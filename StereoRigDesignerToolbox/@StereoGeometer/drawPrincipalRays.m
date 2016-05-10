% Method for drawing the principal rays
%
% Concept and implementation: 
%   Nicolas P. Cottaris, Ph.D.
%   Unversity of Pennsylvania
%
% History:
% 10/13/2015  npc Wrote it.

function drawPrincipalRays(obj)

    if (obj.showMonocularPaths)
        principalRays = {};
        if (obj.showLeftViewFrustum)
            principalRays{numel(principalRays)+1} = obj.leftPrincipalRay;
        end
        if (obj.showRightViewFrustum)
            principalRays{numel(principalRays)+1} = obj.rightPrincipalRay;
        end
    else
        principalRays = {obj.leftPrincipalRay, obj.rightPrincipalRay};
    end
    
    for k = 1:numel(principalRays)
        X = [principalRays{k}.virtualStimulusPoint(1) principalRays{k}.mirrorPoint(1)];
        Y = [principalRays{k}.virtualStimulusPoint(2) principalRays{k}.mirrorPoint(2)];
        Z = [principalRays{k}.virtualStimulusPoint(3) principalRays{k}.mirrorPoint(3)];
        hLine = line(X,Y,Z, 'Color',[1 1 1], 'LineStyle', '--');
        hLine.Parent = obj.sceneView;
        
        X = [principalRays{k}.mirrorPoint(1), principalRays{k}.monitorPoint(1)];
        Y = [principalRays{k}.mirrorPoint(2), principalRays{k}.monitorPoint(2)];
        Z = [principalRays{k}.mirrorPoint(3), principalRays{k}.monitorPoint(3)];
        hLine = line(X,Y,Z, 'Color',[1 1 1], 'LineStyle', '-');
        hLine.Parent = obj.sceneView;
        
        X = [principalRays{k}.mirrorPoint(1), principalRays{k}.nodalPoint(1)];
        Y = [principalRays{k}.mirrorPoint(2), principalRays{k}.nodalPoint(2)];
        Z = [principalRays{k}.mirrorPoint(3), principalRays{k}.nodalPoint(3)];
        hLine = line(X,Y,Z, 'Color',[1 1 1], 'LineStyle', '-');
        hLine.Parent = obj.sceneView;
        
    end
end
