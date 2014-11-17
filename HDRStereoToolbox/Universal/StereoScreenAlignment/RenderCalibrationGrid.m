function RenderCalibrationGrid(windowPtr, X, Y, Xnominal, Ynominal, activeNodeRow, activeNodeCol, displayString, gridColor, gridDistortionTracesColor, gridNodesColor, activeNodeColor)
%
    % Get the rows and cols from X
    rowsNum = size(X,1);
    colsNum = size(X,2);
    
    % Compute the horizontal grid line segments
    xCoordVector = [];
    yCoordVector= [];
    for row = 1:rowsNum
        for col = 1:colsNum-1
            xCoord1 = X(row, col);
            yCoord1 = Y(row, col);
            xCoord2 = X(row, col+1);
            yCoord2 = Y(row, col+1);
            xCoordVector = [xCoordVector xCoord1 xCoord2];
            yCoordVector = [yCoordVector yCoord1 yCoord2];
        end % for col
    end % for row

    % Compute the vertical grid line segments
    for col = 1:colsNum
        for row = 1:rowsNum-1
            xCoord1 = X(row, col);
            yCoord1 = Y(row, col);
            xCoord2 = X(row+1, col);
            yCoord2 = Y(row+1, col);
            xCoordVector = [xCoordVector xCoord1 xCoord2];
            yCoordVector = [yCoordVector yCoord1 yCoord2];
        end % for row
    end % for col
    
    % Draw all line segments for the distorted grid
    lineWidthInPixels = 2; smooth = 2;
    Screen('DrawLines', windowPtr, [xCoordVector; yCoordVector], lineWidthInPixels, gridColor, [], smooth);
    
    if (~isempty(gridDistortionTracesColor))
        % Draw all line segments connecting nominal to distorted grid
        xCoordVector = [];
        yCoordVector = [];
        for row = 1:rowsNum
            for col = 1:colsNum
                xCoord1 = Xnominal(row, col);
                yCoord1 = Ynominal(row, col);
                xCoord2 = X(row, col);
                yCoord2 = Y(row, col);
                xCoordVector = [xCoordVector xCoord1 xCoord2];
                yCoordVector = [yCoordVector yCoord1 yCoord2];
            end % for col
        end % for row

        lineWidthInPixels = 2; smooth = 2;
        Screen('DrawLines', windowPtr, [xCoordVector; yCoordVector], lineWidthInPixels, gridDistortionTracesColor, [], smooth);
    end
    
    
    % Draw the grid nodes
    dotXYpositions = [ reshape(X, 1, numel(X)); ...
                       reshape(Y, 1, numel(Y)) ...
                     ];
    dotSizes  = 15 * ones(1, numel(X));
    dotCenter = [];
    dotType = 2; % circles with anti-aliasing
    Screen('DrawDots', windowPtr, dotXYpositions, dotSizes, gridNodesColor, dotCenter, dotType);
    
    
    
    % Draw the active node as a green square
    activeNodeXYpos = [X(activeNodeRow, activeNodeCol); Y(activeNodeRow, activeNodeCol)];
    activeNodeSize  = 16;
    dotType = 0; % square
    Screen('DrawDots', windowPtr, activeNodeXYpos, activeNodeSize, activeNodeColor, dotCenter, dotType);
    
    % Finally display current alignment settings
    if (~isempty(displayString))
        borderWidth = 1;
        screenXo = 1920/2;
        screenYo = 1080/2;
        
        if (Xnominal(activeNodeRow, activeNodeCol) > screenXo)
            xStringPos = 0;
            x1 = 1;
            x2 = 600;
        else
            xStringPos = 1920-595;
            x1 = 1920-600;
            x2 = 1920;
        end     
   
        % Text background
        infoRect = [x1 screenYo-320 x2 screenYo+320];
        Screen('FillRect', windowPtr, [0.3 0.3 0.3], infoRect );
        Screen('FrameRect', windowPtr, [0.0 1.0 0.0], infoRect, borderWidth );
        
        % Text
        Screen('TextSize', windowPtr, 24);
        textStyle = 0;
        Screen('TextFont', windowPtr, 'Courier', textStyle);
        DrawFormattedText(windowPtr, displayString, xStringPos, 'center', [0.9, 0.9, 0.8]);
    end
    
    Screen('Flip', windowPtr); 
end