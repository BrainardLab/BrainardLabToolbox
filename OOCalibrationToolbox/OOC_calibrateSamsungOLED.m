function OOC_calibrateSamsungOLED

    close all
    clear all
    clear classes
    clc
    
    % Close all open ports
    IOPort('CloseAll')
    
    leftRadiometerOBJ   = [];
    rightRadiometerOBJ  = [];
    calibratorOBJ       = [];
    
    runMode = true;     % True for collecting spectroradiometer data, false for video generation of the stimulus;
        
    runParams = struct(...
            'stabilizerGrays',      [0.0, 0.45, 0.9], ...         % modulation levels for stabilizing region
            'stabilizerTexts',      {{'no stabilizer', 'low stabilizer', 'medium stabilizer', 'high stabilizer', 'max stabilizer'}}, ...  % only relevant when runMode = false (demo)
            'sceneGrays',           [0.5], ...          % mean of the scene region
            'sceneTexts',           {{'low brightness scene', 'average brightness scene', 'high brightness scene'}}, ...   % only relevant when runMode = false (demo)
            'biasGrays',            [1.0], ...                  % modulation levels for bias region
            'biasSampleStep',       160, ...                     % step in pixels by which to change the bias region
            'biasHorizontalSamples',0, ...         
            'biasVerticalSamples',  0, ...
            'biasSquareSamples',    3, ...
            'biasSizes',            [], ...
            'targetGrays',          [0.0: 0.1: 1.0], ...        % The gamma input values
            'sceneIsDynamic',       false, ...                   % Flag indicating whether to generate new stochasic scene for each measurement
            'useTwinSpectroRadiometers', false ...              % Flag indicating whether to use two radiometers. If false we only use one.
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
        
        
        if (1==2)
            % Show target rects, so that we can center the radiometers
            leftTargetSize      = 100;
            rightTargetSize     = 100;
            leftTargetPos       = [1920/2-300 1080/2];
            rightTargetPos      = [1920/2+300 1080/2]; 

            calibratorOBJ.displayTargetRects(leftTargetSize, rightTargetSize, leftTargetPos, rightTargetPos);

            Speak('Pausing');
            pause(1.0);
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
                                'stabilizerGrayIndex',  stabilizerGrayIndex, ...
                                'sceneGrayIndex',       sceneGrayIndex, ...
                                'biasGrayIndex',        biasGrayIndex, ...
                                'biasSizeIndex',        biasSizeIndex, ...
                                'leftTargetGrayIndex',  leftTargetGrayIndex, ...
                                'rightTargetGrayIndex', rightTargetGrayIndex ...
                                );
                            
                            [ keyIsDown, seconds, keyCode ] = KbCheck;
                            if keyIsDown
                                if keyCode(escapeKey)
                                    ListenChar(0);
                                    sca;
                                    error('User aborted');
                                end
                            end
                
                            Speak(sprintf('%d of %d\n', cond+1, conditionsNum));
                            
                            [ keyIsDown, seconds, keyCode ] = KbCheck;
                            if keyIsDown
                                if keyCode(escapeKey)
                                    ListenChar(0);
                                    sca;
                                    error('User aborted');
                                end
                            end
                            
                            tic
                            % Generate and display stimulus
                            demoFrame  = calibratorOBJ.generateStimulus(stabilizerGray, sceneGray, biasGray, biasSize, leftTargetGray, rightTargetGray, runParams.sceneIsDynamic);

                            if (runMode) 
                                % Measure SPD   
                                if (runParams.useTwinSpectroRadiometers)
                                    % Simultaneous measurements - faster
                                    % Start measurements
                                    leftRadiometerOBJ.triggerMeasure();
                                    rightRadiometerOBJ.triggerMeasure();

                                    % Read data from device and store it
                                    runData.leftSPD  = leftRadiometerOBJ.getMeasuredData();
                                    runData.rightSPD = rightRadiometerOBJ.getMeasuredData();
                                else   
                                    % use only one radiometer
                                    leftRadiometerOBJ.measure();
                                 
                                    % Store data
                                    runData.leftSPD = leftRadiometerOBJ.measurement.energy;
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
            
            % Save data
            save('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/OOCalibrationToolbox/SamsungOLED_calib.mat', 'runParams', 'allCondsData');
        
            condNo = 1;
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
           % close video writer
           close(writerObj); 
        end
        
        
    catch err
        
        ListenChar(0);
        sca;
        rethrow(err);
    end
    
end
