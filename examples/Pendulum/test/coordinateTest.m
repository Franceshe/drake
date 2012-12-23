function coordinateTest(is,js)

if (nargin<1) is=1:12; end
if (nargin<2) js=1:4; end  

syms q qd;

options=struct();
for i=is
for j=js
    
if (j<=2)
  twod = true;
  if ismember(i,[1:3,7:8])
    options.view = 'right';
  elseif ismember(i,[4:6,9:10])
    options.view = 'front';
  else
    options.view = 'top';
  end

  m = PlanarRigidBodyModel(['p',num2str(i),'.urdf'],options);
  if mod(j,2)%even(j)
    m.gravity=[-9.81;0];
  elseif ismember(i,[11 12])
    m.gravity=[0;-9.81];
  end
  m = compile(m);
  m = deleteMexPointer(m);
  r = PlanarRigidBodyManipulator(m);

else
  twod = false;
  m = RigidBodyModel(['p',num2str(i),'.urdf']);
  if ismember(i,[1:3,7:8])
    if mod(j,2)%even(j)
      m.gravity=[-9.81;0;0];
    end
  elseif ismember(i,[4:6,9:10])
    if mod(j,2)%even(j)
      m.gravity=[0;-9.81;0];
    end
  elseif ismember(i,[11 12])
    if mod(j,2)%even(j)
      m.gravity=[0;-9.81;0];
    else
      m.gravity=[-9.81;0;0];
    end
  end
  
  m = compile(m);
  m = deleteMexPointer(m);
  r = RigidBodyManipulator(m);
end

xtraj = r.simulate([0 10],randn(2,1));

if (nargin>0)
  v = r.constructVisualizer();
  if (twod)
    v.xlim = .7*[-1 1];
    v.ylim = .7*[-1 1];
  end
  v.playback(xtraj);
end

xf = eval(xtraj,10);

m.doKinematics(xf(1));
c = m.body(2).com;

comf = m.forwardKin(2,c);
if (twod) 
fprintf(1,'i:%d,j:%d,2D, c: %s, a: %s, v: %s, g: %s, s: %d, qf: %s, cf: %s.\n',i,j,mat2str(c),mat2str(m.body(2).joint_axis), options.view, mat2str(m.gravity), m.body(2).jsign, num2str(xf(1)), mat2str(comf,1));
else
fprintf(1,'i:%d,j:%d,3D, c: %s, a: %s, g: %s, qf: %s, cf: %s.\n',i,j,mat2str(c),mat2str(m.body(2).joint_axis), mat2str(m.gravity), num2str(xf(1)), mat2str(comf,1));
end

%qddot = sodynamics(r,0,q,qd,0)
if (comf'*m.gravity<.4)
  fprintf(1,'grav check: ');
  cprintf('red','fail\n');
  error('com should be drawn towards gravity!');
else
  fprintf(1,'grav check: pass\n');
end

m.doKinematics(pi/4);
if twod
  postheta = m.forwardKin(2,[1;0]);
  if valuecheck(m.body(2).joint_axis,[0;1;0])
    pthetaOK=postheta(2)<0;
  elseif valuecheck(m.body(2).joint_axis,[0;-1;0])
    pthetaOK=postheta(2)>0;
  elseif valuecheck(m.body(2).joint_axis,[1;0;0])
    pthetaOK=postheta(2)>0;
  elseif valuecheck(m.body(2).joint_axis,[-1;0;0])
    pthetaOK=postheta(2)<0;
  elseif valuecheck(m.body(2).joint_axis,[0;0;1])
    pthetaOK=postheta(2)>0;
  elseif valuecheck(m.body(2).joint_axis,[0;0;-1])
    pthetaOK=postheta(2)<0;
  else
    warning('this "positive theta" check is not implemented yet');
    pthetaOK=true;
  end
else
  if valuecheck(m.body(2).joint_axis,[0;1;0])
    postheta = m.forwardKin(2,[1;0;0]);
    pthetaOK=postheta(3)<0;
  elseif valuecheck(m.body(2).joint_axis,[0;-1;0])
    postheta = m.forwardKin(2,[1;0;0]);
    pthetaOK=postheta(3)>0;
  elseif valuecheck(m.body(2).joint_axis,[1;0;0])
    postheta = m.forwardKin(2,[0;1;0]);
    pthetaOK=postheta(3)>0;
  elseif valuecheck(m.body(2).joint_axis,[-1;0;0])
    postheta = m.forwardKin(2,[0;1;0]);
    pthetaOK=postheta(3)<0;
  elseif valuecheck(m.body(2).joint_axis,[0;0;1])
    postheta = m.forwardKin(2,[1;0;0]);
    pthetaOK = postheta(2)>0;
  elseif valuecheck(m.body(2).joint_axis,[0;0;-1])
    postheta = m.forwardKin(2,[1;0;0]);
    pthetaOK = postheta(2)<0;
  else
    warning('this "positive theta" check is not implemented yet');
    pthetaOK=true;
  end
end

if pthetaOK
  fprintf(1,'pos theta check: pass\n');
else
  fprintf(1,'pos theta check: ');
  cprintf('red','fail\n');
  error('positive theta check failed');
end

fprintf(1,'\n');
end

end