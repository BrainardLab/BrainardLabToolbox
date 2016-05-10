% Method for drawing the observer's face
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function drawFace(obj)

    [x,y,z] = sphere(40);
    
    % face
    faceWidth = 14/1.3;
    faceHeight = 15/1.3;
    faceDepth = 12/1.3;
    
    % face ball
    %surf(obj.sceneView, x*faceWidth, y*faceDepth - obj.viewingDistance - 7.0, z*faceHeight-4,  'LineWidth', 0.2, 'EdgeColor', [0.3 0.3 0.2], 'FaceAlpha', 0.2);
    
    % eyes
    R = 1.4;
    xx = x*R;
    yy = y*R;
    zz = z*R;
    surf(obj.sceneView, xx + obj.eyePositionLeft(1),  yy + obj.eyePositionLeft(2),  zz + obj.eyePositionLeft(3),  'LineWidth', 0.2, 'EdgeColor', 'none', 'FaceColor', [1 0.5 0], 'FaceAlpha', 0.5);
    surf(obj.sceneView, xx + obj.eyePositionRight(1), yy + obj.eyePositionRight(2), zz + obj.eyePositionRight(3),  'LineWidth', 0.2, 'EdgeColor', 'none', 'FaceColor', [0 0.5 1], 'FaceAlpha', 0.5);
    
    % nodal points
    markerSize = 10;
    scatter3(obj.sceneView, obj.eyePositionLeft(1), obj.eyePositionLeft(2), obj.eyePositionLeft(3), markerSize, 'ko', 'filled');
    scatter3(obj.sceneView, obj.eyePositionRight(1), obj.eyePositionRight(2), obj.eyePositionRight(3),  markerSize , 'ko', 'filled');
end

