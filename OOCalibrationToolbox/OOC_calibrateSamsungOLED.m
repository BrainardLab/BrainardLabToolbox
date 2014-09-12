function OOC_calibrateSamsungOLED


    clear classes
    clc
    
    % Close all open ports
    IOPort('CloseAll')
    
    leftRadiometerOBJ   = [];
    rightRadiometerOBJ  = [];
    calibratorOBJ       = [];
    
    try
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
        
        stabilizerGrays     = [0.25 0.75]; % [0.25 : 0.25 : 1.0];
        bkgndGrays          = [0.5]; % [0.2 0.5 0.8];
        biasGrays           = [1.0];
        targetGrays         = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0];
        biasOris            = [0 90];
        
        cond = 0;
        for i = 1:numel(stabilizerGrays);
            stabilizerGray = stabilizerGrays(i); 
            
            for j = 1:numel(bkgndGrays)   
                bkgndGray = bkgndGrays(j);
                
                for k = 1:numel(biasGrays)  
                    biasGray = biasGrays(k);
                    
                    for l = 1:numel(targetGrays)
                        leftTargetGray  = targetGrays(l);
                        rightTargetGray  = targetGrays(l);
                        
                        for m = 1:numel(biasOris)
                            biasOri = biasOris(m);
                            
                            tic
                            % Generate and display stimulus
                            calibratorOBJ.generateStimulus(stabilizerGray, bkgndGray, biasGray, leftTargetGray, rightTargetGray, biasOri);
                            
                            % Update condition no
                            cond = cond + 1;
                            
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
                            
                            toc
                        end
                        
                    end
                end
            end
        end
        
        
        sca;
        
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
        
        
    catch err
        
        sca;
        rethrow(err);
    end
    
end
