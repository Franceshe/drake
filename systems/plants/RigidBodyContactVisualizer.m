classdef RigidBodyContactVisualizer < Visualizer
  
  methods
    function obj = RigidBodyContactVisualizer(frame,model)
      obj=obj@Visualizer(frame);
      
      if (nargin<1)
        [filename,pathname]=uigetfile('*.urdf');
        obj.model = RigidBodyModel(fullfile(pathname,filename),options);
      elseif ischar(model)
        obj.model = RigidBodyModel(model);
      elseif isa(model,'RigidBodyModel')
        obj.model = model;
      else
        error('model must be a RigidBodyModel or the name of a urdf file'); 
      end
    end
    
    function draw(obj,t,x)

      persistent hFig;
      
      if (isempty(hFig))
        hFig = sfigure(32);
        set(hFig,'DoubleBuffer','on');
      end

      sfigure(hFig);
      clf; hold on;
      
      n = obj.model.featherstone.NB;
      q = x(1:n); qd=x(n+(1:n));
      obj.model.doKinematics(q);
      
      % for debugging:
      %co = get(gca,'ColorOrder');
      %h = [];
      % end debugging

      for i=1:length(obj.model.body)
        body = obj.model.body(i);
        nC = size(body.contact_pts,2);
        if nC>0
          contact_pos = forwardKin(obj.model,i,body.contact_pts);
          ind = nchoosek(1:nC,2);
          for k=1:size(ind,1)
            line(contact_pos(1,ind(k,:)),contact_pos(2,ind(k,:)),contact_pos(3,ind(k,:)));
          end
        end
      end
      
      axis equal;
      view(0,10);
      if ~isempty(obj.xlim)
        xlim(obj.xlim);
      end
      if ~isempty(obj.ylim)
        ylim(obj.ylim);
      end
      if ~isempty(obj.axis)
        axis(obj.axis);
      end
      
      title(['t = ', num2str(t,'%.2f') ' sec']);
      drawnow;
    end
  end

  properties
    model;
    xlim=[]
    ylim=[];
  end
end
