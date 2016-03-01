function windowsClient()
    global CRS;
    global experimentMode
    
    experimentMode = false;
    
    [rootDir, ~] = fileparts(fullfile(which(mfilename)));
    cd(rootDir); 
    addpath('../Common');
    addpath(genpath('C:\Users\melanopsin\Documents\MATLAB\Toolboxes\BrainardLabToolbox\Classes'));
    
    clc
    fprintf('\nStarting windows client\n');
    
    udpParams = getUDPparams();
    
    % === NEW ======  Instantiate a OLVSGcommunicator object ==============
    VSGOL = OLVSGcommunicator( ...
        'signature', 'WindowsSide', ...          % a label indicating the host, used to for user-feedback
          'localIP', udpParams.winHostIP, ...    % required: the IP of this computer
         'remoteIP', udpParams.macHostIP, ...    % required: the IP of the computer we want to conenct to
          'udpPort', udpParams.udpPort, ...      % optional, with default value: 2007
        'verbosity', 'min' ...                   % optional, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        );
    
    % Set valid values for comnunication param: USER_READY_STATUS
    VSGOL.setValidValuesForParam(VSGOL.USER_READY_STATUS, ...
          {...
            'user ready to move on',...
            'continue', ...
            'abort' ...
          } ...
    );
        
    % Set valid values for comnunication param: EYE_TRACKER_STATUS
    VSGOL.setValidValuesForParam(VSGOL.EYE_TRACKER_STATUS, ...
          {...
            'startEyeTrackerCheck', ...
            'isTracking', ...
            'isNotTracking', ...
            'startTracking', ...
            'stopTracking' ...
          }...
    );
    % === NEW ======  Instantiate a OLVSGcommunicator object ==============
    
    
    maxAttempts = 2;
    
    if (experimentMode)
        % Ask for observer
        fprintf('\n*********************************************');
        fprintf('\n*********************************************\n');
        saveDropbox = GetWithDefault('Save into Dropbox folder?', 1);
        
        % Create a VSGCALIBRATE mode to make test runs of the programmer quicker.
        VSGCALIBRATE = false;
        
        nSecsToSave = 5;

        % Initializing Cambridge Researsh System and Other Neccessary Variables
        % Global CRS gives us access to a cell structure of the Video Eye Tracker's
        % variables.  Load constants creates this cell structure
        if isempty(CRS)
            crsLoadConstants;
        end

        % vetClearDataBuffer clears values that may have been previously recorded
        vetClearDataBuffer;

        % vetLoadCalibrationFile loads a calibration file that was created using the
        % provided CRS application called Video Eye Trace.  This calibration file
        % correlates a subject's pupil position with a focal point in visual space.
        % The .scf file is needed in order for the Eye tracker to intialize and
        % function properly.
        calFilePath = 'C:\Users\brainard_lab\Documents\MATLAB\Experiments\VSGEyeTrackerPupillometry\subjectcalibration_current.scf';
        vetLoadCalibrationFile(calFilePath);

        % The way CRS setup the Eye Tracker, we must set a stimulus device, although
        % in reality, our stimulus device is the OneLight machine. For the sake of
        % initialization, we must tell the Video Eye Tracker that the stimulus will
        % be presented on a screen connected through a VGA port.
        vetSetStimulusDevice(CRS.deVGA);

        % vetSelectVideoSource prepares the framegrabber (PICOLO card) to receive
        % data from a connected video eye tracker.  Our model of the eye tracker is
        % labeled as the .vsCamera (a CRS convention/nomenclature)
        if vetSelectVideoSource(CRS.vsCamera) < 0
            error('*** Video source not selected.');
        end
    end % experimentMode
    
    % Receiving initial information from Mac
    fprintf('*** Waiting for Mac to tell us to go\n');
    fprintf('*** Run OLFlickerSensitivity on Mac and select protocol...\n');
    
    % Main Experiment Loop
    
    % === NEW ====== Get param values for labeled param names ==================
    protocolNameStr = VSGOL.receiveParamValue(VSGOL.PROTOCOL_NAME,       'timeOutSecs', Inf)
    obsID           = VSGOL.receiveParamValue(VSGOL.OBSERVER_ID,         'timeOutSecs', 2)
    obsIDAndRun     = VSGOL.receiveParamValue(VSGOL.OBSERVER_ID_AND_RUN, 'timeOutSecs', 2)
    % === NEW ====== Get param values for labeled param names ==================
    
    
    
    if (experimentMode)
        % Ask if we want to save in Dropbox
        if saveDropbox
            dropboxPath = 'C:\Users\brainard_lab\Dropbox (Aguirre-Brainard Lab)\MELA_data';
            savePath = fullfile(dropboxPath, protocolNameStr, obsID, obsIDAndRun);
        else
            expPath = fileparts(mfilename('OLFlickerSensitivityVSGPupillometry.m'));
            savePath = fullfile(expPath,  protocolNameStr, obsID, obsIDAndRun);
        end
        if ~isdir(savePath)
            mkdir(savePath);
        end
    end % experimentMode
    
    
    % === NEW ====== Get param values for labeled param names ==================
    nTrials         = VSGOL.receiveParamValue(VSGOL.NUMBER_OF_TRIALS,  'timeOutSecs', 2)
    startTrialNum   = VSGOL.receiveParamValue(VSGOL.STARTING_TRIAL_NO, 'timeOutSecs', 2)
    offline         = VSGOL.receiveParamValue(VSGOL.OFFLINE,           'timeOutSecs', 2)
    % === NEW ====== Get param values for labeled param names ==================
    
    
    if (experimentMode)
        if (offline)
            % Figure out paths.

            % Set up the file name of the output file
            saveFile = fullfile(savePath, obsIDAndRun);

            %error('offline mode not implemented at this time.  There is unfinished offline code present in this state of the routine.  This error will be removed once the offline code is completed at a future time.');
        end
    end % experimentMode
    

    
    % Loop over trials
    for i = startTrialNum:nTrials
        % Initializating variables
        params.run = false;
    
        if (experimentMode)
            % Clear the buffer
            vetClearDataBuffer;
    
            % Stop the tracking in case it is still running
            vetStopTracking;
        end
        
        % Debug
        %params.run = true;
        
        % Check if we are ready to run
        checkCounter = 0;
        while (params.run == false)
            checkCounter = checkCounter + 1;
            
            %userReady = VSGOLGetInput;
            % === NEW ====== Wait for ever to receive the userReady status ==================
            userReady = VSGOL.receiveParamValue(VSGOL.USER_READY_STATUS,  ...
                'timeOutSecs', Inf, 'consoleMessage', 'Is user ready?');
            % === NEW ====== Wait for ever to receive the userReady status ==================

            fprintf('>>> Check %g\n', checkCounter);
            fprintf('>>> User ready? %s \n', userReady);
            
            
            if checkCounter <= maxAttempts
                % matlabUDP('send','continue');
                % ==== NEW ===  Send user ready status ========================
                VSGOL.sendParamValue({VSGOL.USER_READY_STATUS, 'continue'}, 'timeOutSecs', 2);
                % =============================================================
 
                params = VSGOLEyeTrackerCheck(VSGOL, params);
            else
                % matlabUDP('send','abort');
                % ==== NEW ===  Send user ready status ========================
                VSGOL.sendParamValue({VSGOL.USER_READY_STATUS, 'abort'}, 'timeOutSecs', 2);
                % =============================================================
 
                
                fprintf('>>> Could not acquire good tracking after %g attempts.\n', maxAttempts);
                fprintf('>>> Saving %g seconds of diagnostic video on the hard drive.\n', nSecsToSave);
                if (experimentMode)
                    vetStartTracking;
                    vetStartRecordingToFile(fullfile([saveFile '_' num2str(i, '%03.f') '_diagnostics.cam']));
                    pause(nSecsToSave);
                    vetStopRecording;
                    vetStopTracking;
                end
                
                abortExperiment = true;
                params.run = true;
            end
        end % while params.run
        
        %if abortExperiment
        %   break; 
        %end
    
        if (experimentMode)
            % Stop the tracking
            vetStopTracking;
            %WaitSecs(1);
    
            % Start the tracking
            vetStartTracking;
            %WaitSecs(1);
        end

              
         % Get the 'Go' signal
%         goCommand = VSGOLReceiveEyeTrackerCommand;
%         while (goCommand  ~= true)
%             fprintf('>>> The go signal is %d',goCommand);
%             goCommand = VSGOLReceiveEyeTrackerCommand;
%         end
    
        % === NEW ====== Wait for ever to receive the StartTracking signal ==================
        goCommand = VSGOL.receiveParamValue(VSGOL.EYE_TRACKER_STATUS,  ...
            'timeOutSecs', Inf, 'consoleMessage', 'Is there a start tracking request?');
        if (~strcmp(goCommand, 'startTracking'))
            error('Expected ''startTracking'', received: ''%s'' .', checkStop);
        end
        % === NEW ====== Wait for ever to receive the START signal ==================
            
        

        if offline
            %vetStartRecordingToFile([saveFile '-' num2str(i) '.cam']);
        end
       
                
        % Check the 'stop' signal from the Mac
%         checkStop = 'no_stop';
%         while (~strcmp(checkStop,'stop'))
%             checkStop = VSGOLGetInput;
%             if strcmp(checkStop,'stop')
%                 matlabUDP('send',sprintf('Trial %f has ended!\n', i));
%             end
%         end
    

        % ---------- The next 2 go together
        
        % === NEW ====== Wait for ever to receive the StopTracking signal ==================
        checkStop = VSGOL.receiveParamValue(VSGOL.EYE_TRACKER_STATUS,  ...
            'timeOutSecs', Inf, 'consoleMessage', 'Is there a stop tracking request?');
        if (~strcmp(checkStop, 'stopTracking'))
            error('Expected ''stopTracking'', received: ''%s'' .', checkStop);
        end
        % === NEW ====== Wait for ever to receive the StopTracking signal ==================
        
        
        %matlabUDP('send',sprintf('Trial %f has ended!\n', i));

        % === NEW ====== Send the trial outcome ===========================
        VSGOL.sendParamValue({VSGOL.TRIAL_OUTCOME, sprintf('Trial %f has ended!\n', i)}, ...
                'timeOutSecs', 2, 'maxAttemptsNum', 1, ...
                'consoleMessage', 'Sending the trial outcome');
        % === NEW ====== Send the trial outcome ===========================
        
        % ---------- The above 2 go together
        
    
        if (experimentMode)
            % Get all data from the buffer
            pupilData = vetGetBufferedEyePositions;
    
            if offline
                % Stop the tracking
                vetStopRecording;
            end
    
            % Stop tracking
            vetStopTracking;
            %vetDestroyCameraScreen; ??? Needed?
        end
        
        % Get the transfer data
        goodCounter = 1;
        badCounter = 1;
        clear transferData;
        
        if (experimentMode)
            for jj = 1 : length(pupilData.timeStamps)
                if ((pupilData.tracked(jj) == 1)) %&& VSGOLIsWithinBounds(radius, origin, pupilData.mmPositions(jj,:)))
                    % Save the pupil diameter and time stamp for good data
                    % Keep data for checking plot
                    goodPupilDiameter(goodCounter) = pupilData.pupilDiameter(jj);
                    goodPupilTimeStamps(goodCounter) = pupilData.timeStamps(jj);

                    %Save the data as strings to send to the Mac
                    tempData = [num2str(goodPupilDiameter(goodCounter)) ' ' num2str(goodPupilTimeStamps(goodCounter)) ' 0 ' '0'];
                    transferData{jj} = tempData;

                    goodCounter = goodCounter + 1;
                else
                    % Save the time stamp for bad data
                    % Keep data for checking plot
                    badPupilTimeStamps(badCounter) = pupilData.timeStamps(jj);

                    %Send the timestamps of the interruptions
                    tempData = ['0' ' 0 ' '1 ' num2str(badPupilTimeStamps(badCounter))];
                    transferData{jj} = tempData;

                    badCounter = badCounter + 1;
                end
            end
        else
            transferData = [];
        end
        
        % Start the file transfer
        macCommand = 'fubar';
        numDataPoints = length(transferData);
        clear diameter;
        clear time;
        clear time_inter;
        
        if offline
            good_counter = 0;
            interruption_counter = 0;

            % Iterate over the data points
            for j = 1:numDataPoints
                parsedline = allwords(transferData{j}, ' ');
                diam = str2double(parsedline{1});
                ti = str2double(parsedline{2});
                isinterruption = str2double(parsedline{3});
                interrupttime = str2double(parsedline{4});
                if (isinterruption == 0)
                    good_counter = good_counter+1;
                    diameter(good_counter) = diam;
                    time(good_counter) = ti;
                elseif (isinterruption == 1)
                    interruption_counter = interruption_counter + 1;
                    time_inter(interruption_counter) = interrupttime;
                end
            end
            if ~exist('diameter', 'var')
                diameter = [];
            end

            if ~exist('time', 'var')
                time = [];
            end

            if ~exist('time_inter', 'var')
                time_inter = [];
            end

            %average_diameter = mean(diameter)*ones(size(time));

            % Assign what we obtain to the data structure.
            dataStruct.diameter = diameter;
            dataStruct.time = time;
            dataStruct.time_inter = time_inter;
            %dataStruct.average_diameter = average_diameter;

            dataRaw = transferData;
            save([saveFile '_' num2str(i, '%03.f') '.mat'], 'dataStruct', 'dataRaw', 'pupilData');
        else
            
            disp('Stop before transfer \n');
            pause
            UDPcommunicationProgram = {...
                {'Transfer Data Status', 'macCommand'} ...
            };
        
            while (~strcmp(macCommand,'begin transfer'))
                %macCommand = VSGOLGetInput;
                for k = 1:numel(UDPcommunicationProgram)
                    eval(sprintf('%s = VSGOL.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
                end
            end


            
            %matlabUDP('send','begin transfer');
            messageTuple = {'Transfer Data Status', 'begin transfer'};
            VSGOL.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
        
        
            
            fprintf('Transfer beginning...\n');
            %matlabUDP('send',num2str(numDataPoints));
            messageTuple = {'Number of Data Points', numDataPoints};
            VSGOL.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
            
            
            UDPcommunicationProgram = {...
                {'Transfer Data Status', 'macCommand'} ...
            };
        
            % Iterate over the data
            for kk = 1:numDataPoints
                while (~strcmp(macCommand,['transfering ' num2str(kk)]))
                    %macCommand = VSGOLGetInput;
                    for k = 1:numel(UDPcommunicationProgram)
                        eval(sprintf('%s = VSGOL.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
                    end
                end
                
                % matlabUDP('send',transferData{kk});
                messageTuple = {'Data Point', transferData{kk}};
                VSGOL.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
            end

            % Finish up the transfer
            fprintf('Data transfer for trial %f ending...\n', i);

            UDPcommunicationProgram = {...
                {'Transfer Data Status', 'macCommand'} ...
            };
            while (~strcmp(macCommand,'end transfer'))
                %macCommand = VSGOLGetInput;
                for k = 1:numel(UDPcommunicationProgram)
                    eval(sprintf('%s = VSGOL.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
                end
            end
        end
    
        % After the trial, plot out a trace of the data. This is presumably to make sure that everything went ok.
        % Calculates average pupil diameter.
        % meanPupilDiameter = mean(goodPupilDiameter);

        %     % Creates a figure with pupil diameter and interruptions over time. Also
        %     % displays the average pupil diameter over time.
        %     plot(goodPupilTimeStamps/1000,goodPupilDiameter,'b')
        %     hold on
        %     plot([goodPupilTimeStamps(1) goodPupilTimeStamps(2)]/1000, [meanPupilDiameter meanPupilDiameter], 'g')
        %     plot(badPupilTimeStamps/1000, zeros(size(badPupilTimeStamps)),'ro');
    
    end % for i
    
    % Close the UDP connection
    %matlabUDP('close');
    VSGOL.shutDown();
    
    fprintf('*** Program completed successfully.\n');


end


function beginRecording = VSGOLReceiveEyeTrackerCommand(VSGOL)
    % beginRecording = VSGOLReceiveEyeTrackerCommand
    % Wait and the 'go command
    
    UDPcommunicationProgram = {...
        {OLVSGcommunicator.eyeTrackerStatus, 'eyeTrackerStatus'} ...
    };
    for k = 1:numel(UDPcommunicationProgram)
        eval(sprintf('%s = VSGOL.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
    end
            
    if strcmp(eyeTrackerStatus,'Requesting permission to start tracking')
        % matlabUDP('send','Permission to begin recording received');
        messageTuple = {OLVSGcommunicator.eyeTrackerStatus, 'Permission granted'};
        VSGOL.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
        beginRecording = true;
    else
        beginRecording = false;
    end
end


function params = VSGOLEyeTrackerCheck(VSGOL, params)
    % params = VSGOLEyeTrackerCheck(params)
    % This function calls VSGOLGetInput which listens for a "start" or "stop" from the
    % Mac host. VSGOLProcessCommand will either allow the program to continue or
    % close the UDP port respective of the command from the Mac host.
    % Continuously checks for input from the Mac machine until data is actually available.
    global experimentMode
    
    if (experimentMode)
        vetStopTracking;
    end
    
    WaitSecs(2);
    %vetCreateCameraScreen;

    % checkStart = VSGOLGetInput;
    
    % === NEW ====== Wait for ever to receive the eye tracker status ==================
   	checkStart = VSGOL.receiveParamValue(VSGOL.EYE_TRACKER_STATUS,  ...
        'timeOutSecs', 2, 'consoleMessage', '>>> Entered VSGOLEyeTrackerCheck');
    % === NEW ====== Wait for ever to receive the eye tracker status ==================
            
    WaitSecs(1);
        
    if (strcmp(checkStart,'startEyeTrackerCheck'))
        fprintf('\n*** Start tracking...\n')
        if (experimentMode)
            vetStartTracking;
        end
        timeCheck = 5;
        tStart = GetSecs;
        while (GetSecs - tStart < timeCheck)
            % Collect some checking data
        end
        fprintf('*** Tracking finished \n')
        
        if (experimentMode)
            checkData = vetGetBufferedEyePositions;
            sumTrackData = sum(checkData.tracked);
            fprintf('*** Number of checking data points %d\n',sumTrackData)
        else
            sumTrackData = 6;
        end
        
        % matlabUDP('send',num2str(sumTrackData))
        % ==== NEW ===  Send eye tracker status = startEyeTrackerCheck ========
        VSGOL.sendParamValue({VSGOL.EYE_TRACKER_DATA_POINTS_NUM, sumTrackData}, ...
            'timeOutSecs', 2.0, 'maxAttemptsNum', 3);
        % ==== NEW ============================================================
    
        if (experimentMode)
            vetStopTracking;
        end
        
        WaitSecs(1);
        
        % command = matlabUDP('receive');
        % params.run = VSGOLProcessCommand(params, command);
        
        % === NEW ====== Wait for ever to receive the new eye tracker status ==================
        params.run = VSGOL.receiveParamValue(VSGOL.EYE_TRACKER_STATUS,  ...
            'timeOutSecs', Inf, 'consoleMessage', 'Did we track?');
        % === NEW ====== Wait for ever to receive the new eye tracker status ==================
        
    end
end


function params = VSGOLProcessCommand(params, command)
% params = VSGOLProcessCommand(params, command)
% This function is called in the function "VSGOLGetStart"  It processes the
% command from the Mac host and either starts or terminates the program.
%
% We may not need params.run anymore, however, I think it may be
% useful in another portion of the code.
[opcode, r] = strtok(command);
switch lower(opcode)
    case {'exit', 'quit', 'terminate', 'end', 'stop', 'false'}
        params.run = false;
    case {'start', 'begin', 'initiate', 'run', 'true'}
        params.run = true;
        disp('starting...');
end
end


