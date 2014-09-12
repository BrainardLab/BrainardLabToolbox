function generateStimulus(obj, stabilizerGray, bkgndGray, biasGray, leftTargetGray, rightTargetGray, biasOri)

    % Targets
    targetSize      = 100;
    leftTarget.x0   = 1920/2 - 300;
    leftTarget.y0   = 1080/2;
    rightTarget.x0  = 1920/2 + 300;
    rightTarget.y0  = 1080/2;
    
    
    bkgndMaxDev    = 0.1;

    
    % 1. Stabilizer
    stabilizer.width        = 1920;
    stabilizer.height       = 1080;
    stabilizer.borderWidth  = 250;
    stabilizer.x0           = 1920/2;
    stabilizer.y0           = 1080/2;
    stabilizerRect          = CenterRectOnPointd([0 0 stabilizer.width stabilizer.height], stabilizer.x0, stabilizer.y0);
    stabilizer.data         = repmat(ones(stabilizer.height,stabilizer.width)*stabilizerGray, [1 1 3]);
      
    % 2. Background
    background.width        = stabilizer.width  - 2*stabilizer.borderWidth;
    background.height       = stabilizer.height - 2*stabilizer.borderWidth;
    background.x0           = 1920/2;
    background.y0           = 1080/2;
    backgroundRect          = CenterRectOnPointd([0 0 background.width background.height], background.x0, background.y0);
    backgroundRows          = 10;
    backgroundCols          = 20;
    zoom                    = round(0.5*(background.height/backgroundRows + background.width/backgroundCols)+0.5);
    lowResMatrix            = bkgndGray+bkgndMaxDev*2*(rand(backgroundRows,backgroundCols)-0.5);
    hiResMatrix             = kron(lowResMatrix, ones(zoom));
    actualHeight            = size(hiResMatrix,1);
    actualWidth             = size(hiResMatrix,2);
    hiResMatrix             = hiResMatrix(1:min([background.height actualHeight]), 1:min([background.width actualWidth]));
    background.height       = size(hiResMatrix,1);
    background.width        = size(hiResMatrix,2);
    background.data         = repmat(hiResMatrix, [1 1 3]);
    
    
    % 3. Bias pattern (centered on left target)
    % vertical bar
    if (biasOri == 90)
        bias.width              = 150;
        bias.height             = 550;
    else 
    % or horizontal bar
        bias.width              = 550;
        bias.height             = 150;
    end
    
    bias.x0                 = leftTarget.x0;
    bias.y0                 = leftTarget.y0;
    biasRect                = CenterRectOnPointd([0 0 bias.width bias.height], bias.x0, bias.y0);
    bias.data               = repmat(ones(bias.height,bias.width)*biasGray, [1 1 3]);
    
    
    
    
    % 4. Left target
    leftTarget.width        = targetSize;
    leftTarget.height       = targetSize;
    leftTargetRect          = CenterRectOnPointd([0 0 leftTarget.width leftTarget.height], leftTarget.x0, leftTarget.y0);
    leftTarget.data         = DiskMatrix(leftTarget.height, leftTarget.width, leftTargetGray, biasGray);
    
    % 5. Right target
    rightTarget.width       = targetSize;
    rightTarget.height      = targetSize;
    rightTargetRect         = CenterRectOnPointd([0 0 rightTarget.width rightTarget.height], rightTarget.x0, rightTarget.y0);
    rightTarget.data        = DiskMatrix(rightTarget.height, rightTarget.width, rightTargetGray, bkgndGray);
    
    
    
    % Generate dithering matrices
    % temporalDitheringMode = '10BitPlusNoise';
    temporalDitheringMode = '10BitNoNoise';
    % temporalDitheringMode = '8Bit';
    
    obj.stimDataMatrices     = {};
    obj.stimDestinationRects = {};
    obj.ditheringMatrices    = {};
    
    obj.stimDataMatrices{1} = stabilizer.data;
    obj.stimDataMatrices{2} = background.data;
    obj.stimDataMatrices{3} = bias.data;
    obj.stimDataMatrices{4} = leftTarget.data;
    obj.stimDataMatrices{5} = rightTarget.data;
    
    obj.stimDestinationRects{1} = stabilizerRect;
    obj.stimDestinationRects{2} = backgroundRect;
    obj.stimDestinationRects{3} = biasRect;
    obj.stimDestinationRects{4} = leftTargetRect;
    obj.stimDestinationRects{5} = rightTargetRect;
    
    obj.ditheringMatrices{1} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, stabilizer.height, stabilizer.width);
    obj.ditheringMatrices{2} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, background.height, background.width);
    obj.ditheringMatrices{3} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, bias.height, bias.width);
    obj.ditheringMatrices{4} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, leftTarget.height, leftTarget.width);
    obj.ditheringMatrices{5} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, rightTarget.height, rightTarget.width);
    
    % Render stimulus
    obj.displayMultiRectPattern();
       
end


function m = DiskMatrix(height, width, target, bkgnd)
    z = ones(height, width)*target;
    if (1==2)
    x = ((1:width)-width/2)/(width/2);
    y = ((1:height)-height/2)/(height/2);
    [X,Y]       = meshgrid(x,y);
    R2          = 0.9^2;
    indices     = find(X.^2 + Y.^2 > R2);
    z(indices)  = bkgnd;
    end
    m(:,:,1)    = z;
    m(:,:,2)    = z;
    m(:,:,3)    = z;
end
