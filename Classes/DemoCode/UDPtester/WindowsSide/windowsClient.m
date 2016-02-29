function windowsClient
    global CRS;
    global experimentMode
    
    experimentMode = false;
    
    [rootDir, ~] = fileparts(fullfile(which(mfilename)));
    cd(rootDir); addpath('../Common');
    
    clc
    fprintf('\nStarting windows client\n');
    
     % Instantiate a UDPcommunictor object
    udpParams = getUDPparams('NicolasOffice'); 
    UDPobj = UDPcommunicator( ...
          'localIP', udpParams.winHostIP, ...    % required: the IP of this computer
         'remoteIP', udpParams.macHostIP, ...    % required: the IP of the computer we want to conenct to
          'udpPort', udpParams.udpPort, ...      % optional, with default value: 2007
        'verbosity', 'min' ...             % optional, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        );
    
    maxAttempts = 2;
    
    if (experimentMode)
        % Ask for observer
        fprintf('\n*********************************************');
        fprintf('\n*********************************************\n');
        saveDropbox = GetWithDefault('Save into Dropbox folder?', 1);
        
        % Create a VSGCALIBRATE mode to make test runs of the programmer quicker.
        VSGCALIBRATE = false;
        
        nSecsToSave = 5;

        %% Initializing Cambridge Researsh System and Other Neccessary Variables
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
    
    % Compose the UDPcommunicationProgram to run : specify sequence of messages (labels) expected to be received from the Mac
    % and the names of variables in which to store the received message values
    UDPcommunicationProgram = {...
            {'Protocol Name',       'protocolNameStr'} ...  % {messageLabel, variable name in which to store received data}
            {'Observer ID',         'obsID'} ...
            {'Observer ID and Run', 'obsIDandRun'} ...
            {'Number of Trials',    'nTrials'} ...
            {'Starting Trial No',   'startTrialNum'} ...
            {'Offline',             'offline'} ...
    };

    
    % Run program from step #1 to step #3
    stepsToExecute = (1:3);
    for k = stepsToExecute
        eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
    end
    
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
    
    % Run program from step #4 to step #6
    stepsToExecute = (4:6);
    for k = stepsToExecute
        eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
    end
    
    if (experimentMode)
        if (offline)
            % Figure out paths.

            % Set up the file name of the output file
            saveFile = fullfile(savePath, obsIDAndRun);

            %error('offline mode not implemented at this time.  There is unfinished offline code present in this state of the routine.  This error will be removed once the offline code is completed at a future time.');
        end
    end % experimentMode
    
    % print the variables we received so far
    for k = 1:numel(UDPcommunicationProgram)
        c = UDPcommunicationProgram{k};
        eval(c{2})
    end
    
    
    % ---------- PROGRAMS SYNCED UP TO HERE ------------- NICOLAS
    
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
            UDPcommunicationProgram = {...
                {'User Readiness Status', 'userReadiness'} ...
            };
            for k = 1:numel(UDPcommunicationProgram)
                eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
            end

            fprintf('>>> Check %g\n', checkCounter);
            fprintf('>>> User ready? %s \n', userReadiness);
            
            
            if checkCounter <= maxAttempts
                % matlabUDP('send','continue');
                messageTuple = {'Action', 'continue'};
                UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
                
                params = VSGOLEyeTrackerCheck(UDPobj, params);
                
            else
                % matlabUDP('send','abort');
                messageTuple = {'Action', 'abort'};
                UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
                
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
        goCommand = VSGOLReceiveEyeTrackerCommand(UDPobj);
        while (goCommand  ~= true)
            fprintf('>>> The go signal is %d',goCommand);
            goCommand = VSGOLReceiveEyeTrackerCommand(UDPobj);
        end
        if offline
            %vetStartRecordingToFile([saveFile '-' num2str(i) '.cam']);
        end
    
                
        % Check the 'stop' signal from the Mac
        checkStop = 'no_stop';
        while (~strcmp(checkStop,'stop pupil recording'))
            %checkStop = VSGOLGetInput;
            UDPcommunicationProgram = {...
                {'Eye Tracker Status', 'checkStop'} ...
            };
            for k = 1:numel(UDPcommunicationProgram)
                eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
            end
    
            if strcmp(checkStop,'stop pupil recording')
                %matlabUDP('send',sprintf('Trial %f has ended!\n', i));
                messageTuple = {'Eye Tracker Status', sprintf('Trial %f has ended!\n', i)};
                UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
            end
        end
    
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
            
            disp('OK to before transfer\n');
            pause
            while (~strcmp(macCommand,'begin transfer'))
                macCommand = VSGOLGetInput;
            end

            matlabUDP('send','begin transfer');
            fprintf('Transfer beginning...\n');
            matlabUDP('send',num2str(numDataPoints));

            % Iterate over the data
            for kk = 1:numDataPoints
                while (~strcmp(macCommand,['transfering ' num2str(kk)]))
                    macCommand = VSGOLGetInput;
                end
                matlabUDP('send',transferData{kk});
            end

            % Finish up the transfer
            fprintf('Data transfer for trial %f ending...\n', i);

            while (~strcmp(macCommand,'end transfer'))
                macCommand = VSGOLGetInput;
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
    matlabUDP('close');
    fprintf('*** Program completed successfully.\n');


end


function beginRecording = VSGOLReceiveEyeTrackerCommand(UDPobj)
    % beginRecording = VSGOLReceiveEyeTrackerCommand
    % Wait and the 'go command
    
    UDPcommunicationProgram = {...
        {'Eye Tracker Status', 'eyeTrackerStatus'} ...
    };
    for k = 1:numel(UDPcommunicationProgram)
        eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
    end
            
    if strcmp(eyeTrackerStatus,'Requesting permission to start tracking')
        % matlabUDP('send','Permission to begin recording received');
        messageTuple = {'Eye Tracker Status', 'Permission granted'};
        UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
        beginRecording = true;
    else
        beginRecording = false;
    end
end


function params = VSGOLEyeTrackerCheck(UDPobj, params)
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
    fprintf('>>> Entered VSGOLEyeTrackerCheck \n');

    % checkStart = VSGOLGetInput;

    UDPcommunicationProgram = {...
            {'Eye Tracker Status', 'checkStart'} ...
    };
    for k = 1:numel(UDPcommunicationProgram)
            eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
    end

    fprintf('%s',checkStart);
    WaitSecs(1);
        
    if (strcmp(checkStart,'startEyeTrackerCheck'))
        fprintf('*** Start tracking...\n')
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
        messageTuple = {'Number of checking data points', sumTrackData};
        UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
            

        if (experimentMode)
            vetStopTracking;
        end
        
        WaitSecs(1);
        
        % command = matlabUDP('receive');
        % params.run = VSGOLProcessCommand(params, command);
        UDPcommunicationProgram = {...
            {'Eye Tracker Status', 'params.run'} ...
        };
        for k = 1:numel(UDPcommunicationProgram)
            eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
        end
    
        params.run
        
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



function data = VSGOLGetInput
% NOT NEEDED JUST KEEPING IT HERE FOR REFERENCE - NICOLAS

    % data = VSGOLGetInput Continuously checks for input from the Mac machine
    % until data is actually available.
    %while matlabUDP('check') == 0; end
    %data = matlabUDP('receive');
    
    data = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf);
    
end

