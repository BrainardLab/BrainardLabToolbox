function OOC_calibrateSamsungOLED

    close all
    clear all
    clear classes
    clc
    
    % Close all open ports
    IOPort('CloseAll');
    
    leftRadiometerOBJ   = [];
    rightRadiometerOBJ  = [];
    calibratorOBJ       = [];
    
    % Data file where all data structs are appended
    calibrationFileName = '/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/OOCalibrationToolbox/SamsungOLED_calib.mat';
            
            
    runMode = false; %true;     % True for collecting spectroradiometer data, false for video generation of the stimulus;
     
    % Targets
    leftTarget = struct(...
        'width', 100, ...
    	'height', 100, ...
    	'x0', 1920/2 + 200, ...
    	'y0', 1080/2);
    
    rightTarget = struct(...
        'width', 100, ...
    	'height', 100, ...
    	'x0', 1920/2 + 600, ...
    	'y0', 1080/2+250);
    
    
    % No effect with these, but re-run them
    stabilizerBorderWidth = 0;
    biasSampleStep = 160;
    
    % No effect with these, but re-run them
    stabilizerBorderWidth = 300;
    biasSampleStep = 160;
    
    %stabilizerBorderWidth = 250;
    %biasSampleStep = 100;
    
    runParams = struct(...
            'leftTarget',           leftTarget, ...
            'rightTarget',          rightTarget, ...
            'stabilizerBorderWidth', stabilizerBorderWidth, ...                     % width of the stabilizer region in pixels,
            'stabilizerGrays',      [0.0 0.33 0.66 0.99], ...         % modulation levels for stabilizing region
            'stabilizerTexts',      {{'no stabilizer', 'low stabilizer', 'medium stabilizer', 'high stabilizer', 'max stabilizer'}}, ...  % only relevant when runMode = false (demo)
            'sceneGrays',           [0.0], ...          % mean of the scene region
            'sceneTexts',           {{'low brightness scene', 'average brightness scene', 'high brightness scene'}}, ...   % only relevant when runMode = false (demo)
            'biasGrays',            [1.0], ...                  % modulation levels for bias region
            'biasSampleStep',       biasSampleStep, ...                     % step in pixels by which to change the bias region
            'biasHorizontalSamples',0, ...         
            'biasVerticalSamples',  0, ...
            'biasSquareSamples',    2, ...
            'biasSizes',            [], ...
            'targetGrays',          [0.0: 0.1: 1.0], ... % [0.0: 0.1: 1.0], ...        % The gamma input values
            'sceneIsDynamic',       false, ...                   % Flag indicating whether to generate new stochasic scene for each measurement
            'useTwinSpectroRadiometers', false, ...              % Flag indicating whether to use two radiometers. If false we only use one.
            'datePerformed',        datestr(now) ...
        );
        
       
    KbName('UnifyKeyNames');
    escapeKey = KbName('ESCAPE');
    ListenChar(2);
    while KbCheck; end
    
    try
        if (runMode)
            % Instantiate the left Radiometer object, here a PR650obj.
            leftRadiometerOBJ = PR650dev(...
                'verbosity',        1, ...                           % 1 -> minimum verbosity
                'devicePortString', '/dev/cu.USA19QW3d1P1.1' ...      % empty -> automatic port detection
                );

            fprintf('\nLeft Radiometer: %s with serial no:%s\n', leftRadiometerOBJ.deviceModelName, leftRadiometerOBJ.deviceSerialNum);

            % Set various PR-650 specific optional parameters
            leftRadiometerOBJ.setOptions(...
                'syncMode',     'OFF', ...
                'verbosity',     1 ...
            );

            if (runParams.useTwinSpectroRadiometers)
                % Instantiate the right Radiometer object, here a PR650obj.
                rightRadiometerOBJ = PR650dev(...
                    'verbosity',        1, ...                          % 1 -> minimum verbosity
                    'devicePortString',  '/dev/cu.USA19H1a2P1.1' ...   % empty -> automatic port detection
                    );
                fprintf('\nRight Radiometer: %s with serial no:%s\n', rightRadiometerOBJ.deviceModelName, rightRadiometerOBJ.deviceSerialNum);

                % Set various PR-650 specific optional parameters
                rightRadiometerOBJ.setOptions(...
                    'syncMode',     'OFF', ...
                    'verbosity',     1 ...
                );
            end

            % Instantiate @Calibrator object
            calibratorOBJ = SamsungOLEDCalibrator(...
                'executiveScriptName',   mfilename, ...                         % name of the executive script (this file)
                'leftRadiometerOBJ',     leftRadiometerOBJ, ...
                'rightRadiometerOBJ',    rightRadiometerOBJ, ...
                'calibrationFile',       'SamsungOLED_240Hz_10bit', ...         % name of file on which the calibration data will be saved
                'displayTemporalDither', 4, ...                                 % 240 Hz: 4 frame interlace for 10 - bit resolution
                'comment',               'test' ...
                );
        else
           % demoMode
           % Start calibratorOBJ in demo mode
           calibratorOBJ = SamsungOLEDCalibrator();
           % start a video writer
           writerObj = VideoWriter('calibration.mp4', 'MPEG-4'); 
           writerObj.FrameRate = 30;
           writerObj.Quality = 100;
           open(writerObj);
        end
        
        
        
        if (runParams.biasHorizontalSamples > 0)
            % horizontally-enlarged bias region
            biasSizes1(:,1)      = 100+(runParams.biaHorizontalSamples:-1:0)*runParams.biasSampleStep;
            biasSizes1(:,2)      = ones(runParams.biaHorizontalSamples+1,1)*300;
            runParams.biasSizes  = [runParams.biasSizes; biasSizes1];
        end
        
        if (runParams.biasVerticalSamples > 0)
            % vertically-enlarged bias region
            biasSizes2(:,1)      = (ones(runParams.biasVerticalSamples+1,1)*300);
            biasSizes2(:,2)      = (100+(runParams.biasVerticalSamples:-1:0)*runParams.biasSampleStep);
            runParams.biasSizes  = [runParams.biasSizes; biasSizes2];
        end
        
        if (runParams.biasSquareSamples > 0)
            % squarely-enlarged bias region
            biasSizes3(:,1)      = 100+(runParams.biasSquareSamples:-1:0)*runParams.biasSampleStep;
            biasSizes3(:,2)      = biasSizes3(:,1);
            runParams.biasSizes  = [runParams.biasSizes; biasSizes3];
        end
        
        
        conditionsNum = numel(runParams.stabilizerGrays);
        conditionsNum = conditionsNum * numel(runParams.sceneGrays);
        conditionsNum = conditionsNum * numel(runParams.biasGrays);
        conditionsNum = conditionsNum * size(runParams.biasSizes,1);
        conditionsNum = conditionsNum * numel(runParams.targetGrays);
        fprintf('Conditions num to be tested: %d\n', conditionsNum);
        
        
        cond = 0;
        allCondsData = {};
        
        stabilizerGrayIndices = randperm(numel(runParams.stabilizerGrays));
        for i = 1:numel(runParams.stabilizerGrays);
            
            stabilizerGrayIndex = stabilizerGrayIndices(i);
            stabilizerGray = runParams.stabilizerGrays(stabilizerGrayIndex); 
            stabilizerText = upper(runParams.stabilizerTexts{stabilizerGrayIndex});
            
            sceneGrayIndices = randperm(numel(runParams.sceneGrays));
            for j = 1:numel(sceneGrayIndices)  
                
                sceneGrayIndex = sceneGrayIndices(j);
                sceneGray = runParams.sceneGrays(sceneGrayIndex);
                sceneText = upper(runParams.sceneTexts{sceneGrayIndex});
                
                biasGrayIndices = randperm(numel(runParams.biasGrays)); 
                for k = 1:numel(biasGrayIndices)  
                    biasGrayIndex = biasGrayIndices(k);
                    biasGray = runParams.biasGrays(biasGrayIndex);
                    
                    randomBiasSizeIndices = randperm(size(runParams.biasSizes,1));
                    for m = 1:numel(randomBiasSizeIndices)
                        
                        biasSizeIndex = randomBiasSizeIndices(m);
                        biasSize = runParams.biasSizes(biasSizeIndex,:);

                        % randomly access all targetGrays (gamma in values)
                        randomLeftTargetIndices  = randperm(numel(runParams.targetGrays));
                        randomRightTargetIndices = randperm(numel(runParams.targetGrays));
                        
                        for l = 1:numel(randomLeftTargetIndices)
                            
                            leftTargetGrayIndex  = randomLeftTargetIndices(l);
                            rightTargetGrayIndex = randomRightTargetIndices(l);
                            
                            leftTargetGray  = runParams.targetGrays(leftTargetGrayIndex);
                            rightTargetGray = runParams.targetGrays(rightTargetGrayIndex);
 
                            runData = struct( ...
                                'leftSPD',              [], ...
                                'rightSPD',             [], ...
                                'leftS',                [], ...
                                'rightS',               [], ...
                                'stabilizerGrayIndex',  stabilizerGrayIndex, ...
                                'sceneGrayIndex',       sceneGrayIndex, ...
                                'biasGrayIndex',        biasGrayIndex, ...
                                'biasSizeIndex',        biasSizeIndex, ...
                                'leftTargetGrayIndex',  leftTargetGrayIndex, ...
                                'rightTargetGrayIndex', rightTargetGrayIndex ...
                                );
                                
                            tic
                            % Generate and display stimulus
                            demoFrame  = calibratorOBJ.generateStimulus(...
                                            runParams.leftTarget, ...
                                            runParams.rightTarget, ...
                                            runParams.stabilizerBorderWidth, ...
                                            stabilizerGray, ...
                                            sceneGray, ...
                                            biasGray, ...
                                            biasSize, ...
                                            leftTargetGray, ...
                                            rightTargetGray, ...
                                            runParams.sceneIsDynamic...
                                );
                            
                            % Save stimulus at 1/4 resolution
                            runData.demoFrame = single(demoFrame(1:2:end, 1:2:end,:));

                            if (runMode) 
                                
                                Speak(sprintf('%d of %d\n', cond+1, conditionsNum));

                                [ keyIsDown, seconds, keyCode ] = KbCheck;
                                if keyIsDown
                                    if keyCode(escapeKey)
                                        ListenChar(0);
                                        sca;
                                        error('User aborted');
                                    end
                                end
                            
                                % Measure SPD   
                                if (runParams.useTwinSpectroRadiometers)
                                    % Simultaneous measurements - faster
                                    % Start measurements
                                    leftRadiometerOBJ.triggerMeasure();
                                    rightRadiometerOBJ.triggerMeasure();

                                    % Read data from device and store it
                                    runData.leftSPD  = leftRadiometerOBJ.getMeasuredData();
                                    runData.rightSPD = rightRadiometerOBJ.getMeasuredData();
                                    runData.leftS    = leftRadiometerOBJ.nativeS;
                                    runData.rightS   = rightRadiometerOBJ.nativeS;
                                else   
                                    % use only one radiometer
                                    leftRadiometerOBJ.measure();
                                 
                                    % Store data
                                    runData.leftSPD = leftRadiometerOBJ.measurement.energy;
                                    runData.leftS   = leftRadiometerOBJ.nativeS;
                                    
                                    if ((isempty(runData.leftSPD)) || (isempty(runData.leftS)))
                                        runData.leftSPD
                                        runData.leftS 
                                       error('Radiometer object returned empty values'); 
                                    end
                                end
                            else
                                % in demo mode, so just add frame to video writer
                                figure(1);
                                imshow(demoFrame(1:2:end, 1:2:end,:));
                                text(50/2, 60/2, stabilizerText, 'FontName', 'System', 'FontSize', 26, 'FontWeight', 'bold', 'Color', 'Red');
                                text(50/2, 130/2, sceneText, 'FontName', 'System', 'FontSize', 26, 'FontWeight', 'bold', 'Color', 'Blue');
                                frame = getframe;
                                writeVideo(writerObj,frame);
                            end % runMode
                            toc
                            
                            % Update condition no
                            cond = cond + 1;
                            
                            % Store data for this condition
                            allCondsData{cond} = runData;
                        end
                    end
                end
            end
        end
        
        if (runMode)
            % Exit PTB and restore luts
            sca;
            ListenChar(0);
            
            % Saved data struct
            calibrationDataSet.runParams = runParams;
            calibrationDataSet.allCondsData = allCondsData;
        
            
            % Create a MAT-file object that supports partial loading and saving.
            matOBJ = matfile(calibrationFileName, 'Writable', true);
            % get current variables
            varList = who(matOBJ);
            
            % add new variable with new validation data
            calParamName = sprintf('calibrationRun_%05d', length(varList)+1);
            eval(sprintf('matOBJ.%s = calibrationDataSet;', calParamName)); 
            fprintf('\nSaved current validation data data to ''%s'' as %s.\n', calibrationFileName, calParamName);
        
        
            % Display something
            condNo = numel(allCondsData);
            leftSPD = allCondsData{condNo}.leftSPD;
            rightSPD = allCondsData{condNo}.rightSPD;
            
            % Plot data
            size(leftSPD)
            size(rightSPD)

            figure(1);
            clf
            subplot(1,2,1);
            plot(leftSPD','r.-');

            subplot(1,2,2);
            plot(rightSPD','b.-');
        else
            ListenChar(0);
           % close video writer
           close(writerObj); 
        end
        
        
    catch err
        
        ListenChar(0);
        sca;
        rethrow(err);
    end
    
end
