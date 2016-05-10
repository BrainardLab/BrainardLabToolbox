% Method for computing the monitor projections to the virtual plane
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function generateMonitorProjectionsToVirtualPlane(obj)

    debug = false;
    monitorPlanes = {obj.leftMonitorPlane, obj.rightMonitorPlane};
    
    if (debug)
        % for testing purposes, when using the projection planes we should go
        % back to the idential virtual stimulus
        monitorPlanes = {obj.virtualLeftMonocularStimulusProjectionOnLeftMonitor, obj.virtualRightMonocularStimulusProjectionOnRightMonitor};
        fprintf(2, 'In debug mode. Will backprojec monitor stimuli instead of monitor outlines\n');
    end
    
    zRotations = [obj.monitorRotationLeft, obj.monitorRotationRight];
    sideNames = {'left', 'right'};
    
    for s = 1:numel(monitorPlanes)
        % unrotate monitor plane, so that we can get the xz coords with y = fixed
        tmpPlane = obj.rotatePlane(monitorPlanes{s}, 'zAxis', -zRotations(s));
        
        xMonitorCoords = tmpPlane.boundaryPoints(1,:);
        yMonitorCoords = tmpPlane.boundaryPoints(3,:);
        
        % compute transformation of monitor points to virtual plane points
        [xVirtualPlaneCoords, yVirtualPlaneCoords] = transformPointsForward(obj.monitorCoordsToVirtualPlaneCoordsTransform(sideNames{s}), xMonitorCoords, yMonitorCoords);

        for k = 1:4
            p(:,k) = [xVirtualPlaneCoords(k); 0; yVirtualPlaneCoords(k)];
            pLabel{k} = tmpPlane.boundaryLabels{k};
        end
    
        if (strcmp(sideNames{s}, 'left'))
            obj.leftMonitorImageOnVirtualPlane = obj.generatePlane('left monitor image', p(:,1), p(:,2), p(:,3), p(:,4), pLabel{1}, pLabel{2},pLabel{3}, pLabel{4});
        else
            obj.rightMonitorImageOnVirtualPlane = obj.generatePlane('right monitor image', p(:,1), p(:,2), p(:,3), p(:,4), pLabel{1}, pLabel{2},pLabel{3}, pLabel{4});
        end
    end
end