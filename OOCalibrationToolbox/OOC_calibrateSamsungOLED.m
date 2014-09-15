function OOC_calibrateSamsungOLED


    clear classes
    clc
    
    % Close all open ports
    IOPort('CloseAll')
    
    leftRadiometerOBJ   = [];
    rightRadiometerOBJ  = [];
    calibratorOBJ       = [];
    
    runMode = false;
    
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
        
        stabilizerGrays     = [0.0:0.25:1.0]; % [0.25 : 0.25 : 1.0];
        stabilizerTexts     = {'no stabilizer', 'low stabilizer', 'medium stabilizer', 'high stabilizer', 'max stabilizer'};
        sceneGrays          = [0.3 0.5 0.7]; % [0.2 0.5 0.8];
        sceneTexts          = {'low brightness scene', 'average brightness scene', 'high brightness scene'};
        biasGrays           = [0.9];
        
        samples = 12;
        sampleStep = 50;  % increase by 25 pixels
        biasSizes1(:,1)      = 100+(samples:-1:0)*sampleStep;
        biasSizes1(:,2)      = ones(samples+1,1)*300;
        
        biasSizes2(:,1)      = [ones(samples+1,1)*300 ];
        biasSizes2(:,2)      = [100+(samples:-1:0)*sampleStep];
        
        biasSizes3(:,1)      = [100+(samples:-1:0)*sampleStep];
        biasSizes3(:,2)      = [100+(samples:-1:0)*sampleStep];
        
        biasSizes = [biasSizes1; biasSizes2; biasSizes3];
        
        targetGrays = [0.0: 0.2: 1.0];
        
        cond = 0;
        for i = 1:numel(stabilizerGrays);
            stabilizerGray = stabilizerGrays(i); 
            stabilizerText = upper(stabilizerTexts{i});
            
            for j = 1:numel(sceneGrays)   
                sceneGray = sceneGrays(j);
                sceneText = upper(sceneTexts{j});
                
                for k = 1:numel(biasGrays)  
                    biasGray = biasGrays(k);
                    
                    for m = 1:size(biasSizes,1)
                        biasSize = biasSizes(m,:);

                        randomTargetIndex = randperm(numel(targetGrays));
                        for l = 1:numel(targetGrays)
                            
                            leftTargetGray  = targetGrays(randomTargetIndex(l));
                            rightTargetGray = targetGrays(randomTargetIndex(l));

                            tic
                            % Generate and display stimulus
                            demoFrame  = calibratorOBJ.generateStimulus(stabilizerGray, sceneGray, biasGray, biasSize, leftTargetGray, rightTargetGray);

                            % Update condition no
                            cond = cond + 1;

                            if (runMode)
                                % Measure SPD                         
                                if (1==2)
                                    % Sequential component measurements- slow
                                    leftRadiometerOBJ.measure();
                                    rightRadiometerOBJ.measure();

                                    % Store data
                                    leftSPD(cond,:)  = leftRadiometerOBJ.measurement.energy;
                                    rightSPD(cond,:) = rightRadiometerOBJ.measurement.energy;
                                else
                                    % Simultaneous measurements - faster

                                    % Start measurements
                                    leftRadiometerOBJ.triggerMeasure();
                                    rightRadiometerOBJ.triggerMeasure();

                                    % Read data from device
                                    leftResult  = leftRadiometerOBJ.getMeasuredData();
                                    rightResult = rightRadiometerOBJ.getMeasuredData();

                                    % Store data
                                    leftSPD(cond,:)  = leftResult;
                                    rightSPD(cond,:) = rightResult;
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
                        end
                    end
                end
            end
        end
        
        if (runMode)
            
            % Exit PTB and restore luts
            sca;
        
            % Save data
            save('calib1.mat', 'leftSPD', 'rightSPD');
        
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
        
        sca;
        rethrow(err);
    end
    
end
