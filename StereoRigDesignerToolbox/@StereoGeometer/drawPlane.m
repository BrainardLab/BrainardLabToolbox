function drawPlane(obj, plane, color, opacity, normalVectorDisplay, boundaryPointsDisplay, varargin)
    
    if (~isstruct(normalVectorDisplay))
        error('the second argument to drawPlane must be a struct describing the normal vector display');
    end
    
    if (~isstruct(boundaryPointsDisplay))
        error('the second argument to drawPlane must be a struct describing the boundary points display');
    end
    
    if (~isempty(varargin)) && (ischar(varargin{1}))
        xCoords = plane.boundaryPoints(1,:);
        yCoords = plane.boundaryPoints(2,:);
        zCoords = plane.boundaryPoints(3,:);
        
        if (strcmp(varargin{1}, 'outline'))
            % draw plane's outline only
            for k = 1:3
                plot3(obj.sceneView, [xCoords(k) xCoords(k+1)], [yCoords(k) yCoords(k+1)], [zCoords(k) zCoords(k+1)], ':', 'LineWidth', 2.0, 'Color', color);
            end
            plot3(obj.sceneView, [xCoords(4) xCoords(1)], [yCoords(4) yCoords(1)], [zCoords(4) zCoords(1)], ':', 'LineWidth', 2.0, 'Color', color);
        elseif (strcmp(varargin{1}, 'fill+outline'))
            % draw plane as a filledpatch
            h = patch('Faces',[1 2 3 4],'Vertices',(plane.boundaryPoints)');
            h.FaceColor = color;
            h.FaceAlpha = opacity;
            h.EdgeColor = [0.0 0.0 0.0];
            h.LineStyle = '-';
            h.LineWidth = 1.0;
            h.Parent = obj.sceneView;
             % draw plane's outline only
            for k = 1:3
                plot3(obj.sceneView, [xCoords(k) xCoords(k+1)], [yCoords(k) yCoords(k+1)], [zCoords(k) zCoords(k+1)], '-', 'LineWidth', 1.0, 'Color', color);
            end
            plot3(obj.sceneView, [xCoords(4) xCoords(1)], [yCoords(4) yCoords(1)], [zCoords(4) zCoords(1)], '-', 'LineWidth', 1.0, 'Color', color);
        elseif (strcmp(varargin{1}, 'no outline'))
            % draw plane as a filledpatch
            h = patch('Faces',[1 2 3 4],'Vertices',(plane.boundaryPoints)');
            h.FaceColor = color;
            h.FaceAlpha = opacity;
            h.EdgeColor = [0.0 0.0 0.0];
            h.EdgeAlpha = 0;
            h.LineStyle = '-';
            h.LineWidth = 0.1;
            h.Parent = obj.sceneView;
        end
    else
        % draw plane as a filledpatch
        h = patch('Faces',[1 2 3 4],'Vertices',(plane.boundaryPoints)');
        h.FaceColor = color;
        h.FaceAlpha = opacity;
        h.EdgeColor = [0.0 0.0 0.0];
        h.EdgeAlpha = 0.5;
        h.LineStyle = '-';
        h.LineWidth = 1;
        h.Parent = obj.sceneView;
    end
    
    if (boundaryPointsDisplay.isOn)
        S = 2*repmat(boundaryPointsDisplay.size, [size(plane.boundaryPoints,2) 1]);
        scatter3(plane.boundaryPoints(1,:), plane.boundaryPoints(2,:), plane.boundaryPoints(3,:), S, 'filled');
        for k = 1:numel(plane.boundaryLabels)
            text(plane.boundaryPoints(1,k), plane.boundaryPoints(2,k), plane.boundaryPoints(3,k), [' ' plane.boundaryLabels{k}], 'FontSize', boundaryPointsDisplay.size);
        end
    end
    
    if (normalVectorDisplay.isOn)
        normalVectorP1 = mean(plane.boundaryPoints,2);
        normalVectorP2 = normalVectorP1 + plane.normal/max(abs(plane.normal)) * normalVectorDisplay.length;
        plot3([normalVectorP1(1) normalVectorP2(1)], [normalVectorP1(2) normalVectorP2(2)], [normalVectorP1(3) normalVectorP2(3)], 'k-', 'LineWidth', 1.0);
    end
    
end