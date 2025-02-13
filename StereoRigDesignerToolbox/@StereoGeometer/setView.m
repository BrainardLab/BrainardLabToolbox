% Method to set the 3D viewing angle
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function setView(obj, mode)
            
    if (ischar(mode))
        switch (mode)
            case 'rightView'
                view(obj.sceneView, [90 0])

            case 'leftView'
                view(obj.sceneView, [-90 0])

            case 'topView'
                view(obj.sceneView, [0 90])

            case 'rearView'
                view(obj.sceneView, [0 0])

            case 'frontView'
                view(obj.sceneView, [180 0])

            case 'defaultView'
                view(obj.sceneView, obj.viewAngles)
        end
    else
        view(obj.sceneView, mode)
    end

    drawnow;
end