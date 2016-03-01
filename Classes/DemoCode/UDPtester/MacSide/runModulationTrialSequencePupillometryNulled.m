function runModulationTrialSequencePupillometryNulled
    global experimentMode
    experimentMode = false;
    
    [rootDir, ~] = fileparts(fullfile(which(mfilename)));
    cd(rootDir); 
    addpath('../Common');
    
    clc
    
    
    % === NEW ====== Instantiate a UDPcommunictor object ==================
    udpParams = getUDPparams();
    
    OLVSG = OLVSGcommunicator( ...
        'signature', 'MacSide', ...              % a label indicating the host, used to for user-feedback
          'localIP', udpParams.macHostIP, ...    % required: the IP of this computer
         'remoteIP', udpParams.winHostIP, ...    % required: the IP of the computer we want to conenct to
          'udpPort', udpParams.udpPort, ...      % optional, with default value: 2007
        'verbosity', 'min' ...                   % optional, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        );
   
    % Set valid values for comnunication param: USER_READY_STATUS
    OLVSG.setValidValuesForParam(OLVSG.USER_READY_STATUS, ...
          {...
            'user ready to move on',...
            'continue', ...
            'abort' ...
          } ...
    );
        
    % Set valid values for comnunication param: EYE_TRACKER_STATUS
    OLVSG.setValidValuesForParam(OLVSG.EYE_TRACKER_STATUS, ...
          {...
            'startEyeTrackerCheck', ...
            'isTracking', ...
            'isNotTracking', ...
            'startTracking', ...
            'stopTracking' ...
          }...
    );

    % Set valid values for comnunication param: DATA_TRANSFER_STATUS
    OLVSG.setValidValuesForParam(OLVSG.DATA_TRANSFER_STATUS, ...
        { ...
            'begin transfer', ...
            'end transfer' ...
        }...
    );

    % === NEW ====== Instantiate a UDPcommunictor object ==================
     
        
    
    
    params = struct(...
        'protocolName', 'ModulationTrialSequencePupillometryNulled',...
        'obsID', 'nicolas', ...
        'obsIDandRun', 'nicolas -123', ...
        'nTrials', 1, ...,
        'whichTrialToStartAt', 1, ...
        'VSGOfflineMode', false ...
    );
    params.skipPupilRecordingFirstTrial = true;

    
    % Initialize a data structure to be used to obtain the data
    dataStruct = struct('diameter', -1, ...
        'time', -1, ...
        'time_inter', -1, ...
        'average_diameter', -1, ...
        'ratioInterupt', -1);
      
    % Determine the number of trials in this block and create a data struct of
    % that size
    dataStruct = repmat(dataStruct, params.nTrials, 1);
    offline = params.VSGOfflineMode;
        
    fprintf('\n<strong>%s</strong>; Hit enter when the windowsClient is up and running.\n', mfilename);
    pause;
    
    % Let the Windows loose
    OLVSG.sendParamValue({OLVSG.WAIT_STATUS, 'Wake Up'}, 'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending wake up message');
    
    
    % This is the trialLoop function
    % ==== NEW ===  Send param values =====================================
    OLVSG.sendParamValue({OLVSG.PROTOCOL_NAME,       params.protocolName},        'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending protocol name');
    OLVSG.sendParamValue({OLVSG.OBSERVER_ID,         params.obsID},               'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending observer ID');
    OLVSG.sendParamValue({OLVSG.OBSERVER_ID_AND_RUN, params.obsIDandRun},         'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending observer ID and run');
    OLVSG.sendParamValue({OLVSG.NUMBER_OF_TRIALS,    params.nTrials},             'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending number of trials');
    OLVSG.sendParamValue({OLVSG.STARTING_TRIAL_NO,   params.whichTrialToStartAt}, 'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending which trial to start at');
    OLVSG.sendParamValue({OLVSG.OFFLINE,             params.VSGOfflineMode},      'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'sending VSGOfflineMode');
    % ==== NEW ===  Send param values =====================================
    

    if (experimentMode)  
        % Create the OneLight object.
        % This makes sure we are talking to OneLight.
        ol = OneLight;
        
        % Set the background to the 'idle' background appropriate for this
        % trial.
        fprintf('- Setting mirrors to background\n');
        ol.setMirrors(block(1).data.startsBG',  block(1).data.stopsBG'); % Use first trial
    end
    
    events = struct();
    
    if (experimentMode) 
        % Suppress keypresses going to the Matlab window.
        ListenChar(2);
        %         OLDarkTimer;
    end
    

    % Iterate over trials
    for trial = params.whichTrialToStartAt:params.nTrials
        
        if (experimentMode) 
            fprintf('* Start trial %i/%i - %s, %.2f Hz.\n', trial, params.nTrials, block(trial).direction, block(trial).carrierFrequencyHz);
            system(['say Trial ' num2str(trial)  ' of ' num2str(params.nTrials)]);

            ol.setMirrors(block(1).data.startsBG',  block(1).data.stopsBG'); % Use first trial
        end
        
        % Check the communication betwen Mac host and Win VET
        % Set some flags that are checked done below.
        readyToResume = false;
        isBeingTracked = false;
        params.run = false;

        % Play a tone to mark the beginning of the oncoming trial
        % Set up sounds
        fs = 20000;
        durSecs = 0.1;
        t = linspace(0, durSecs, durSecs*fs);
        yStart = [sin(880*2*pi*t)];
        yStop = [sin(440*2*pi*t)];


        if (~experimentMode) 
            % dummy block
            block(1).data.startsBG = [1 2];
            block(1).data.stopsBG = [2 3];
            block(1).modulationMode = 'AM';
        end
        
        % DEBUG
        %params.run = true; abort = false;
            
        % Check the tracking function of VET system
        while (params.run == false)
            sound(yStop, fs);  
            
            % Check whether the user is good to resume
            [readyToResume, abort] = OLVSGCheckResume(readyToResume, params, block(1).data.startsBG', block(1).data.stopsBG');
            
            %matlabUDP('send','The User is ready to move on.');
            % ==== NEW ===  Send user ready status ========================
            OLVSG.sendParamValue({OLVSG.USER_READY_STATUS, 'user ready to move on'}, ...
                'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'User input acquired');
            % =============================================================
            
    
            % Wait to receive either a continue or an abort message
            % continueCheck = OLVSGGetInput;
            
            % === NEW ====== Wait for ever to receive the userReady status ==================
            continueCheck = OLVSG.receiveParamValue(OLVSG.USER_READY_STATUS,  ...
                'timeOutSecs', 2.0, 'consoleMessage', 'Continue checking ?');
            % === NEW ====== Wait for ever to receive the userReady status ==================
            

            if strcmp(continueCheck, 'abort');
               abort = true;
            elseif strcmp(continueCheck, 'continue');
                % Let's make sure that the eye is being tracked
                isBeingTracked = OLVSGEyeTrackerCheck(OLVSG);
            else
                error('Unknown continueCheck value: ''%s''\n', continueCheck);
            end
                
            
            % When we are in in OFFLINE mode, we need to send over the
            % direction to the VSG computer so that it knows how to name
            % files
            %if (offline == true)
            %    reply = OLVSGSendDirection(params, trial);
            %    fprintf('%s',reply);
            %    isBeingTracked = true;
            %end

            if (abort == true)
                % If not, we break out.
                pause(5);
                system('say Could not track.');
                break;
            end                

            % If we have to redo the tracking, play a tone
            if (isBeingTracked == false)
                sound(yStop, fs);
            end

            % Here we establish where we are ready to go
            if (readyToResume == true && isBeingTracked == true)
                params.run = true;
            end
        end
            
        % Abort if true
        if (abort == true)
            break;
        end
            

        
        % Send the 'start' signal. Note that this will remain in the queue over at the VSG box.
        % reply = OLVSGSendEyeTrackingCommand;
        
        % ==== NEW ===  Send the 'startTracking' command ================================
        OLVSG.sendParamValue({OLVSG.EYE_TRACKER_STATUS, 'startTracking'}, ...
            'timeOutSecs', 5, 'maxAttemptsNum', 3, ...
            'consoleMessage', 'Sending request to start tracking');
        % =====================================================================
        
        
        
        
        sound(yStart, fs);
        if trial == 1 && params.skipPupilRecordingFirstTrial
            % If we're in the first trial, we stop recording
            % immediately and just show the background. That way, all
            % the things below still check out.

            % We stop recording.
%             reply = OLVSGStopPupilRecording(OLVSG);
%             fprintf('%s', reply);

            % ==== NEW ===  Send the 'stopTracking' command and wait for the trial outcome ====
            trialOutcome = OLVSG.sendParamValueAndWaitForResponse(...
                {OLVSG.EYE_TRACKER_STATUS, 'stopTracking'}, ...
                {OLVSG.TRIAL_OUTCOME}, ...                             % expected response label
                'timeOutSecs', 5, 'maxAttemptsNum', 3, ...
                'consoleMessage', 'Sending request to stop tracking');
            fprintf('%s', trialOutcome);
            % ==== NEW ===  Send the 'stopTracking' command and wait for the trial outcome ====
               
             
            if (experimentMode) 
                % Launch into OLPDFlickerSettings.
                events(trial).tTrialStart = mglGetSecs;
                [~, events(trial).t] = ModulationTrialSequenceFlickerStartsStops(trial, params.timeStep, 1);
                events(trial).tTrialEnd = mglGetSecs;
            end

        else

            if (experimentMode) 
                % Launch into OLPDFlickerSettings.
                events(trial).tTrialStart = mglGetSecs;
                [~, events(trial).t] = ModulationTrialSequenceFlickerStartsStops(trial, params.timeStep, 1);
                events(trial).tTrialEnd = mglGetSecs;
            end
            
            % We stop recording.
            % reply = OLVSGStopPupilRecording(OLVSG);
            
            % ==== NEW ===  Send the 'stopTracking' command and wait for the trial outcome ====
            trialOutcome = OLVSG.sendParamValueAndWaitForResponse(...
                {OLVSG.EYE_TRACKER_STATUS, 'stopTracking'}, ...
                {OLVSG.TRIAL_OUTCOME}, ...                             % expected response label
                'timeOutSecs', 5, 'maxAttemptsNum', 3, ...
                'consoleMessage', 'Sending request to stop tracking');
            fprintf('%s', trialOutcome);
            % ==== NEW ===  Send the 'stopTracking' command and wait for the trial outcome ====
        end
            
        
        % Save the data structure
        if (offline == false)
            % Get the data
            
            [time, diameter, good_counter, interruption_counter, time_inter] = ...
                OLVSGTransferData(OLVSG,trial, params, block(1).data.startsBG', block(1).data.stopsBG');

            if (experimentMode) 
                % Calculate Some statistics on how good the measuremnts were
                good_counter = good_counter - 1;
                interruption_counter = interruption_counter - 1;
                ratioInterupt = (interruption_counter/(interruption_counter+good_counter));
                average_diameter = mean(diameter)*ones(size(time));

                % Assign what we obtain to the data structure.
                dataStruct(trial).diameter = diameter;
                dataStruct(trial).time = time;
                dataStruct(trial).time_inter = time_inter;
                dataStruct(trial).average_diameter = average_diameter;
                dataStruct(trial).ratioInterupt = ratioInterupt;
            end
            
        end
            
        if (experimentMode) 
            if strcmp(block(trial).modulationMode, 'AM')
                dataStruct(trial).frequencyEnvelope = block(trial).envelopeFrequencyHz;
                dataStruct(trial).phaseEnvelope = block(trial).carrierPhaseDeg;
                dataStruct(trial).modulationMode = block(trial).modulationMode;
            end

            if strcmp(block(trial).modulationMode, 'BG')
                dataStruct(trial).frequencyEnvelope = 0;
                dataStruct(trial).phaseEnvelope = 0;
                dataStruct(trial).modulationMode = block(trial).modulationMode;
            end

            if strcmp(block(trial).modulationMode, 'FM')
                dataStruct(trial).frequencyEnvelope = 0;
                dataStruct(trial).phaseEnvelope = 0;
                dataStruct(trial).modulationMode = block(trial).modulationMode;
            end
            dataStruct(trial).modulationMode = block(trial).modulationMode;
            
            if (offline == true)
                dataStruct(trial).frequencyCarrier = block(trial).carrierFrequencyHz;
                dataStruct(trial).phaseCarrier = block(trial).carrierPhaseDeg;
                dataStruct(trial).direction = block(trial).direction;
                dataStruct(trial).contrastRelMax = block(trial).contrastRelMax;

                if ~isempty(strfind(block(trial).modulationMode, 'pulse'))
                    dataStruct(trial).frequencyEnvelope = 0;
                    dataStruct(trial).phaseEnvelope = 0;
                    dataStruct(trial).modulationMode = block(trial).modulationMode;
                    dataStruct(trial).phaseRandSec = block(trial).phaseRandSec;
                    dataStruct(trial).stepTimeSec = block(trial).stepTimeSec;
                    dataStruct(trial).preStepTimeSec = block(trial).preStepTimeSec;
                end
            end
        end
        
        % And clear the variables to get ready for the trial.
        clear time;
        clear diameter;
        clear good_counter;
        clear interruption_counter;
        clear time_inter;
            
    end % for trial
        
    tBlockEnd = mglGetSecs;
        
    fprintf('- Done with block.\n');

    system('say End of Experiment');
    
    if (experimentMode)
        ListenChar(0);

        % Turn all mirrors off
        ol.setMirrors(block(1).data.startsBG',  block(1).data.stopsBG'); % Use first trialol.setAll(false);
    end
    
    % Tack data that we want for later analysis onto params structure.  It then
    % gets passed back to the calling routine and saved in our standard place.
    params.dataStruct = dataStruct;
    
    OLVSG.shutDown();
end


function [time, diameter, good_counter, interruption_counter, time_inter] = OLVSGTransferData(OLVSG, i, params, starts, stopsBackgroundIdle)
        % [time, diameter, good_counter, interruption_counter, time_inter] = OLVSGTransferData(i, params, starts, stopsBackgroundIdle)
        % Get the data from the VSG box
        
        global experimentMode
        
        if (experimentMode)
            % Set the mirrors to the background
            ol = OneLight;
            ol.setMirrors(starts,stopsBackgroundIdle);
        end
        
        % Initialize the data transfer

        %matlabUDP('send','begin transfer');
        % fprintf('OLVSGTransferData: Beginning transfer of data...\n');
        
        % ==== NEW ===  Send begin transfer request and wait for acknowledgment ========================
        OLVSG.sendParamValueAndWaitForResponse(...
            {OLVSG.DATA_TRANSFER_STATUS, 'begin transfer'}, ...             % transmitted 
            {OLVSG.DATA_TRANSFER_STATUS, 'begin transfer'}, ...             % response label and value expected to be received
            'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'Beginning transfer of data');
        % ==== NEW ===  Send begin transfer request and wait for acknowledgment ========================
            
        
        
        fprintf('OLVSGTransferData: proceeding with data transfer\n');
        good_counter = 0;
        
        % Clear and initialize some variables
        clear diameter;
        clear time;
        clear time_inter;
        interruption_counter = 0;
        diameter(1) = 0;
        time(1) = 0;
        time_inter(1) = 0;
        
        % Get the number of data points to be transferred
        % === NEW ====== Wait for ever to receive the userReady status ==================
        nDataPoints = OLVSG.receiveParamValue(OLVSG.DATA_TRANSFER_POINTS_NUM,  'timeOutSecs', 2.0);
        % === NEW ====== Wait for ever to receive the userReady status ==================
                
        fprintf('OLVSGTransferData: The number of data points is %d\n', nDataPoints);
            
        % Iterate over the data points
        for i = 1:nDataPoints
            
            %matlabUDP('send', ['transfering ' num2str(i)]);
            %firstSampleTimeStamp = OLVSGGetInput;
            
            % === NEW == Send request to trasfer data point i, and wait to receive that point ===
            firstSampleTimeStamp = OLVSG.sendParamValueAndWaitForResponse(...
                {OLVSG.DATA_TRANSFER_REQUEST_FOR_POINT, i}, ...
                {OLVSG.DATA_FOR_POINT}, ...
                'timeOutSecs', 2 ...
            );
            % === NEW == Send request to trasfer data point i, and wait to receive that point ===]
        
            parsedline = allwords(firstSampleTimeStamp, ' ');
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
        
        fprintf('OLVSGTransferData: Data transfer %f complete.\n', i)
        
        %matlabUDP('send','end transfer');
        
        % ==== NEW ===  Send the end transfer request  ========================
        OLVSG.sendParamValue({OLVSG.DATA_TRANSFER_STATUS, 'end transfer'});
        % ==== NEW ===  Send the end transfer request  ========================
end
    

function isBeingTracked = OLVSGEyeTrackerCheck(OLVSG)
    % isBeingTracked = OLVSGEyeTrackerCheck
    % This function makes sure that the EyeTracker is successfully tracking
    % the subject's eye.
    %
    % We want to get 5 good data points for 5 seconds
    timeCheck = 5;
    dataCheck = 5;
    
    % OLVSGClearMessageBuffer;
    OLVSG.flashQueue()
    
    WaitSecs(1);
    
    % matlabUDP('send','startEyeTrackerCheck');
    % ==== NEW ===  Send eye tracker status = startEyeTrackerCheck ========
    OLVSG.sendParamValue({OLVSG.EYE_TRACKER_STATUS, 'startEyeTrackerCheck'}, ...
        'timeOutSecs', 2.0, 'maxAttemptsNum', 1, 'consoleMessage', 'Start eye tracking check.');
    % ==== NEW ============================================================
 
    
    tStart = mglGetSecs;

    while (mglGetSecs-tStart <= timeCheck)
        % Collecting checking data
    end

    % numTrackedData = OLVSGGetInput;
    % === NEW ====== Retrieve the number of eye tracking data points ==================
    numTrackedData = OLVSG.receiveParamValue(OLVSG.EYE_TRACKER_DATA_POINTS_NUM,  ...
        'timeOutSecs', 2.0, 'consoleMessage', 'Waiting for eye tracker data');
    % === NEW ====== Retrieve the number of eye tracking data points ==================
  
    % Clear the buffer
    % OLVSGClearMessageBuffer;
    OLVSG.flashQueue();
    
    if (numTrackedData >= dataCheck)
        isBeingTracked = true;
        %matlabUDP('send', 'true');
        % ==== NEW ===  Send user ready status ================================
        OLVSG.sendParamValue({OLVSG.EYE_TRACKER_STATUS, 'isTracking'}, ...
            'timeOutSecs', 2, 'consoleMessage', 'Eye tracking check was successful.');
        % =====================================================================
    else
        isBeingTracked = false;
        %matlabUDP('send', 'false');
        % ==== NEW ===  Send user ready status ================================
        OLVSG.sendParamValue({OLVSG.EYE_TRACKER_STATUS, 'isNotTracking'}, ...
            'timeOutSecs', 2, 'consoleMessage', 'Eye tracking check failed');
        % =====================================================================
    end

    
end


function [readyToResume, abort] = OLVSGCheckResume(readyToResume, params, starts, stopsBackgroundIdle)
    % [readyToResume, abort] = OLVSGCheckResume(readyToResume, params, stopsBackgroundIdle, starts)
    % Checks whether suject is okay to resume with next trial.

    global experimentMode
    % We need to explicitly re-set the mirrors to the background to prevent
    % OneLight from blinking the mirrors to zero during the function call away
    % from the main routine
    
    if (experimentMode)
        ol = OneLight;
        ol.setMirrors(starts,stopsBackgroundIdle);
    end
    
    fs = 20000;
    durSecs = 0.01;
    t = linspace(0, durSecs, durSecs*fs);
    yHint = [sin(880*2*pi*t)];

    if (experimentMode)
        % Suppress keypresses going to the Matlab window.
        ListenChar(2); 
    end
    
    resume = false;
    % Flush our keyboard queue.
    fprintf('Waiting for a key press ...\n');
    mglGetKeyEvent;
    keyPress = [];
    
    while (resume == false)
        %fprintf('waiting for response.'); This started working after adding
        %the pause...keep in mind 4 future
        pause(.1);
        key = mglGetKeyEvent;
        % If a key was pressed, get the key and exit.
        if ~isempty(key)
            sound(yHint, fs);
            keyPress = key.charCode;
            if (strcmp(keyPress,'a'))
                abort = true;
                readyToResume = false;
                resume = true;
                fprintf('Aborted.\n');
            else
                readyToResume = true;
                abort = false;
                resume = true;
            end
        end
    end
end
    
