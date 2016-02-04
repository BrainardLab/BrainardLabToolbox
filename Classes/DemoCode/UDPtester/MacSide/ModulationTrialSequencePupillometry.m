function params = ModulationTrialSequencePupillometry(exp)
% params = MRITrialSequence(exp)

% Setup basic parameters for the experiment
params = initParams(exp);

fprintf('> Trial numbers in protocol file:\n');
fprintf('   nTrials: %g\n', params.nTrials);
fprintf('   theFrequencyIndices: %g\n', length(params.theFrequencyIndices));
fprintf('   thePhaseIndices: %g\n', length(params.thePhaseIndices));
fprintf('   theDirections: %g\n', length(params.theDirections));
fprintf('   theContrastRelMaxIndices: %g\n', length(params.theContrastRelMaxIndices));
fprintf('   trialDuration: %g\n\n', length(params.trialDuration));

% Ask for the observer age
params.observerAgeInYears = GetWithDefault('>>> Observer age', 32);

% Ask if we want to skip pupil recording in the first trial
params.skipPupilRecordingFirstTrial = GetWithDefault('>>> Skip pupil recording in the first trial? [1 = yes, 0 = no]', 0);

%% Put together the trial order
for i = 1:length(params.cacheFileName)
    % Construct the file name to load in age-specific file
    
    %modulationData{i} = LoadCalFile(params.cacheFileName{i}, [], [params.cacheDir '/modulations/']);
    [~, fileName, fileSuffix] = fileparts(params.cacheFileName{i});
    params.cacheFileName{i} = [fileName '-' num2str(params.observerAgeInYears) fileSuffix];
    try
        modulationData{i} = load(fullfile(params.cacheDir, 'modulations', params.cacheFileName{i}));
    catch
        error('ERROR: Cache file for observer with specific age could not be found');
    end
    
    % Check if we're using the most recent version of the cache file in the
    % modulation files. If not, prompt user to recompute.
    
    % Get the date of the cache used the modulation file
    tmpParams = modulationData{i}.modulationObj.describe(1).params;
    
    % Load in the cache file so that we know what date the most recent cache is
    tmpParams.olCache = OLCache('/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli', tmpParams.oneLightCal);
    
    tmpCacheData = tmpParams.olCache.load(tmpParams.cacheFileName{1});
    
    % Compare the dates. If they don't match up, we have a more recent
    % cache file than we use in the modulation file. Tell experimenter to
    % re-generate the modulation files
    if ~strcmp(tmpCacheData.date, tmpParams.cacheDate{1})
        %error('ERROR: Date of most recent cache file available and cache file used in modulation pre-cache are not consistent. Please regenerate modulation waveforms using OLFlickerComputeModulationWaveforms!')
    end
end

% Put together the trial order
% Pre-initialize the blocks
block = struct();
block(params.nTrials).describe = '';

% Debug
%params.nTrials = 1;

for i = 1:params.nTrials
    fprintf('- Preconfiguring trial %i/%i...', i, params.nTrials);
    block(i).data = modulationData{params.theDirections(i)}.modulationObj.modulation(params.theFrequencyIndices(i), params.thePhaseIndices(i), params.theContrastRelMaxIndices(i));
    block(i).describe = modulationData{params.theDirections(i)}.modulationObj.describe;
    
    % Check if the 'attentionTask' flag is set. If it is, set up the task
    % (brief stimulus offset).
    %block(i).attentionTask.flag = params.attentionTask(i);
    
    block(i).direction = block(i).data.direction;
    block(i).modulationMode = block(i).data.modulationMode;
    if strcmp(block(i).modulationMode, 'AM')
        block(i).envelopeFrequencyHz = block(i).data.theEnvelopeFrequencyHz;
        block(i).envelopePhaseDeg = block(i).carrierPhaseDeg;
        block(i).carrierPhaseDeg = 0;
        block(i).carrierFrequencyHz = block(i).describe.theFrequenciesHz(params.theFrequencyIndices(i));
        block(i).contrastRelMax = block(i).describe.theContrastRelMax(params.theContrastRelMaxIndices(i));
    else
        block(i).carrierFrequencyHz = block(i).describe.theFrequenciesHz(params.theFrequencyIndices(i));
        block(i).carrierPhaseDeg = block(i).describe.thePhasesDeg(params.thePhaseIndices(i));
        block(i).contrastRelMax = block(i).describe.theContrastRelMax(params.theContrastRelMaxIndices(i));
    end
    % If in distortion product, get the envelope frequency
    
    
    
    
    if strcmp(block(i).direction, 'Background')
        block(i).modulationMode = 'BG';
        block(i).envelopePhaseDeg = 0;
        block(i).envelopeFrequencyHz = 0;
    end
    
    
    % We pull out the background.
    block(i).data.startsBG = block(i).data.starts(1, :);
    block(i).data.stopsBG = block(i).data.stops(1, :);
    
    fprintf('Done\n');
end



% Get rid of modulationData struct
clear modulationData;

%% Create the OneLight object.
% This makes sure we are talking to OneLight.

ol = OneLight;

% Make sure our input and output pattern buffers are setup right.
ol.InputPatternBuffer = 0;
ol.OutputPatternBuffer = 0;

fprintf('\n* Creating keyboard listener\n');
mglListener('init');

%% Calibration mode
% The calibration mode exists to allow for a calibration of the x-y
% positions of the eye tracker. This is currently not used, but an
% appropriate routine to communicate with the VSG Winbox is implemented
% below.
VSGCALLIBRATE = false;

% OLVSGSendCalibrateTarget tells the other computer to start the EyeTracking
% routine, the one that makes sure the subject is looking at the target
% throughout the experiment/run.  OLVSGSendCalibrateTarget tells the Windows
% machine when to start recording.  This internal function also creates the
% GUI for the experimenter so that the position can be selected.
if VSGCALLIBRATE
    OLVSGSendCalibrateTarget();
end

%% Initialize UDP
% Set up the matlabUDP protocol, opens the necessary ports and establishes
% a connection between the mac and the windows machine so that we can
% measure and monitor pupil size.
%
% The programs on the two machines have matching sequences of operation, so
% that they march forward in lock step through their various
% communications.
matlabUDP('close');
matlabUDP('open', params.macHostIP, params.winHostIP, params.udpPort);

%% Run the trial loop.
params = trialLoop(params, block, exp);

% Toss the OLCache and OneLight objects because they are really only
% ephemeral.
params = rmfield(params, {'olCache'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS FOR PROGRAM LOGIC %%%%%%%%%%%%%%%%%%%%%%%%
%
% Contains:
%       - initParams(...)
%       - trialLoop(...)

    function params = initParams(exp)
        % params = initParams(exp)
        % Initialize the parameters
        
        [~, tmp, suff] = fileparts(exp.configFileName);
        exp.configFileName = fullfile(exp.configFileDir, [tmp, suff]);
        
        % Load the config file for this condition.
        cfgFile = ConfigFile(exp.configFileName);
        
        % Convert all the ConfigFile parameters into simple struct values.
        params = convertToStruct(cfgFile);
        params.cacheDir = fullfile(exp.baseDir, 'cache');
        
        % Load the calibration file.
        cType = OLCalibrationTypes.(params.calibrationType);
        params.oneLightCal = LoadCalFile(cType.CalFileName);
        
        % Setup the cache.
        params.olCache = OLCache(params.cacheDir, params.oneLightCal);
        
        file_names = allwords(params.modulationFiles,',');
        for i = 1:length(file_names)
            % Create the cache file name.
            [~, params.cacheFileName{i}] = fileparts(file_names{i});
        end
        
    end

    function params = trialLoop(params, block, exp)
        % [params, responseStruct] = trialLoop(params, cacheData, exp)
        % This function runs the experiment loop
        
        %% Create the OneLight object.
        % This makes sure we are talking to OneLight.
        ol = OneLight;
        
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
        
        % Send the number of trials to the Winbox
        reply = OLVSGSendNumTrials(params);
        fprintf('Win received number of trials? %s\n',reply);
        
        % Send OFFLINE flag to the Winbox
        reply = OLVSGSendOfflineFlag(params);
        fprintf('Win received online flag %s\n',reply);
        
        % Set the background to the 'idle' background appropriate for this
        % trial.
        fprintf('- Setting mirrors to background\n');
        ol.setMirrors(block(1).data.startsBG',  block(1).data.stopsBG'); % Use first trial
        
        events = struct();
        
        % Suppress keypresses going to the Matlab window.
        ListenChar(2);
        
        % Iterate over trials
        for trial = 1:params.nTrials
            fprintf('* Start trial %i/%i - %s, %.2f Hz.\n', trial, params.nTrials, block(trial).direction, block(trial).carrierFrequencyHz);
            
            ol.setMirrors(block(1).data.startsBG',  block(1).data.stopsBG'); % Use first trial
            
            %% Check the communication betwen Mac host and Win VET
            % Set some flags that are checked done below.
            readyToResume = false;
            isBeingTracked = false;
            params.run = false;
            
            % Play a tone to mark the beginning of the oncoming trial
            %% Set up sounds
            fs = 20000;
            durSecs = 0.1;
            t = linspace(0, durSecs, durSecs*fs);
            yStart = [sin(880*2*pi*t)];
            yStop = [sin(440*2*pi*t)];
            
            
            %% DEBUG
            %params.run = true; abort = false;
            
            %% Check the tracking function of VET system
            while (params.run == false)
                sound(yStop, fs);
                % Check whether the user is good to resume
                [readyToResume, abort] = OLVSGCheckResume(readyToResume, params, block(1).data.startsBG', block(1).data.stopsBG');
                if (abort == true)
                    % If not, we break out.
                    break;
                end
                
                % Let's make sure that the eye is being tracked
                isBeingTracked = OLVSGEyeTrackerCheck;
                
                % When we are in in OFFLINE mode, we need to send over the
                % direction to the VSG computer so that it knows how to name
                % files
                %if (offline == true)
                %    reply = OLVSGSendDirection(params, trial);
                %    fprintf('%s',reply);
                %    isBeingTracked = true;
                %end
                
                % If we have to redo the tracking, play a tone
                if (isBeingTracked == false)
                    %system('say Try again');
                    sound(yStop, fs);
                end
                
                % Here we establish where we are ready to go
                if (readyToResume == true && isBeingTracked == true)
                    params.run = true;
                end
            end
            
            % Abort if true
            if (abort == true)
                break
            end
            
            % Send the 'start' signal. Note that this will remain in the queue
            % over at the VSG box.
            fprintf('Send permission to start tracking \n')
            reply = OLVSGSendEyeTrackingCommand;
            while (~strcmp(reply,'Permission to begin recording received'))
                reply = OLVSGGetInput;
            end
            %sound('say Starting');
            sound(yStart, fs);
            if trial == 1 && params.skipPupilRecordingFirstTrial
                % If we're in the first trial, we stop recording
                % immediately and just show the background. That way, all
                % the things below still check out.
                
                % We stop recording.
                reply = OLVSGStopPupilRecording;
                fprintf('%s', reply);
                
                %% Launch into OLPDFlickerSettings.
                events(trial).tTrialStart = mglGetSecs;
                [~, events(trial).t] = ModulationTrialSequenceFlickerStartsStops(trial, params.timeStep, 1);
                events(trial).tTrialEnd = mglGetSecs;
                
            else
                
                %% Launch into OLPDFlickerSettings.
                events(trial).tTrialStart = mglGetSecs;
                [~, events(trial).t] = ModulationTrialSequenceFlickerStartsStops(trial, params.timeStep, 1);
                events(trial).tTrialEnd = mglGetSecs;
                
                % We stop recording.
                reply = OLVSGStopPupilRecording;
                fprintf('%s', reply);
            end
            
            %% Save the data structure
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
                
                dataStruct(trial).frequencyCarrier = block(trial).carrierFrequencyHz;
                dataStruct(trial).phaseCarrier = block(trial).carrierPhaseDeg;
                dataStruct(trial).direction = block(trial).direction;
                dataStruct(trial).contrastRelMax = block(trial).contrastRelMax;
                
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
                
                % And clear the variables to get ready for the trial.
                clear time;
                clear diameter;
                clear good_counter;
                clear interruption_counter;
                clear time_inter;
            end
            if (offline == true);
                dataStruct(trial).frequencyCarrier = block(trial).carrierFrequencyHz;
                dataStruct(trial).phaseCarrier = block(trial).carrierPhaseDeg;
                dataStruct(trial).direction = block(trial).direction;
                dataStruct(trial).contrastRelMax = block(trial).contrastRelMax;
            end
            
        end
        tBlockEnd = mglGetSecs;
        
        fprintf('- Done with block.\n');
        
        system('say End of Experiment');
        ListenChar(0);
        
        % Turn all mirrors off
        ol.setMirrors(block(1).data.startsBG',  block(1).data.stopsBG'); % Use first trialol.setAll(false);
        
        % Tack data that we want for later analysis onto params structure.  It then
        % gets passed back to the calling routine and saved in our standard place.
        params.dataStruct = dataStruct;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS FOR OL-VSG COMM %%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Contains:
%       - OLVSGTransferData             - Gets data from the VSG box.
%       - OLVSGSendEyeTrackingCommand   - Sends the start signal
%       - OLVSGEyeTrackerCheck          - Makes sure the eye is trackable
%       - OLVSGCheckResume              - Check whether subject can move on
%       - OLVSGStopPupilRecording       - Stop pupil recording
%       - OLVSGSendNumTrials             - Send number of stimuli
%       - OLVSGSendOfflineFlag          - Sends offline flag
%       - OLVSGSendDirection            - Sends directions
%       - OLVSGSendCalibrateTarget      - Sends the calibration command
%       - OLVSGClearMessageBuffer       - Clears the UDP queue
%       - OLVSGGetInput                 - Generic function to get UDP input
%       - PlayC                         - Plays 'C'
%       - PlayD                         - Plays 'D'
%       - PlayE                         - Plays 'E' and sets mirrors
%
% Note that these functions like have counter parts in the
% VSGEyeTrackerPupillometry toolbox.
%
% Unused and thus removed (07/25/2013):
%       X SendStart(...)
%       X SendPupilMonitoringDuration(...)
%
% [These functions can always be restored from the SVN. I (MS) have removed
% them, however, for clarity.]

    function [time, diameter, good_counter, interruption_counter, time_inter] = OLVSGTransferData(i, params, starts, stopsBackgroundIdle)
        % [time, diameter, good_counter, interruption_counter, time_inter] = OLVSGTransferData(i, params, starts, stopsBackgroundIdle)
        % Get the data from the VSG box
        
        % Set the mirrors to the background
        ol = OneLight;
        ol.setMirrors(starts,stopsBackgroundIdle);
        
        % Initialize the data transfer
        fprintf('OLVSGTransferData: Beginning transfer of data...\n');
        matlabUDP('send','begin transfer');
        winCommand = 'waiting';
        while (~strcmp(winCommand,'begin transfer'))
            winCommand = OLVSGGetInput;
        end
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
        nDataPoints = str2num(OLVSGGetInput);
        
        fprintf('OLVSGTransferData: The number of data points is %d\n', nDataPoints);
        
        % Iterate over the data points
        for i = 1:nDataPoints
            matlabUDP('send', ['transfering ' num2str(i)]);
            firstSampleTimeStamp = OLVSGGetInput;
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
        matlabUDP('send','end transfer');
    end

    function reply = OLVSGSendEyeTrackingCommand
        % reply = OLVSGSendEyeTrackingCommand
        % This function sends the 'go' command
        matlabUDP('send', 'start');
        reply = OLVSGGetInput;
        fprintf('%s\n', reply);
    end

    function isBeingTracked = OLVSGEyeTrackerCheck
        % isBeingTracked = OLVSGEyeTrackerCheck
        % This function makes sure that the EyeTracker is successfully tracking
        % the subject's eye.
        %
        % We want to get 5 good data points for 5 seconds
        timeCheck = 5;
        dataCheck = 5;
        OLVSGClearMessageBuffer;
        WaitSecs(2);
        matlabUDP('send','startEyeTrackerCheck');
        tStart = mglGetSecs;
        
        while (mglGetSecs-tStart <= timeCheck)
            % Collecting checking data
        end
        
        numTrackedData = OLVSGGetInput;
        fprintf('%s checking data points collected \n',numTrackedData)
        
        % Clear the buffer
        OLVSGClearMessageBuffer;
        
        if (str2double(numTrackedData) >= dataCheck)
            isBeingTracked = true;
            matlabUDP('send', 'true');
            fprintf('Tracking check successful \n')
        else
            isBeingTracked = false;
            matlabUDP('send', 'false');
        end
        
    end

    function [readyToResume, abort] = OLVSGCheckResume(readyToResume, params, starts, stopsBackgroundIdle)
        % [readyToResume, abort] = OLVSGCheckResume(readyToResume, params, stopsBackgroundIdle, starts)
        % Checks whether suject is okay to resume with next trial.
        
        % We need to explicitly re-set the mirrors to the background to prevent
        % OneLight from blinking the mirrors to zero during the function call away
        % from the main routine
        ol = OneLight;
        ol.setMirrors(starts,stopsBackgroundIdle);
        
        
        fs = 20000;
        durSecs = 0.01;
        t = linspace(0, durSecs, durSecs*fs);
        yHint = [sin(880*2*pi*t)];
        
        % Suppress keypresses going to the Matlab window.
        ListenChar(2);
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
                %if (strcmp(keyPress,'a'))
                %    abort = true;
                %    readyToResume = false;
                %    resume = true;
                %    fprintf('Aborted.\n');
                %else
                    readyToResume = true;
                    abort = false;
                    resume = true;
                %end
            end
        end
        matlabUDP('send','The User is ready to move on.');
        fprintf('OLVSGCheckResume: User input acquired.\n');
    end

    function reply = OLVSGStopPupilRecording
        % reply = OLVSGStopPupilRecording(params, starts, settings)
        % Stop the recording
        matlabUDP('send',sprintf('stop'));
        reply = OLVSGGetInput;
    end

    function reply = OLVSGSendNumTrials(params)
        % reply = OLVSGSendNumStims(params)
        % Send over the number of trials
        number = params.nTrials;
        matlabUDP('send', sprintf('%f', number));
        reply = OLVSGGetInput;
        
    end

    function reply = OLVSGSendOfflineFlag(params)
        % reply = OLVSGSendOfflineFlag(params)
        % Send over the offline flag
        offline = params.VSGOfflineMode;
        if (offline == true)
            sOffline = 'true';
        else
            sOffline = 'false';
        end
        matlabUDP('send',sprintf('%s',sOffline));
        reply = OLVSGGetInput;
    end

    function reply = OLVSGSendDirection(params, i)
        % reply = OLVSGSendDirection(params, i)
        % Send over the direction index. This is only for the currently unused
        % OFFLINE mode.
        if (i == 0)
            direction = 0;
        else
            direction = params.directionTrials(i);
        end
        
        if (direction == 0)
            sDirection = '0';
        elseif (direction == 1)
            sDirection = '1';
        elseif (direction == 2)
            sDirection = '2';
        elseif (direction == 3)
            sDirection = '3';
        elseif (direction == 4)
            sDirection = '4';
        end
        
        matlabUDP('send',sprintf('%s',sDirection));
        reply = OLVSGGetInput;
        
    end

    function OLVSGSendCalibrateTarget
        % OLVSGSendCalibrateTarget
        % This presumably runs calibration
        index=0; % use for later errorcoding purposes
        circlepoint(1).position='up'; circlepoint(5).position='upperleft'; circlepoint(9).position='center';
        circlepoint(2).position='down'; circlepoint(6).position='upperright'; circlepoint(10).position='finish';
        circlepoint(3).position='left'; circlepoint(7).position='lowerleft';
        circlepoint(4).position='right'; circlepoint(8).position='lowerright';
        
        % Sets all the circlepoints as not finished by presetting them zero. The
        % values then are set to 1 once each point has been recorded with its
        % position.
        for r = 1:10
            circlepoint(r).iscalibrated = 0;
        end
        
        % Experimenter waits for the subject to be ready
        input('Make sure subject is ready and it enter to begin eye tracker calibration procedure','s');
        matlabUDP('send', 'Begin tracker calibration');
        
        % Now the experimenter tells the subject to look at the various points on
        % the on a circle that defines the edge of the stimulus, and then pushes a
        % button on a gui to tell the program to measure eye position.  This allows
        % us to compute an "OK" region and do something smart when the subject
        % fails to look at the stimulus.
        while(any(~[circlepoint.iscalibrated]))
            
            % Indicate point verbally and then push a button when subject indicates
            % they are fixated at the position.
            index = 11;
            assignin('base', 'commanddirection', 'not_set');
            push=buttons;
            waitfor(push);
            
            % Figure out what to do.  1-9 indicate points (9 = center) and 10 means
            % to finish. The variable index takes on the answer at the end of this
            % loop.
            index = -1;
            for i=1:10
                if strcmp(circlepoint(i).position,evalin('base','commanddirection'))
                    index=i;
                end
            end
            if (index == -1)
                error('We got a gui command that we don''t understand.')
            end
            
            % If we're not finished, talk to the Windows machine and take a data
            % point.
            if(index<10)
                % Step TAKE POINT.  Tell tracker to get eye position.
                matlabUDP('send', circlepoint(index).position);
                fprintf('Asked for eye position for point %s\n',circlepoint(index).position);
                
                % Step GET POINT.  Wait for the position to come back.
                firstSampleTimeStamp = OLVSGGetInput;
                if strcmp(firstSampleTimeStamp, circlepoint(index).position)
                    fprintf('Got data for %s: ',circlepoint(index).position);
                end
                firstSampleTimeStamp = OLVSGGetInput;
                fprintf('%s\n',firstSampleTimeStamp);
                circlepoint(index).iscalibrated=true;
                
                % If we've calibrated the center point, then the Windows machine
                % will send us the radii it knows about.  We thus pick up that
                % string and display to the experimenter to help him or her track
                % progress
                if (circlepoint(9).iscalibrated)
                    distancesStr = OLVSGGetInput;
                    fprintf('Distances so far\n%s\n',distancesStr);
                end
                
            elseif (index == 10)
                % Step FINISH.  Tell the Windows machine that we're done now.
                matlabUDP('send', 'finish');
                
                % Get all the data
                distancesStr=OLVSGGetInput;
                fprintf('Final distances\n%s\n',distancesStr);
                
                % Let the experimenter decide whether we are really done
                command = input('Would you like to repeat any values? yes or no...\n','s')
                matlabUDP('send',command);
                if strcmp(command,'no')
                    circlepoint(10).iscalibrated = true;
                    fprintf('Target calibration finished\n')
                else
                    fprintf('Use gui to redo desired points\n');
                end
            end
        end
    end

    function OLVSGClearMessageBuffer
        % OLVSGClearMessageBuffer
        % Clear Message Buffer
        while (matlabUDP('check') == 1)
            throwaway = matlabUDP('receive');
        end
    end

    function data = OLVSGGetInput
        % data = OLVSGGetInput
        % Generic function get input.
        while matlabUDP('check') == 0; end
        data = matlabUDP('receive');
    end

    function PlayC
        % PlayC
        % Play a 'C' tone (262 Hz)
        t = linspace(0, 1, 10000);
        y = sin(262*2*pi*t);
        sound(y, 20000);
    end

    function PlayD
        % PlayD
        % Play a 'D' tone (294 Hz)
        t = linspace(0, 1, 10000);
        y = sin(294*2*pi*t);
        sound(y, 20000);
    end

    function [keyEvents, t, counter] = ModulationTrialSequenceFlickerStartsStops(trial, frameDurationSecs, numIterations)
        % OLFlicker - Flickers the OneLight.
        %
        % Syntax:
        % keyPress = OLFlicker(ol, stops, frameDurationSecs, numIterations)
        %
        % Description:
        % Flickers the OneLight using the passed stops matrix until a key is
        % pressed or the number of iterations is reached.
        %
        % Input:
        % ol (OneLight) - The OneLight object.
        % stops (1024xN) - The normalized [0,1] mirror stops to loop through.
        % frameDurationSecs (scalar) - The duration to hold each setting until the
        %     next one is loaded.
        % numIterations (scalar) - The number of iterations to loop through the
        %     stops.  Passing Inf causes the function to loop forever.
        %
        % Output:
        % keyPress (char|empty) - If in continuous mode, the key the user pressed
        %     to end the script.  In regular mode, this will always be empty.
        %starts = block(trial).data.starts';
        %stops = block(trial).data.stops';
        
        %keyPress = [];
        
        % Flag whether we're checking the keyboard during the flicker loop.
        %checkKB = isinf(numIterations);
        
        % Counters to keep track of which of the stops to display and which
        % iteration we're on.
        iterationCount = 0;
        setCount = 0;
        
        numstops = size(block(trial).data.starts, 1);
        
        t = zeros(1, numstops);
        i = 0;
        
        % This is the time of the stops change.  It gets updated everytime
        % we apply new mirror stops.
        mileStone = mglGetSecs + frameDurationSecs;
        
        
        keyEvents = [];
        
        while iterationCount < numIterations
            if mglGetSecs >= mileStone;
                i = i + 1;
                
                % Update the time of our next switch.
                mileStone = mileStone + frameDurationSecs;
                
                % Update our stops counter.
                setCount = mod(setCount + 1, numstops);
                
                % If we've reached the end of the stops list, iterate the
                % counter that keeps track of how many times we've gone through
                % the list.
                if setCount == 0
                    iterationCount = iterationCount + 1;
                    setCount = numstops;
                end
                
                % Send over the new stops.
                t(i) = mglGetSecs;
                counter(i) = setCount;
                ol.setMirrors(block(trial).data.starts(setCount, :)', block(trial).data.stops(setCount, :)');
            end
            
        end
    end
end