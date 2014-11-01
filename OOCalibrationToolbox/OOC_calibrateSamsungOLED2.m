function OOC_calibrateSamsungOLED2

    close all
    clear all
    clear classes
    clc
    
    global calibrationDataSet
    
    % Close all open ports
    IOPort('CloseAll');
    
    leftRadiometerOBJ   = [];
    rightRadiometerOBJ  = [];
    calibratorOBJ       = [];
    
    % Data file where all data structs are appended
    calibrationFileName = '/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/OOCalibrationToolbox/SamsungOLED_CloudsCalib2.mat';
            
    % Load pre-computed calibration patterns
    fprintf('Loading stimuli. Please wait ...');
    stimulusFileName = 'PixelOLEDprobes2.mat';
    load(stimulusFileName);  %loads 'stimParams', 'stimuli'
    fprintf('Loaded all stimuli');
    
    runMode = true;     % True for collecting spectroradiometer data, false for video generation of the stimulus;
     
    targetSize = 100;
    useTwinSpectroRadiometers = true;
    
    % Targets
    leftTarget = struct(...
        'width', targetSize, ...
    	'height', targetSize, ...
    	'x0', 1920/2 + 200, ...
    	'y0', 1080/2+100);
    
    rightTarget = struct(...
        'width', targetSize, ...
    	'height', targetSize, ...
    	'x0', 1920/2 + 550, ...
    	'y0', 1080/2-100);
    
    
    % Generate dithering matrices
    % temporalDitheringMode = '10BitPlusNoise';
    % temporalDitheringMode = '10BitNoNoise';

    % 8 bit for LUT calibration
    temporalDitheringMode = '8Bit';
      
    % gamma curve sampling
    gammaSampling = [1.0];
       
    runParams = struct(...
            'temporalDitheringMode', temporalDitheringMode, ...
            'leftTarget',           leftTarget, ...
            'rightTarget',          rightTarget, ...
            'useTwinSpectroRadiometers', useTwinSpectroRadiometers, ...              % Flag indicating whether to use two radiometers. If false we only use one.
            'leftRadiometerID',     [], ...
            'rightRadiometerID',    [], ...
            'stimulusFileName',     stimulusFileName, ...
            'stimParams',           stimParams, ...
            'leftTargetGrays',      gammaSampling, ...       % The gamma input values for the left target
            'rightTargetGrays',     gammaSampling, ...
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
                'devicePortString', '/dev/cu.USA19QW1a2P1.1' ...      % empty -> automatic port detection
                );
            
            runParams.leftRadiometerID.model    = leftRadiometerOBJ.deviceModelName;
            runParams.leftRadiometerID.serialNo = leftRadiometerOBJ.deviceSerialNum;
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
                    'devicePortString',  '/dev/cu.USA19H3d1P1.1' ...   % empty -> automatic port detection
                    );
                runParams.rightRadiometerID.model    = rightRadiometerOBJ.deviceModelName;
                runParams.rightRadiometerID.serialNo = rightRadiometerOBJ.deviceSerialNum;
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
         
        
        if (runMode)
            % Present stimulus for aligning the radiometers.
            leftTargetGray  = 0.5;
            rightTargetGray = 0.5;

            exponentOfOneOverFIndex = 1;
            oriBiasIndex      = 1;
            orientationIndex  = 1;
            patternIndex        = 1;
            
            stimulationPattern = double(squeeze(stimuli(exponentOfOneOverFIndex, oriBiasIndex,orientationIndex, patternIndex,:,:)))/255.0;

            demoFrame  = calibratorOBJ.generateArbitraryStimulus(...
                                                runParams.temporalDitheringMode, ...
                                                runParams.leftTarget, ...
                                                runParams.rightTarget, ...
                                                leftTargetGray, ...
                                                rightTargetGray, ...
                                                stimulationPattern ...
                                    );
                      
            Speak('Align radiometers on targets. Hit enter to continue, or ESCAPE to exit.'); 
            keyIsDown = false;
            while ~keyIsDown
                [ keyIsDown, seconds, keyCode ] = KbCheck;
                any(keyCode)
                pause(0.1);
            end
            if keyCode(escapeKey)
                ListenChar(0);
                sca;
                disp('User aborted');
                return;
            end

            Speak('Pausing for 2 seconds. Leave the room now');
            pause(2.0);
        end
        
 
        % Start the calibration sequence
        allCondsData = {};
        presentedStimuli = 0;
        totalStimuli = size(stimuli,1)*size(stimuli,2)*size(stimuli,3)*size(stimuli,4);
    
        
        for exponentOfOneOverFIndex = 1:numel(stimParams.exponentOfOneOverFArray)
            for oriBiasIndex = 1:numel(stimParams.oriBiasArray)
                for orientationIndex = 1:numel(stimParams.orientationsArray)
                    sequence = squeeze(stimuli(exponentOfOneOverFIndex, oriBiasIndex,orientationIndex, :,:,:));
                    
                    visited = zeros(1,size(sequence,1));
                    
                    % Randomize frame index
                    randomFrameIndices = randperm(8);
                
                    for k = 1:numel(randomFrameIndices);
                        randomFrameIndex = randomFrameIndices(k);
                        % Randomize condition index
                        randomConditionIndices = randperm(9);
                        
                        for l = 1:numel(randomConditionIndices)
                            randomConditionIndex = randomConditionIndices(l);
                            
                            for polarity = 1:2
                                if (polarity == 1)
                                    kk = (randomFrameIndex-1)*9*2 + randomConditionIndex;
                                else
                                    kk = (randomFrameIndex-1)*9*2 + randomConditionIndex + 9;
                                end
                            
                                visited(kk) = visited(kk) + 1;
                                
                                stimulationPattern = double(squeeze(sequence(kk,:,:)))/255.0;
                                presentedStimuli = presentedStimuli + 1;
                                
                                if (mod(presentedStimuli, 20) == 0)
                                    Speak(sprintf('%d of %d', presentedStimuli, totalStimuli));
                                end
                        
                                
                                for targetGrayIndex = 1: numel(runParams.leftTargetGrays)
                                    leftTargetGray  = runParams.leftTargetGrays(targetGrayIndex);
                                    rightTargetGray = runParams.rightTargetGrays(targetGrayIndex);

                                    runData = struct( ...
                                        'leftSPD',              [], ...
                                        'rightSPD',             [], ...
                                        'leftS',                [], ...
                                        'rightS',               [], ...
                                        'exponentOfOneOverFIndex',  exponentOfOneOverFIndex, ...
                                        'oriBiasIndex',       oriBiasIndex, ...
                                        'orientationIndex',   orientationIndex, ...
                                        'frameIndex',        randomFrameIndex, ...
                                        'conditionIndex',        randomConditionIndex, ...
                                        'polarity',           polarity, ...
                                        'leftTargetGrayIndex',  targetGrayIndex, ...
                                        'rightTargetGrayIndex', targetGrayIndex ...
                                        );
                        
                                    demoFrame  = calibratorOBJ.generateArbitraryStimulus(...
                                                    runParams.temporalDitheringMode, ...
                                                    runParams.leftTarget, ...
                                                    runParams.rightTarget, ...
                                                    leftTargetGray, ...
                                                    rightTargetGray, ...
                                                    stimulationPattern ...
                                        );
                            
                                    runData.demoFrame = uint8(squeeze(demoFrame(:,:,1))*255.0);


                                    if (runMode)  

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
                                        frame = getframe;
                                        writeVideo(writerObj,frame);
                                    end % runMode


                                    % Store data for this condition
                                    allCondsData{exponentOfOneOverFIndex, ...
                                                oriBiasIndex, ...
                                                orientationIndex, ...
                                                randomFrameIndex, ...
                                                randomConditionIndex, ...
                                                polarity, ...
                                                targetGrayIndex} = runData;

                                end  % target GrayIndex
                            end % polarity
                        end % for l = 1:numel(randomConditionIndices)
                    end % for k = 1:numel(randomFrameIndices);
                    
                    if (any(visited ~= 1))
                        Visited
                        error('Visited is not correct');
                    end
                end  % orientationIndex
            end % oriBiasIndex
        end % exponentIndex
    
        
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
            resultString = sprintf('\nSaved current run data to ''%s'' as %s.\n', calibrationFileName, calParamName);
            disp(resultString);

            setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
            setpref('Internet', 'E_Mail', 'cottaris@sas.upenn.edu');
            sendmail('cottaris@sas.upenn.edu', 'Samsung OLED calibration run finished !', resultString);
        
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
