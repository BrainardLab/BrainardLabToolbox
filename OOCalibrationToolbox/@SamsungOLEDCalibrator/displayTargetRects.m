function displayTargetRects(obj, leftTargetSize, rightTargetSize, leftTargetPos, rightTargetPos)

    leftGrayLevel = 0.2;
    rightGrayLevel = 0.8;
    bkgnd = 0.5;
    
    % Left target
    leftTarget.width    = leftTargetSize;
    leftTarget.height   = leftTargetSize;
    leftTarget.x0       = leftTargetPos(1);
    leftTarget.y0       = leftTargetPos(2);
    leftTargetRect      = CenterRectOnPointd([0 0 leftTarget.width leftTarget.height], leftTarget.x0, leftTarget.y0);
    leftTarget.data     = DiskMatrix(leftTarget.height, leftTarget.width, leftGrayLevel, bkgnd);
    
    % Right target
    rightTarget.width   = rightTargetSize;
    rightTarget.height  = rightTargetSize;
    rightTarget.x0      = rightTargetPos(1);
    rightTarget.y0      = rightTargetPos(2);
    rightTargetRect     = CenterRectOnPointd([0 0 rightTarget.width rightTarget.height], rightTarget.x0, rightTarget.y0);
    rightTarget.data    = DiskMatrix(rightTarget.height, rightTarget.width, rightGrayLevel, bkgnd);
        
    % Frame
    backDrop.width      = 3*1920/4;
    backDrop.height     = 3*1080/4;
    backDrop.x0         = 1920/2;
    backDrop.y0         = 1080/2;
    backDropRect        = CenterRectOnPointd([0 0 backDrop.width backDrop.height], backDrop.x0, backDrop.y0);
    backDrop.data       = ones(backDrop.height,backDrop.width,3)*bkgnd;
        
    % Generate dithering matrices
    % temporalDitheringMode = '10BitPlusNoise';
    temporalDitheringMode = '10BitNoNoise';
    % temporalDitheringMode = '8Bit';
    
    leftTargetDitheringMatrix  = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, leftTarget.height, leftTarget.width);
    rightTargetDitheringMatrix = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, rightTarget.height, rightTarget.width);
    backDropDitheringMatrix    = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, backDrop.height, backDrop.width);
    
        
    % Render stimulus
    obj.display3Rects(backDrop.data, leftTarget.data, rightTarget.data, ...
        backDropRect, leftTargetRect, rightTargetRect, ...
        backDropDitheringMatrix, leftTargetDitheringMatrix, rightTargetDitheringMatrix);
        
end


function m = DiskMatrix(height, width, target, bkgnd)
    z = ones(height, width)*target;
    x = ((1:width)-width/2)/(width/2);
    y = ((1:height)-height/2)/(height/2);
    [X,Y]       = meshgrid(x,y);
    indices     = find(sqrt(X.^2 + Y.^2) > 0.9);
    z(indices)  = bkgnd;
    m(:,:,1)    = z;
    m(:,:,2)    = z;
    m(:,:,3)    = z;
    size(m)
end
