function OOC_analyzeSamsungOLEDCal

    close all
    clear all
    clear classes
    clc
    

    % Data file where all data structs are appended
    calibrationFileName = '/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/OOCalibrationToolbox/SamsungOLED_calib.mat';
    
    % create a MAT-file object that supports partial loading and saving.
    matOBJ = matfile(calibrationFileName, 'Writable', false);
    
    % get current variables
    varList = who(matOBJ);
        
    if isempty(varList)
        if (exist(dataSetFilename, 'file'))
            fprintf(2,'No calibration data found in ''%s''.\n', dataSetFilename);
        else
            fprintf(2,'''%s'' does not exist.\n', dataSetFilename);
        end
        calibrationDataSet = [];
        return;        
    end
    
    fprintf('\nFound %d calibration data sets in the saved history.', numel(varList));
    
    % ask the user to select one
    defaultDataSetNo = numel(varList);
    dataSetIndex = input(sprintf('\nSelect a data set (1-%d) [%d]: ', defaultDataSetNo, defaultDataSetNo));
    if isempty(dataSetIndex) || (dataSetIndex < 1) || (dataSetIndex > defaultDataSetNo)
       dataSetIndex = defaultDataSetNo;
    end
      
    % return the selected ground truth data set
    eval(sprintf('calibrationDataSet = matOBJ.%s;',varList{dataSetIndex}));
    
    % Retrieve data
    runParams = calibrationDataSet.runParams;
    allCondsData = calibrationDataSet.allCondsData;
        
 
    
    load T_xyz1931
    
    runParams
    stabilizerGrayLevelNum  = numel(runParams.stabilizerGrays);
    sceneGrayLevelNum       = numel(runParams.sceneGrays);
    biasLevelNum            = numel(runParams.biasGrays);
    biasSizesNum            = size(runParams.biasSizes,1);
    gammaInputValuesNum     = numel(runParams.targetGrays);
        
    
    fprintf('\n\n'); 
    fprintf('\nStabilizer gray levels: ');
    fprintf('%2.2f ', runParams.stabilizerGrays);
    
    fprintf('\nScene gray levels: ');
    fprintf('%2.2f ', runParams.sceneGrays);
    
    fprintf('\nBias gray levels: ');
    fprintf('%2.2f ', runParams.biasGrays);
    
    fprintf('\nBias region sizes (x): ');
    fprintf('%2.2f ', runParams.biasSizes(:, 1));
    
    fprintf('\nBias region sizes (y): ');
    fprintf('%2.2f ', runParams.biasSizes(:, 2));
    
    fprintf('\nGamma input values: ');
    fprintf('%2.3f ', runParams.targetGrays);
    
    fprintf('\n\n');
    
    leftSPD = zeros(stabilizerGrayLevelNum, ...
                    sceneGrayLevelNum, ...
                    biasLevelNum, ...
                    biasSizesNum, ...
                    gammaInputValuesNum, ...
                    numel(allCondsData{1}.leftSPD));
           
    rightSPD = leftSPD;
    
    
    conditionsNum = numel(allCondsData);
    
    for condIndex = 1:conditionsNum
        % get struct for current condition
        conditionData = allCondsData{condIndex};
       
        % get indices
        stabilizerGrayIndex = conditionData.stabilizerGrayIndex;
        sceneGrayIndex = conditionData.sceneGrayIndex;
        biasGrayIndex = conditionData.biasGrayIndex;
        biasSizeIndex = conditionData.biasSizeIndex;
        leftTargetGrayIndex = conditionData.leftTargetGrayIndex;
        rightTargetGrayIndex = conditionData.rightTargetGrayIndex;
        figure(99);
        imshow(conditionData.demoFrame);
        colormap(gray(256));
        set(gca, 'CLim', [0 1]);
        axis 'image'
        
        % get SPD data 
        leftSPD(stabilizerGrayIndex, ...
                sceneGrayIndex, ...
                biasGrayIndex, ...
                biasSizeIndex, ...
                leftTargetGrayIndex, ...
                :) = conditionData.leftSPD;
        
        if (condIndex == 1)
            nativeS = conditionData.leftS;
            vLambdaLeft = 683*SplineCmf(S_xyz1931,T_xyz1931(2,:), nativeS);
            waveLeft = SToWls(nativeS);
            vLambdaRight = [];
            waveRight = [];
        end
        
        if ~isempty(conditionData.rightSPD)
            rightSPD(stabilizerGrayIndex, ...
                    sceneGrayIndex, ...
                    biasGrayIndex, ...
                    biasSizeIndex, ...
                    rightTargetGrayIndex, ...
                    :) = conditionData.rightSPD;
                
            if (condIndex == 1)
                nativeS = conditionData.rightS;
                if ~isempty(nativeS)
                    vLambdaRight = 683*SplineCmf(S_xyz1931,T_xyz1931(2,:), nativeS);
                    waveRight = SToWls(nativeS);
                end
            end
        end % ~isempty(conditionData.rightSPD)
        
    end % cond Index
    
    
    % plot subset of data 
    
    stabilizerGrayIndex = 1;
    sceneGrayIndex = 1;
    biasGrayIndex = 1;
    biasSizeIndex = 1;
    
    stabilizerGray = runParams.stabilizerGrays(stabilizerGrayIndex);
    sceneGray      = runParams.sceneGrays(sceneGrayIndex);
    biasGray       = runParams.biasGrays(biasGrayIndex);
    
    
    maxSPD = max(leftSPD(:));
    
    figure(1);
    clf;
    
    
    gammaOutputLeft = zeros(stabilizerGrayLevelNum, biasSizesNum, gammaInputValuesNum);
    gammaOutputRight = zeros(stabilizerGrayLevelNum, biasSizesNum, gammaInputValuesNum);
    vLeft  = repmat(vLambdaLeft, [gammaInputValuesNum 1]);
    vRight = repmat(vLambdaRight, [gammaInputValuesNum 1]);
    
    for stabilizerGrayIndex = 1:stabilizerGrayLevelNum
        for biasSizeIndex = 1: biasSizesNum
            spd = squeeze(leftSPD(stabilizerGrayIndex, ...
                        sceneGrayIndex, ...
                        biasGrayIndex, ...
                        biasSizeIndex, ...
                        1:gammaInputValuesNum, ...
                        :));
            gammaOutputLeft(stabilizerGrayIndex, biasSizeIndex, :) = sum(spd.*vLeft,2); 
        end
    end
    
    if ~isempty(waveRight)
        for stabilizerGrayIndex = 1:stabilizerGrayLevelNum
            for biasSizeIndex = 1: biasSizesNum
                spd = squeeze(rightSPD(stabilizerGrayIndex, ...
                            sceneGrayIndex, ...
                            biasGrayIndex, ...
                            biasSizeIndex, ...
                            1:gammaInputValuesNum, ...
                            :));
                gammaOutputRight(stabilizerGrayIndex, biasSizeIndex, :) = sum(spd.*vRight,2); 
            end
        end
    end
    
    
    
    gammaInput  = runParams.targetGrays;
    maxGammaOutputLeft = max(gammaOutputLeft(:));
    for stabilizerGrayIndex = 1:stabilizerGrayLevelNum
        stabilizerGray = runParams.stabilizerGrays(stabilizerGrayIndex);
        for biasSizeIndex = 1: biasSizesNum
            biasSizeX = runParams.biasSizes(biasSizeIndex, 1);
            biasSizeY = runParams.biasSizes(biasSizeIndex, 2);
            subplot(stabilizerGrayLevelNum, biasSizesNum, (stabilizerGrayIndex-1)* biasSizesNum + biasSizeIndex);
            plot(gammaInput, squeeze(gammaOutputLeft(stabilizerGrayIndex, biasSizeIndex, :)), 'ks-', 'MarkerFaceColor', [1 0.8 0.8]);
            title(sprintf('stabilizer:%2.2f; biasSize: %2.0fx%2.0f', stabilizerGray, biasSizeX, biasSizeY));
            set(gca, 'YLim', [0 maxGammaOutputLeft]);
            set(gca, 'XTick', [0:0.2:1.0], 'YTick', [0:100:1000]);
            axis 'square'
            axis 'xy'
            grid on;
        end
    end
    
        
end
