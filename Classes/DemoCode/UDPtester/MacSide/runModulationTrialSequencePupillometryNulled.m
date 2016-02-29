function runModulationTrialSequencePupillometryNulled
    global experimentMode
    experimentMode = false;
    
    [rootDir, ~] = fileparts(fullfile(which(mfilename)));
    cd(rootDir); addpath('../Common');
    
    clc
    fprintf('\nStarting ''%s''\n', mfilename);
    fprintf('Hit enter when the windowsClient is up and running.\n');
    pause;
    
    % Instantiate a UDPcommunictor object
    udpParams = getUDPparams('NicolasOffice');
    UDPobj = UDPcommunicator( ...
          'localIP', udpParams.macHostIP, ...
         'remoteIP', udpParams.winHostIP, ...
          'udpPort', udpParams.udpPort, ...      % optional with default 2007
        'verbosity', 'min' ...             % optional with possible values {'min', 'normal', 'max'}, and default 'normal'
        );
    
    
    params = struct(...
        'protocolName', 'ModulationTrialSequencePupillometryNulled',...
        'obsID', 'nicolas', ...
        'obsIDandRun', 'nicolas -123', ...
        'nTrials', 1, ...,
        'whichTrialToStartAt', 1, ...
        'VSGOfflineMode', true ...
    );
    

    
    % Initialize a data structure to be used to obtain the data
    dataStruct = struct('diameter', -1, ...
        'time', -1, ...
        'time_inter', -1, ...
        'average_diameter', -1, ...
        'ratioInterupt', -1);
        
    % This is the trialLoop function
    % Compose the UDPcommunicationProgram to run: sequence of commands to transmit to Windows
    UDPcommunicationProgram = {...
            {'Protocol Name',       params.protocolName} ...  % {messageLabel, messageValue}
            {'Observer ID',         params.obsID} ...
            {'Observer ID and Run', params.obsIDandRun} ...
            {'Number of Trials',    params.nTrials} ...
            {'Starting Trial No',   params.whichTrialToStartAt} ...
            {'Offline',             params.VSGOfflineMode}
    };

    % Run the initial program
    for k = 1:numel(UDPcommunicationProgram)
        UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(UDPcommunicationProgram{k});
    end

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
        end
        
        % DEBUG
        %params.run = true; abort = false;
            
        % Check the tracking function of VET system
        while (params.run == false)
            sound(yStop, fs);  
            
            % Check whether the user is good to resume
            [readyToResume, abort] = OLVSGCheckResume(readyToResume, params, block(1).data.startsBG', block(1).data.stopsBG');
            
            %matlabUDP('send','The User is ready to move on.');
            messageTuple = {'User Readiness Status', 'User is ready to move on.'}
            UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
    
            
            fprintf('OLVSGCheckResume: User input acquired.\n');
    
            % Wait to receive the next action
            % continueCheck = OLVSGGetInput;
            UDPcommunicationProgram = {...
                {'Action', 'continueCheck'} ...
            };
            for k = 1:numel(UDPcommunicationProgram)
                eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
            end
            

            
            if strcmp(continueCheck, 'abort');
               abort = true;
            end
            if strcmp(continueCheck, 'continue');
                % Let's make sure that the eye is being tracked
                isBeingTracked = OLVSGEyeTrackerCheck(UDPobj);
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
            
        % Send the 'start' signal. Note that this will remain in the queue
        % over at the VSG box.
        fprintf('Send permission to start tracking \n');
        % reply = OLVSGSendEyeTrackingCommand;
        
        messageTuple = {'Eye Tracker Status', 'Requesting permission to start tracking'};
        UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
    
%         while (~strcmp(reply,'Permission granted'))
%             reply = OLVSGGetInput;
%         end

        reply = ' ';
        while (~strcmp(reply,'Permission granted'))
            UDPcommunicationProgram = {...
                {'User Readiness Status', 'reply'} ...
            };
            for k = 1:numel(UDPcommunicationProgram)
                eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
            end
        end
        
        disp('OK to here');
        pause;
        
        sound(yStart, fs);
        if trial == 1 && params.skipPupilRecordingFirstTrial
            % If we're in the first trial, we stop recording
            % immediately and just show the background. That way, all
            % the things below still check out.

            % We stop recording.
            reply = OLVSGStopPupilRecording;
            fprintf('%s', reply);

            % Launch into OLPDFlickerSettings.
            events(trial).tTrialStart = mglGetSecs;
            [~, events(trial).t] = ModulationTrialSequenceFlickerStartsStops(trial, params.timeStep, 1);
            events(trial).tTrialEnd = mglGetSecs;

        else

            % Launch into OLPDFlickerSettings.
            events(trial).tTrialStart = mglGetSecs;
            [~, events(trial).t] = ModulationTrialSequenceFlickerStartsStops(trial, params.timeStep, 1);
            events(trial).tTrialEnd = mglGetSecs;

            % We stop recording.
            reply = OLVSGStopPupilRecording;
            fprintf('%s', reply);
        end
            
        
        % Save the data structure
        if (offline == false)
            % Get the data
            [time, diameter, good_counter, interruption_counter, time_inter] = OLVSGTransferData(trial, params, block(1).data.startsBG', block(1).data.stopsBG');

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
            
        if (offline == true);
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
    
end


function isBeingTracked = OLVSGEyeTrackerCheck(UDPobj)
    % isBeingTracked = OLVSGEyeTrackerCheck
    % This function makes sure that the EyeTracker is successfully tracking
    % the subject's eye.
    %
    % We want to get 5 good data points for 5 seconds
    timeCheck = 5;
    dataCheck = 5;
    
    % OLVSGClearMessageBuffer;
    UDPobj.flashQueue();
    
    WaitSecs(1);
    
    % matlabUDP('send','startEyeTrackerCheck');
    messageTuple = {'Eye Tracker Status', 'startEyeTrackerCheck'};
    UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
    
    tStart = mglGetSecs;

    while (mglGetSecs-tStart <= timeCheck)
        % Collecting checking data
    end

    % numTrackedData = OLVSGGetInput;
    UDPcommunicationProgram = {...
                {'Number of checking data points', 'numTrackedData'} ...
    };
    for k = 1:numel(UDPcommunicationProgram)
        eval(sprintf('%s = UDPobj.getMessageValueWithMatchingLabelOrFail(UDPcommunicationProgram{k}{1});', UDPcommunicationProgram{k}{2}));
    end
            
    fprintf('%s checking data points collected \n',numTrackedData)

    % Clear the buffer
    % OLVSGClearMessageBuffer;
    UDPobj.flashQueue();
    
    if (numTrackedData >= dataCheck)
        isBeingTracked = true;
        %matlabUDP('send', 'true');
        fprintf('Tracking check successful \n')
    else
        isBeingTracked = false;
        %matlabUDP('send', 'false');
    end

    messageTuple = {'Eye Tracker Status', isBeingTracked};
    UDPobj.sendMessageAndReceiveAcknowldegmentOrFail(messageTuple);
    
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
    
