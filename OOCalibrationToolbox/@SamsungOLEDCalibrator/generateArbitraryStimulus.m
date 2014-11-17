function demoFrame = generateArbitraryStimulus(obj, temporalDitheringMode, leftTarget, rightTarget, leftTargetGray, rightTargetGray, stimulationPattern)

    % 1. scene
    scene.width  = 1920;
    scene.height = 1080;
    scene.x0     = 1920/2;
    scene.y0     = 1080/2;
    sceneRect    = CenterRectOnPointd([0 0 scene.width scene.height], scene.x0, scene.y0);
    scene.data   = repmat(stimulationPattern, [1 1 3]);
    
    % update demo frame
    demoFrame = scene.data;
    
    % 2. Left target
    leftTargetRect   = CenterRectOnPointd([0 0 leftTarget.width leftTarget.height], leftTarget.x0, leftTarget.y0);
    leftTarget.data  = DiskMatrix(leftTarget.height, leftTarget.width, leftTargetGray, []);
    
    % update demo frame
    demoFrame        = UpdateDemoFrame(demoFrame, leftTarget);
    
    % 3. Right target
    rightTargetRect  = CenterRectOnPointd([0 0 rightTarget.width rightTarget.height], rightTarget.x0, rightTarget.y0);
    rightTarget.data = DiskMatrix(rightTarget.height, rightTarget.width, rightTargetGray, []);
    
    % update demo frame
    demoFrame        = UpdateDemoFrame(demoFrame, rightTarget);
    
    
    if (obj.runMode)
        obj.stimDataMatrices     = {};
        obj.stimDestinationRects = {};
        obj.ditheringMatrices    = {};

        obj.stimDataMatrices{1} = scene.data;
        obj.stimDataMatrices{2} = leftTarget.data;
        obj.stimDataMatrices{3} = rightTarget.data;

        obj.stimDestinationRects{1} = sceneRect;
        obj.stimDestinationRects{2} = leftTargetRect;
        obj.stimDestinationRects{3} = rightTargetRect;

        obj.ditheringMatrices{1} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, scene.height, scene.width);
        obj.ditheringMatrices{2} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, leftTarget.height, leftTarget.width);
        obj.ditheringMatrices{3} = SamsungOLEDCalibrator.generateMatrixDitherOffsets(temporalDitheringMode, rightTarget.height, rightTarget.width);

        % Render stimulus
        obj.displayMultiRectPattern();
    end
    
    
end


function demoFrame = UpdateDemoFrame(oldDemoFrame, stim)
    demoFrame = oldDemoFrame;
    ii = stim.y0 - round(stim.height/2) + (1:stim.height);
    jj = stim.x0 - round(stim.width/2) + (1:stim.width);
    stim.data(find(stim.data<0)) = 0;
    stim.data(find(stim.data>1)) = 1;
    demoFrame(ii,jj,:) = stim.data;    
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
