% Method for computing dependent properties
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function computeDependentProperties(obj)

    % compute the dependent properties
    obj.eyePositionLeft  = [-obj.eyeSeparation/2; -obj.viewingDistance; 0];
    obj.eyePositionRight = [ obj.eyeSeparation/2; -obj.viewingDistance; 0];
           
    obj.mirrorDepthPosition = -obj.viewingDistance + obj.mirrorDistanceFromEyeNodalPoint;
    obj.mirrorPositionLeft  = [-(obj.mirrorWidth/2+obj.mirrorOffset)*cos(abs(obj.mirrorRotationLeft)/180*pi);  obj.mirrorDepthPosition + (obj.mirrorWidth/2+obj.mirrorOffset)*(sin(abs(obj.mirrorRotationLeft)/180*pi)); 0];
    obj.mirrorPositionRight = [ (obj.mirrorWidth/2+obj.mirrorOffset)*cos(abs(obj.mirrorRotationRight)/180*pi); obj.mirrorDepthPosition + (obj.mirrorWidth/2+obj.mirrorOffset)*(sin(abs(obj.mirrorRotationRight)/180*pi)); 0];
    
    obj.monitorWidth  = obj.monitorDiagonalSize * cos(obj.monitorPixelsHeight/obj.monitorPixelsWidth);
    obj.monitorHeight = obj.monitorDiagonalSize * sin(obj.monitorPixelsHeight/obj.monitorPixelsWidth);
    obj.monitorPositionLeft  = [-obj.monitorHorizPosition; obj.monitorDepthPosition; 0];
    obj.monitorPositionRight = [ obj.monitorHorizPosition; obj.monitorDepthPosition; 0];

    obj.generateGeometry();
end
