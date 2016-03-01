function runWindowsClientOnLine

    % Housekeeping.
    clear; close all;

    % Ask for observer
    fprintf('\n*********************************************');
    fprintf('\n*********************************************\n');
    saveDropbox = GetWithDefault('Save into Dropbox folder?', 1);

    % Create a VSGCALIBRATE mode to make test runs of the programmer quicker.
    VSGCALIBRATE = false;
    maxAttempts = 2;
    nSecsToSave = 5;

    
    %% Initializing Cambridge Researsh System and Other Neccessary Variables
    % Global CRS gives us access to a cell structure of the Video Eye Tracker's
    % variables.  Load constants creates this cell structure
    global CRS;
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

    macHostIP = '130.91.72.120';
    winHostIP = '130.91.74.15';
    udpPort = 2007;

    % === NEW ======  Instantiate a OLVSGcommunicator object ==============
    VSGOL = OLVSGcommunicator( ...
        'signature', 'WindowsSide', ...          % a label indicating the host, used to for user-feedback
          'localIP', winHostIP, ...    % required: the IP of this computer
         'remoteIP', macHostIP, ...    % required: the IP of the computer we want to conenct to
          'udpPort', udpPort, ...      % optional, with default value: 2007
        'verbosity', 'min' ...                   % optional, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
    );
    % === NEW ======  Instantiate a OLVSGcommunicator object ==============
    
    % === NEW ====== Receiving initial information from Mac
    fprintf('\nRun OLFlickerSensitivity on Mac and select protocol...\n');
    VSGOL.receiveParamValue(VSGOL.WAIT_STATUS,  'timeOutSecs', Inf, 'consoleMessage', 'Hey Mac, is there anybody out there?');
    
    % === NEW ====== Get param values for labeled param names ==================
    protocolNameStr = VSGOL.receiveParamValue(VSGOL.PROTOCOL_NAME,       'timeOutSecs', 2, 'consoleMessage', 'receiving protocol name');
    obsID           = VSGOL.receiveParamValue(VSGOL.OBSERVER_ID,         'timeOutSecs', 2, 'consoleMessage', 'receiving observer ID');
    obsIDAndRun     = VSGOL.receiveParamValue(VSGOL.OBSERVER_ID_AND_RUN, 'timeOutSecs', 2, 'consoleMessage', 'receiving observer ID and run');
    % === NEW ====== Get param values for labeled param names ==================
    
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

    % === NEW ====== Get param values for labeled param names ==================
    nTrials         = VSGOL.receiveParamValue(VSGOL.NUMBER_OF_TRIALS,  'timeOutSecs', 2, 'consoleMessage', 'receiving number of trials');
    startTrialNum   = VSGOL.receiveParamValue(VSGOL.STARTING_TRIAL_NO, 'timeOutSecs', 2, 'consoleMessage', 'receiving which trial to start');
    offline         = VSGOL.receiveParamValue(VSGOL.OFFLINE,           'timeOutSecs', 2, 'consoleMessage', 'receivingVSGOfflineMode');
    % === NEW ====== Get param values for labeled param names ==================
    
    if (offline)
        % Figure out paths.

        % Set up the file name of the output file
        saveFile = fullfile(savePath, obsIDAndRun);

        %error('offline mode not implemented at this time.  There is unfinished offline code present in this state of the routine.  This error will be removed once the offline code is completed at a future time.');
    end

    
    %% Loop over trials
    for i = startTrialNum:nTrials
        %% Initializating variables
        params.run = false;

        % Clear the buffer
        vetClearDataBuffer;

        % Stop the tracking in case it is still running
        vetStopTracking;

        %% Debug
        %params.run = true;


        %% Check if we are ready to run
        checkCounter = 0;
        while (params.run == false)
            checkCounter = checkCounter + 1;
            
            % === NEW ====== Wait for ever to receive the userReady status ==================
            userReady = VSGOL.receiveParamValue(VSGOL.USER_READY_STATUS,  ...
                'timeOutSecs', Inf, 'consoleMessage', 'Is user ready?');
            % === NEW ====== Wait for ever to receive the userReady status ==================
            fprintf('>>> Check %g\n', checkCounter);
            
            if checkCounter <= maxAttempts
                % ==== NEW ===  Send user ready status ========================
                VSGOL.sendParamValue({VSGOL.USER_READY_STATUS, 'continue'}, 'timeOutSecs', 2);
                % =============================================================
 
                params = VSGOLEyeTrackerCheck(VSGOL, params);
            else
                % ==== NEW ===  Send user ready status ========================
                VSGOL.sendParamValue({VSGOL.USER_READY_STATUS, 'abort'}, 'timeOutSecs', 2);
                % =============================================================
                
                fprintf('>>> Could not acquire good tracking after %g attempts.\n', maxAttempts);
                fprintf('>>> Saving %g seconds of diagnostic video on the hard drive.\n', nSecsToSave);
            
                vetStartTracking;
                vetStartRecordingToFile(fullfile([saveFile '_' num2str(i, '%03.f') '_diagnostics.cam']));
                pause(nSecsToSave);
                vetStopRecording;
                vetStopTracking;
                abortExperiment = true;
                params.run = true;
            end
        end % while (params.run == false)


        %if abortExperiment
        %   break; 
        %end

        % Stop the tracking
        vetStopTracking;
        %WaitSecs(1);

        % Start the tracking
        vetStartTracking;
        %WaitSecs(1);

        % Get the 'Go' signal
        % === NEW ====== Wait for ever to receive the StartTracking signal ==================
        goCommand = VSGOL.receiveParamValue(VSGOL.EYE_TRACKER_STATUS,  ...
            'timeOutSecs', Inf, 'consoleMessage', 'Start tracking?');
        if (~strcmp(goCommand, 'startTracking'))
            error('Expected ''startTracking'', received: ''%s'' .', checkStop);
        end
        % === NEW ====== Wait for ever to receive the START signal ==================
    
        if offline
            %vetStartRecordingToFile([saveFile '-' num2str(i) '.cam']);
        end

        % Check the 'stop' signal from the Mac
        % === NEW === Wait for ever to receive the stopTracking signal, then send the trial outcome ==================
        VSGOL.receiveParamValueAndSendResponse(...
            {VSGOL.EYE_TRACKER_STATUS, 'stopTracking'}, ...                  % expected param name and value
            {VSGOL.TRIAL_OUTCOME, sprintf('Trial %f has ended!\n', i)}, ...  % the response to be sent
            'timeOutSecs', Inf, 'consoleMessage', 'Stop tracking?');
        % === NEW === Wait for ever to receive the stopTracking signal, then send the trial outcome ==================

        % Get all data from the buffer
        pupilData = vetGetBufferedEyePositions;
    
        if offline
            % Stop the tracking
            vetStopRecording;
        end

        % Stop tracking
        vetStopTracking;
        %vetDestroyCameraScreen; ??? Needed?

        % Get the transfer data
        goodCounter = 1;
        badCounter = 1;
        clear transferData;
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
    
        % Start the file transfer
        
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
            
            % === NEW ====== Wait for ever to receive a 'begin transfer' signal and respond to it ==================
            VSGOL.receiveParamValueAndSendResponse(...
                {VSGOL.DATA_TRANSFER_STATUS, 'begin transfer'}, ...  % received from mac
                {VSGOL.DATA_TRANSFER_STATUS, 'begin transfer'}, ...  % transmitted back
                'timeOutSecs', Inf, ...
                'consoleMessage', 'Begin data transfer?' ...
            );
            % === NEW ====== Wait for ever to receive a 'begin transfer' signal and respond to it ==================
            
            % ==== NEW ===  Send the number of data points to be transferred ===
            VSGOL.sendParamValue({VSGOL.DATA_TRANSFER_POINTS_NUM, numDataPoints}, ...
                'timeOutSecs', 2, 'consoleMessage', sprintf('Informing Mac about number of data points (%d)', numDataPoints));
            % ==== NEW ===  Send the number of data points to be transferred ===
            
            % Iterate over the data
            for kk = 1:numDataPoints
                
                % === NEW Wait for ever to receive request to transfer data for point kk, then send that data over
                VSGOL.receiveParamValueAndSendResponse(...
                    {VSGOL.DATA_TRANSFER_REQUEST_FOR_POINT, kk}, ...  % received trasnfer request for data point kk 
                    {VSGOL.DATA_FOR_POINT, transferData{kk}}, ...     % transmit back the data for point kk
                    'timeOutSecs', Inf ...
                );
                % === NEW Wait for ever to receive request to transfer data for point kk, then send that data over
                
            end % kk
            
            % Finish up the transfer
            VSGOL.receiveParamValue(VSGOL.DATA_TRANSFER_STATUS, 'consoleMessage', sprintf('Data for trial %d transfered. End data transfer?', i));
        end
        
        %% After the trial, plot out a trace of the data. This is presumably to make sure that everything went ok.
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
    VSGOL.shutDown();
    
    fprintf('*** Program completed successfully.\n');
end


function params = VSGOLEyeTrackerCheck(VSGOL, params)
    
    vetStopTracking;
    WaitSecs(2);
    
    %vetCreateCameraScreen;
    
    % === NEW ====== Wait for ever to receive the eye tracker status ==================
   	checkStart = VSGOL.receiveParamValue(VSGOL.EYE_TRACKER_STATUS,  ...
        'timeOutSecs', 2, 'consoleMessage', 'Start checking eye tracking ?');
    % === NEW ====== Wait for ever to receive the eye tracker status ==================
    
    WaitSecs(1);
    if (strcmp(checkStart,'startEyeTrackerCheck'))
        fprintf('*** Start tracking...\n')
        vetStartTracking;
        timeCheck = 5;
        tStart = GetSecs;
        while (GetSecs - tStart < timeCheck)
            % Collect some checking data
        end
        fprintf('*** Tracking finished \n')
        checkData = vetGetBufferedEyePositions;
        sumTrackData = sum(checkData.tracked);
        fprintf('*** Number of checking data points %d\n',sumTrackData)
        
        % ==== NEW ===  Send eye tracker status = startEyeTrackerCheck ========
        VSGOL.sendParamValue({VSGOL.EYE_TRACKER_DATA_POINTS_NUM, sumTrackData}, ...
            'timeOutSecs', 2.0, 'maxAttemptsNum', 3);
        % ==== NEW ============================================================
        
        vetStopTracking;
        WaitSecs(1);
        
        % === NEW ====== Wait for ever to receive the new eye tracker status ==================
        params.run = VSGOL.receiveParamValue(VSGOL.EYE_TRACKER_STATUS,  ...
            'timeOutSecs', Inf, 'consoleMessage', 'Did we track OK?');
        % === NEW ====== Wait for ever to receive the new eye tracker status ==================
    end
end
