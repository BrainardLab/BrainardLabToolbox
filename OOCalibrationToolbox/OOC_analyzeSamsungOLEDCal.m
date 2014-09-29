function OOC_analyzeSamsungOLEDCal

    close all
    clear all
    clear classes
    clc
    
    % Load calibration file. This will load allCondsData and runParams
    load('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/OOCalibrationToolbox/SamsungOLED_calib.mat');
    
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
                                
        % get SPD data 
        leftSPD(stabilizerGrayIndex, ...
                sceneGrayIndex, ...
                biasGrayIndex, ...
                biasSizeIndex, ...
                leftTargetGrayIndex, ...
                :) = conditionData.leftSPD;
            
        if ~isempty(conditionData.rightSPD)
            rightSPD(stabilizerGrayIndex, ...
                    sceneGrayIndex, ...
                    biasGrayIndex, ...
                    biasSizeIndex, ...
                    rightTargetGrayIndex, ...
                    :) = conditionData.rightSPD;
        end 
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
    
    for stabilizerGrayIndex = 1:stabilizerGrayLevelNum
        
        stabilizerGray = runParams.stabilizerGrays(stabilizerGrayIndex);
        
        for biasSizeIndex = 1: biasSizesNum

            biasSizeX = runParams.biasSizes(biasSizeIndex, 1);
            biasSizeY = runParams.biasSizes(biasSizeIndex, 2);

            spd = squeeze(leftSPD(stabilizerGrayIndex, ...
                        sceneGrayIndex, ...
                        biasGrayIndex, ...
                        biasSizeIndex, ...
                        1:gammaInputValuesNum, ...
                        :));
            subplot(stabilizerGrayLevelNum, biasSizesNum, (stabilizerGrayIndex-1)* biasSizesNum + biasSizeIndex);
            imagesc(spd);
            title(sprintf('stabilizer:%2.2f; biasSize: %2.0fx%2.0f', stabilizerGray, biasSizeX, biasSizeY));
            set(gca, 'CLim', [0 maxSPD]);
            axis 'square'
            axis 'xy'
        end
    end
    
        
end
