% Method for computing the transform from monitor coords to virtual plane coords
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function compute2DTransformFromMonitorCoordsToVirtualPlaneCoords(obj)

    virtualStimulusPlanes = {obj.virtualLeftMonocularStimulus, obj.virtualRightMonocularStimulus};
    virtualStimulusProjectionPlanes = {obj.virtualLeftMonocularStimulusProjectionOnLeftMonitor, obj.virtualRightMonocularStimulusProjectionOnRightMonitor};
    zRotations = [obj.monitorRotationLeft, obj.monitorRotationRight];
    sideNames = {'left', 'right'};
    
    obj.monitorCoordsToVirtualPlaneCoordsTransform = containers.Map();
    
    for k = 1:numel(virtualStimulusProjectionPlanes)
        % unrotate monitor plane, so that we can get the xz coords with y = fixed
        tmpPlane = obj.rotatePlane(virtualStimulusProjectionPlanes{k}, 'zAxis', -zRotations(k));
        xMonitorCoords = tmpPlane.boundaryPoints(1,:);
        yMonitorCoords = tmpPlane.boundaryPoints(3,:);
        sourcePoints = [xMonitorCoords(:) yMonitorCoords(:)];
        
        virtualStimulus = virtualStimulusPlanes{k};
        xVirtualPlaneCoords = virtualStimulus.boundaryPoints(1,:);
        yVirtualPlaneCoords = virtualStimulus.boundaryPoints(3,:);
        transformedPoints = [xVirtualPlaneCoords(:) yVirtualPlaneCoords(:)];
        obj.monitorCoordsToVirtualPlaneCoordsTransform(sideNames{k}) = fitgeotrans(sourcePoints, transformedPoints, 'projective');
    end
    
end