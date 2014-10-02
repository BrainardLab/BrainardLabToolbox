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
        
 
    
    
    runParams
    stabilizerBorderWidth   = runParams.stabilizerBorderWidth;
    stabilizerGrayLevelNum  = numel(runParams.stabilizerGrays);
    sceneGrayLevelNum       = numel(runParams.sceneGrays);
    biasLevelNum            = numel(runParams.biasGrays);
    biasSizesNum            = size(runParams.biasSizes,1);
    gammaInputValuesNum     = numel(runParams.leftTargetGrays);
   
    
    % Load CIE 1931 CMFs
    load T_xyz1931
    vLambda1931_originalSampling = squeeze(T_xyz1931(2,:));
    desiredS = [380 1 401];
    
    printCalibrationFrames = false;
    
    
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
    
    fprintf('\nGamma input values (left) : ');
    fprintf('%2.3f ', runParams.leftTargetGrays);
    
    fprintf('\nGamma input values (right): ');
    fprintf('%2.3f ', runParams.rightTargetGrays);
    
    fprintf('\n\n');
    
    
    % Preallocate memory for spds
    leftSPD = zeros(stabilizerGrayLevelNum, ...
                    sceneGrayLevelNum, ...
                    biasLevelNum, ...
                    biasSizesNum, ...
                    gammaInputValuesNum, ...
                    desiredS(3));
           
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
        
        if (printCalibrationFrames)
            h0 = figure(99);
            set(h0, 'Position', [100 100 754 453]);
            imshow(conditionData.demoFrame);
            hold on;
            plot([1 size(conditionData.demoFrame,2) size(conditionData.demoFrame,2) 1 1], ...
                 [1 1 size(conditionData.demoFrame,1) size(conditionData.demoFrame,1)  1], 'k-');
            hold off;
            colormap(gray(256));
            set(gca, 'CLim', [0 1]);
            axis 'image'
            drawnow;

            % Print frame as pdf
            set(h0,'PaperOrientation','landscape');
            set(h0,'PaperUnits','normalized');
            set(h0,'PaperPosition', [0 0 1 1]);
            print(gcf, '-dpdf', sprintf('Cond_%d.pdf', condIndex));
        end
        
    
        if (condIndex == 1)
            nativeS = conditionData.leftS;
            vLambda = 683*SplineCmf(S_xyz1931, vLambda1931_originalSampling, desiredS);
            wave = SToWls(desiredS);
        end
        
        % get SPD data 
        spd = conditionData.leftSPD;
        % interpolate to desiredS
        spd = SplineSpd(nativeS, spd', desiredS);
        
        leftSPD(stabilizerGrayIndex, ...
                sceneGrayIndex, ...
                biasGrayIndex, ...
                biasSizeIndex, ...
                leftTargetGrayIndex, ...
                :) = spd;
        
        if ~isempty(conditionData.rightSPD)
            
            % get SPD data 
            spd = conditionData.rightSPD;
            % interpolate to desiredS
            spd = SplineSpd(nativeS, spd', desiredS);
        
            rightSPD(stabilizerGrayIndex, ...
                    sceneGrayIndex, ...
                    biasGrayIndex, ...
                    biasSizeIndex, ...
                    rightTargetGrayIndex, ...
                    :) = spd;
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
    
    
    gammaOutputLeft = zeros(stabilizerGrayLevelNum, biasSizesNum, gammaInputValuesNum);
    gammaOutputRight = zeros(stabilizerGrayLevelNum, biasSizesNum, gammaInputValuesNum);
    vLambda  = repmat(vLambda, [gammaInputValuesNum 1]);
    
    for stabilizerGrayIndex = 1:stabilizerGrayLevelNum
        for biasSizeIndex = 1: biasSizesNum
            spd = squeeze(leftSPD(stabilizerGrayIndex, ...
                        sceneGrayIndex, ...
                        biasGrayIndex, ...
                        biasSizeIndex, ...
                        1:gammaInputValuesNum, ...
                        :));
            luminance = sum(spd.*vLambda,2);
            gammaOutputLeft(stabilizerGrayIndex, biasSizeIndex, :) = luminance; 
        end
    end
    
    
    
    if ~isempty(rightSPD)
        for stabilizerGrayIndex = 1:stabilizerGrayLevelNum
            for biasSizeIndex = 1: biasSizesNum
                spd = squeeze(rightSPD(stabilizerGrayIndex, ...
                            sceneGrayIndex, ...
                            biasGrayIndex, ...
                            biasSizeIndex, ...
                            1:gammaInputValuesNum, ...
                            :));
                luminance = sum(spd.*vLambda,2);
                gammaOutputRight(stabilizerGrayIndex, biasSizeIndex, :) = luminance; 
            end
        end
    end
    
    

    gammaInputLeft  = runParams.leftTargetGrays;
    maxGammaOutputLeft = max(gammaOutputLeft(:));
    
    h1 = figure(1);
    figXo = 2560;
    figYo = 360;
    figWidth = 700;
    figHeight = 860;
    set(h1, 'Position', [figXo figYo figWidth figHeight]);
    clf;
    
    lineColors = lines(stabilizerGrayLevelNum*biasSizesNum);
    
    width = 0.85/(biasSizesNum+1);
    height = 0.7/(stabilizerGrayLevelNum+1);
    marginX = 0.02;
    marginY = 0.05;
    
	% First scan
    referenceBiasSizeIndex = 1;
    
    for stabilizerGrayIndex = 1:stabilizerGrayLevelNum
        
        stabilizerGray      = runParams.stabilizerGrays(stabilizerGrayIndex);
        referenceGammaCurve = squeeze(gammaOutputLeft(stabilizerGrayIndex, referenceBiasSizeIndex,:));
        referenceBiasSizeX  = runParams.biasSizes(referenceBiasSizeIndex,1);
        referenceBiasSizeY  = runParams.biasSizes(referenceBiasSizeIndex,2);
        
        legendMatrix = {};
        for biasSizeIndex = 1: biasSizesNum
            
            biasSizeX = runParams.biasSizes(biasSizeIndex, 1);
            biasSizeY = runParams.biasSizes(biasSizeIndex, 2);
        
            gammaCurve       = squeeze(gammaOutputLeft(stabilizerGrayIndex, biasSizeIndex, :));
            scalingFactor    = gammaCurve \ referenceGammaCurve;
            scaledGammaCurve = gammaCurve * scalingFactor;
            
            left = 3*marginX + (biasSizeIndex-1)*(width+marginX);
            bottom = 1-stabilizerGrayIndex*(height+marginY);
            subplot('Position', [left bottom width height]);   
            
            condIndex = (stabilizerGrayIndex-1)* biasSizesNum + biasSizeIndex;
            lineColor = lineColors(condIndex,:);
            
            plot(gammaInputLeft, gammaCurve, 'ks-', 'LineWidth', 3.0, 'MarkerSize', 8, 'MarkerFaceColor', [0.8 0.8 0.8], 'Color', lineColor);
            set(gca, 'FontName', 'Helvetica', 'FontSize', 8);
            grid on;
            box on
            
            set(gca, 'YLim', [0 maxGammaOutputLeft]);
            set(gca, 'XTick', [0:0.2:1.0], 'YTick', [0:100:1000]);
            
            if (biasSizeIndex == 1)
               ylabel('luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 10, 'FontWeight', 'bold');
               set(gca, 'YTickLabel', [0:100:1000]);
            else
               ylabel(''); 
               set(gca, 'YTickLabel', []);
            end
            xlabel('');
            
            title(sprintf('Stabilizer gray = %2.2f; \nBias WxH = %2.0fx%2.0f pxls.', stabilizerGray, biasSizeX, biasSizeY), 'FontName', 'Helvetica', 'FontSize', 8);
            
            % The scaled gamma curves for the CurrentStabilizerGray
            left = 3*marginX + biasSizesNum*(width+marginX);
            subplot('Position', [left bottom width height]);
            
            hold on;
            plot(gammaInputLeft, scaledGammaCurve, 'k-', 'LineWidth', 3.0, 'MarkerSize', 8, 'MarkerFaceColor', [0.8 0.8 0.8], 'Color', lineColors(condIndex,:));
            legendMatrix{biasSizeIndex} = sprintf('BiasWxH: %2.0fx%2.0f (scale: %2.2f)', biasSizeX, biasSizeY, 1.0/scalingFactor);     
        end
        
        xlabel('');
        ylabel('');
        set(gca, 'YTickLabel', []);
        set(gca, 'YLim', [0 maxGammaOutputLeft]);
        set(gca, 'XTick', [0:0.2:1.0], 'YTick', [0:100:1000]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 8);
        grid on;
        box on
            
        % legend and title
        legend_handle = legend(legendMatrix, 'FontName', 'Helvetica', 'FontSize', 6, 'Location', 'Best');
        set(legend_handle, 'Box', 'off')
        title(sprintf('Scaled gammas w/r to:\nBiasWxH = %2.2f x %2.2f pxls', referenceBiasSizeX, referenceBiasSizeY), 'FontName', 'Helvetica', 'FontSize', 8, 'BackgroundColor',[.99 .99 .48], 'EdgeColor', [0 0 0]);
    end
    
   
    % Second scan
    referenceStabilizerGrayIndex = 1;
    for biasSizeIndex = 1: biasSizesNum
        referenceGammaCurve = squeeze(gammaOutputLeft(referenceStabilizerGrayIndex, biasSizeIndex,:));
        referenceStabilizerGray  = runParams.stabilizerGrays(referenceStabilizerGrayIndex);
        
        legendMatrix = {};
        for stabilizerGrayIndex = 1:stabilizerGrayLevelNum
            stabilizerGray   = runParams.stabilizerGrays(stabilizerGrayIndex);
            gammaCurve       = squeeze(gammaOutputLeft(stabilizerGrayIndex, biasSizeIndex, :));
            scalingFactor    = gammaCurve \ referenceGammaCurve;
            scaledGammaCurve = gammaCurve * scalingFactor;
            
            left = 3*marginX + (biasSizeIndex-1)*(width+marginX);
            bottom = 1-(stabilizerGrayLevelNum+1)*(height+marginY);
            subplot('Position', [left bottom width height]);   
            
            condIndex = (stabilizerGrayIndex-1)* biasSizesNum + biasSizeIndex;
            lineColor = lineColors(condIndex,:);
            
            hold on;
            plot(gammaInputLeft, scaledGammaCurve, 'k-', 'LineWidth', 3.0, 'MarkerSize', 8, 'MarkerFaceColor', [0.8 0.8 0.8], 'Color', lineColors(condIndex,:));
            legendMatrix{stabilizerGrayIndex} = sprintf('Stabil. gray = %2.2f (scale: %2.2f)', stabilizerGray, 1.0/scalingFactor);
        end
        
        xlabel('settings value', 'FontName', 'Helvetica', 'FontSize', 10, 'FontWeight', 'bold');
        if (biasSizeIndex == 1)
               ylabel('luminance (cd/m2)', 'FontName', 'Helvetica', 'FontSize', 10, 'FontWeight', 'bold');
               set(gca, 'YTickLabel', [0:100:1000]);
        else
               ylabel(''); 
               set(gca, 'YTickLabel', []);
        end
            
        set(gca, 'YLim', [0 maxGammaOutputLeft]);
        set(gca, 'XTick', [0:0.2:1.0], 'YTick', [0:100:1000]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 8);
        grid on;
        box on
        
        % legend and title
        legend_handle = legend(legendMatrix, 'FontName', 'Helvetica', 'FontSize', 6, 'Location', 'Best');
        set(legend_handle, 'Box', 'off')
        title(sprintf('Scaled gammas w/r to:\nStabilizerGray = %2.2f', referenceStabilizerGray), 'FontName', 'Helvetica', 'FontSize', 8, 'BackgroundColor',[.99 .99 .48], 'EdgeColor', [0 0 0]);
    end % biasSizeIndex
    

    % Third scan (all curves)
    referenceGammaCurve = squeeze(gammaOutputLeft(referenceStabilizerGrayIndex, referenceBiasSizeIndex,:));
    referenceStabilizerGray   = runParams.stabilizerGrays(referenceStabilizerGrayIndex);
    referenceBiasSizeX = runParams.biasSizes(referenceBiasSizeIndex, 1);
    referenceBiasSizeY = runParams.biasSizes(referenceBiasSizeIndex, 2);
            
    condIndex = 0;
    legendMatrix = {};
    
    left = 3*marginX + biasSizesNum*(width+marginX);
    bottom = 1-(stabilizerGrayLevelNum+1)*(height+marginY);
    subplot('Position', [left bottom width height]);   
    hold on;
    
    for stabilizerGrayIndex = 1:stabilizerGrayLevelNum
        for biasSizeIndex = 1: biasSizesNum
            gammaCurve       = squeeze(gammaOutputLeft(stabilizerGrayIndex, biasSizeIndex, :));
            scalingFactor    = gammaCurve \ referenceGammaCurve;
            scaledGammaCurve = gammaCurve * scalingFactor;
            
            condIndex = (stabilizerGrayIndex-1)* biasSizesNum + biasSizeIndex;
            lineColor = lineColors(condIndex,:);
            plot(gammaInputLeft, scaledGammaCurve, 'k-', 'LineWidth', 3.0, 'MarkerSize', 8, 'MarkerFaceColor', [0.8 0.8 0.8], 'Color', lineColors(condIndex,:));
            legendMatrix{condIndex} = sprintf('scale: %2.2f', 1.0/scalingFactor);
        end       
    end % biasSizeIndex
    
    xlabel('settings value', 'FontName', 'Helvetica', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('');
    set(gca, 'YTickLabel', []);
    set(gca, 'YLim', [0 maxGammaOutputLeft]);
    set(gca, 'XTick', [0:0.2:1.0], 'YTick', [0:100:1000]);
    set(gca, 'FontName', 'Helvetica', 'FontSize', 8);
    grid on;
    box on
    
    % legend and title
    legend_handle = legend(legendMatrix, 'FontName', 'Helvetica', 'FontSize', 6, 'Location', 'NorthWest');
    set(legend_handle, 'Box', 'off')
    title(sprintf('Scaled gammas w/r to:\nStab.Gray=%2.2f, BiasWxH=%2.0fx%2.0f pxls.', referenceStabilizerGray, referenceBiasSizeX, referenceBiasSizeY), 'FontName', 'Helvetica', 'FontSize', 8, 'BackgroundColor',[.99 .99 .48], 'EdgeColor', [0 0 0]);

        
    
    % Print figure
    set(h1,'PaperOrientation','Portrait');
    set(h1,'PaperUnits','normalized');
    set(h1,'PaperPosition', [0 0 1 1]);
    print(gcf, '-dpdf', '-r600', 'Fig1.pdf');
        
    
     
    
end
