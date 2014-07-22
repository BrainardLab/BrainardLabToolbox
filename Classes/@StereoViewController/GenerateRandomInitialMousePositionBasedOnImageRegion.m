function [xMousePixels, yMousePixels] = GenerateRandomInitialMousePositionBasedOnImageRegion(obj, imageRegion, screenConfig, positionsNum)
%   [xMousePixels, yMousePixels] = GenerateRandomInitialMousePositionWithinAnImageRegion(obj, imageRegion, screenConfig, positionsNum)
%
%   Description:
%   Method that generates a random mouse position within an image area 
%
%   Parameters:
%   obj: -- The parent StereoViewController object
%   region -- struct specifying the region within the image
%   screenConfig - struct with the specifics of the display
%   positionsNum -- how many random positions to generate
%
%   History:
%   @code  
%   4/27/2013    npc    Wrote it 
%   @endcode
%
            
    screenWidthInPixels       = screenConfig.screenSizePixel(1);
    screenHeightInPixels      = screenConfig.screenSizePixel(2);
    screenWidthInCentimeters  = screenConfig.screenSizeMM(1)/10;
    screenHeightInCentimeters = screenConfig.screenSizeMM(2)/10;
    
    tryAgain = true;
    while (tryAgain)
        
        includedPoints = [];
        while (isempty(includedPoints))
            % Generate 10 times more points than requested, in case the region
            % between the includePolygon and the excludePolygon is too narrow.
            randomPointsNum = 10 * positionsNum;
            randomPositions = rand(randomPointsNum, 2) .* repmat([imageRegion.parentImageWidthInPixels imageRegion.parentImageHeightInPixels], [randomPointsNum 1]);

            insideExcludePolygon = inpolygon(randomPositions(:,1), randomPositions(:,2), imageRegion.excludePerimeterPoints(:,1), imageRegion.excludePerimeterPoints(:,2));
            insideIncludePolygon = inpolygon(randomPositions(:,1), randomPositions(:,2), imageRegion.includePerimeterPoints(:,1), imageRegion.includePerimeterPoints(:,2));
            includedPoints = find((insideExcludePolygon == false) & (insideIncludePolygon == true));
            if (isempty(includedPoints))
               disp('Did not find any points in the region between the specified polygons. Will try again ...');
            end
        end
    
        mousePos(:,1) = randomPositions(includedPoints,1);
        mousePos(:,2) = randomPositions(includedPoints,2);

        % Now transform image coords to screen centimeters
        xMouseCm = ((mousePos(:,1)/ imageRegion.parentImageWidthInPixels - 0.5) * imageRegion.parentImageWidthInCm);
        yMouseCm = ((mousePos(:,2)/ imageRegion.parentImageHeightInPixels - 0.5) * imageRegion.parentImageHeightInCm);
    
        % Adjust position to take into account the screen warping and translation factors
        %xMouseCm = xMouseCm + screenConfig.originInCm(1);
        %yMouseCm = yMouseCm + screenConfig.originInCm(2);
        
        % Transform to screen pixels
        xMousePixels = (xMouseCm/screenWidthInCentimeters  + 0.5) * screenWidthInPixels;
        yMousePixels = (yMouseCm/screenHeightInCentimeters + 0.5) * screenHeightInPixels;

        % Invert y-coord
        yMousePixels = screenHeightInPixels - yMousePixels;

        % Adjust position to take into account the screen warping and translation factors
        xMousePixels = xMousePixels + screenConfig.originInCm(1) * screenWidthInPixels/screenWidthInCentimeters; 
        yMousePixels = yMousePixels + screenConfig.originInCm(2) * screenWidthInPixels/screenWidthInCentimeters;

        % Make sure the xy coords are within the screen boundaries. 
        % If the image scaling is too large they may be outside those
        % boundaries. All units here are pixels.
        margin = 30;
        xmin = margin;
        ymin = margin;
        xmax = screenWidthInPixels - margin;
        ymax = screenHeightInPixels - margin;
        includedPoints = find( (xMousePixels > xmin) & (xMousePixels < xmax) & (yMousePixels > ymin) & (yMousePixels < ymax) );
    
        % Ensure we have at least one valid point
        if isempty(includedPoints)
            tryAgain = true;
        else
            tryAgain = false;
            xMousePixels = xMousePixels(includedPoints);
            yMousePixels = yMousePixels(includedPoints);
        end
    end  % while tryAgain
    
    % Return as many points as requested, or what we were able to get
    xMousePixels = round(xMousePixels(1:min([length(includedPoints) positionsNum])));
    yMousePixels = round(yMousePixels(1:min([length(includedPoints) positionsNum])));
end