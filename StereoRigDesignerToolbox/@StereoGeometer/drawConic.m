% Method for drawing a conic section
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function drawConic(obj, planeApoints, planeBpoints, color, opacity, edgeColor, edgeStyle)
          
    n = size(planeApoints,2);
    
    for ptIndex = 1:n

        pt1 = ptIndex;
        pt2 = ptIndex+1;
        if (pt2 > n)
            pt2 = 1;
        end
        vertices = [ ...
            planeApoints(1,pt1)  planeApoints(2,pt1)  planeApoints(3,pt1); ...
            planeApoints(1,pt2)  planeApoints(2,pt2)  planeApoints(3,pt2); ...
            planeBpoints(1,pt2)  planeBpoints(2,pt2)  planeBpoints(3,pt2);
            planeBpoints(1,pt1)  planeBpoints(2,pt1)  planeBpoints(3,pt1);
            ];

        h = patch('Faces',[1 2 3 4],'Vertices', vertices);
        h.FaceColor = color;
        h.FaceAlpha = opacity;
        h.EdgeColor = edgeColor;
        h.LineStyle = edgeStyle;
        h.Parent = obj.sceneView;
    end
end