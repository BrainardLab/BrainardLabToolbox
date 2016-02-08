function [data, params] = OLFlickerSensitivityVSGPupillometryRewrite
% [data, params] = OLPDPupilDiameterSubjectWindows
%
% This function works in lockstep with the program
% BasicPupilDiameter that runs on the Mac host.
% It uses UDP to talk with the Mac, and controls
% the VSG eye tracker to do the Mac's bidding.
%
% xx/xx/12  dhb, sj         Written.
% 07/25/13  ms              Commented.
% 11/20/13  ll              Rewrite.
% 02/09/16  npc             Clean up. Rewrite to use UDPcommunicator class.

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

%% Parameters
% There are some parameters we need for this to work, and
% our system for managing configuration parameters on Windows
% is not very evolved.  Indeed, we just set them here.
macHostIP = '130.91.72.120';
winHostIP = '130.91.74.15';
udpPort = 2007;

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

%% Open up the UDP communication.
% Both computers have to execute their open command to go
% beyond this point.
matlabUDP('close');
matlabUDP('open',winHostIP,macHostIP,udpPort);

%% Receiving initial information from Mac
fprintf('*** Waiting for Mac to tell us to go\n');
fprintf('*** Run OLFlickerSensitivity on Mac and select protocol...\n');

%% Main Experiment Loop
% Get start command from Mac
protocolNameStr = VSGOLGetProtocolName;
obsID = VSGOLGetObsID;
obsIDAndRun = VSGOLGetObsIDAndRun;

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

nTrials = VSGOLGetNumberTrials;
startTrialNum = VSGOLGetStartTrialNum;
offline = VSGOLGetOffline;
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
        userReady = VSGOLGetInput;
        fprintf('>>> Check %g\n', checkCounter);
        fprintf('>>> User ready? %s \n',userReady);
        if checkCounter <= maxAttempts
            matlabUDP('send','continue');
            params = VSGOLEyeTrackerCheck(params);
        else
            matlabUDP('send','abort');
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

    end
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
    goCommand = VSGOLReceiveEyeTrackerCommand;
    while (goCommand  ~= true)
        fprintf('>>> The go signal is %d',goCommand);
        goCommand = VSGOLReceiveEyeTrackerCommand;
    end
    if offline
        %vetStartRecordingToFile([saveFile '-' num2str(i) '.cam']);
    end
    
    % Check the 'stop' signal from the Mac
    checkStop = 'no_stop';
    while (~strcmp(checkStop,'stop'))
        checkStop = VSGOLGetInput;
        if strcmp(checkStop,'stop')
            matlabUDP('send',sprintf('Trial %f has ended!\n', i));
        end
    end
    
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
    
    %% After the trial, plot out a trace of the data. This is presumably to make sure that everything went ok.
    % Calculates average pupil diameter.
    % meanPupilDiameter = mean(goodPupilDiameter);
    
    %     % Creates a figure with pupil diameter and interruptions over time. Also
    %     % displays the average pupil diameter over time.
    %     plot(goodPupilTimeStamps/1000,goodPupilDiameter,'b')
    %     hold on
    %     plot([goodPupilTimeStamps(1) goodPupilTimeStamps(2)]/1000, [meanPupilDiameter meanPupilDiameter], 'g')
    %     plot(badPupilTimeStamps/1000, zeros(size(badPupilTimeStamps)),'ro');
end

% Close the UDP connection
matlabUDP('close');
fprintf('*** Program completed successfully.\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Subfunction neded by PupilDiameterSubjectWindows(...)
% Contains:
%   - VSGOLIsWithinBounds
%   - VSGOLGetStart
%   - VSGOLEyeTrackerCheck
%   - VSGOLProcessCommand
%   - VSGOLReceiveEyeTrackerCommand
%   - VSGOLGetNumberTrials
%   - VSGOLGetOffline
%   - VSGOLGetDirection
%   - VSGOLGetCalibrateTarget
%   - VSGOLGetInput
%
% Obsolete, thus removed:
%   - GetPupilMonitoringDuration

function data = VSGOLIsWithinBounds(radius, origin, current)
% data = VSGOLIsWithinBounds(radius, origin, current)
% Determines if the subject is staring at the target.
if (pdist([origin;current],'euclidean') <= radius)
    data = true;
else
    data = false;
end
end

function params = VSGOLEyeTrackerCheck(params)
% params = VSGOLEyeTrackerCheck(params)
% This function calls VSGOLGetInput which listens for a "start" or "stop" from the
% Mac host. VSGOLProcessCommand will either allow the program to continue or
% close the UDP port respective of the command from the Mac host.
% Continuously checks for input from the Mac machine until data is actually available.
vetStopTracking;
WaitSecs(2);
%vetCreateCameraScreen;
fprintf('>>> Entered VSGOLEyeTrackerCheck \n');
checkStart = VSGOLGetInput;
fprintf('%s',checkStart);
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
    matlabUDP('send',num2str(sumTrackData))
    vetStopTracking;
    WaitSecs(1);
    command = matlabUDP('receive');
    params = VSGOLProcessCommand(params, command);
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

function beginRecording = VSGOLReceiveEyeTrackerCommand
% beginRecording = VSGOLReceiveEyeTrackerCommand
% Wait and the 'go command
if strcmp(VSGOLGetInput,'start')
    matlabUDP('send','Permission to begin recording received');
    beginRecording = true;
else
    beginRecording = false;
end
end

function nTrials = VSGOLGetNumberTrials
% nTrials = VSGOLGetNumberTrials
% Get the number of trials from the Mac
temp = VSGOLGetInput;
fprintf('>>> Number of trials received as %s.\n',temp);
nTrials = str2num(temp);
matlabUDP('send','Received')
end

function startTrialNum = VSGOLGetStartTrialNum
% nTrials = VSGOLGetNumberTrials
% Get the number of trials from the Mac
temp = VSGOLGetInput;
fprintf('>>> Start trial number received as %s.\n',temp);
startTrialNum = str2num(temp);
matlabUDP('send','Received')
end


function protocolNameStr = VSGOLGetProtocolName
% nTrials = VSGOLGetNumberTrials
% Get the number of trials from the Mac
protocolNameStr = VSGOLGetInput;
fprintf('>>> Protocol name received as %s.\n',protocolNameStr);
matlabUDP('send','Received')
end

function obsID = VSGOLGetObsID
% nTrials = VSGOLGetNumberTrials
% Get the number of trials from the Mac
obsID = VSGOLGetInput;
fprintf('>>> Observer ID received as %s.\n',obsID);
matlabUDP('send','Received')
end

function obsIDAndRun = VSGOLGetObsIDAndRun
% nTrials = VSGOLGetNumberTrials
% Get the number of trials from the Mac
obsIDAndRun = VSGOLGetInput;
fprintf('>>> Observer ID and Run received as %s.\n',obsIDAndRun);
matlabUDP('send','Received')
end

function offline = VSGOLGetOffline
% offline = VSGOLGetOffline
% Get the oFFLINE flag
temp = VSGOLGetInput;
fprintf('>>> pOffline flag received from mac! %s',temp);
if (strcmp('true',temp))
    offline = true;
    matlabUDP('send','Received');
elseif (strcmp('false',temp))
    offline = false;
    matlabUDP('send','Received');
else
    offline = 'not_received';
    matlabUDP('send','Not received');
end
end

function [radius, origin] = VSGOLGetCalibrateTarget
% [radius, origin] = VSGOLGetCalibrateTarget
%
% VSGOLGetCalibrateTarget's purpose is to record subject eye positionings
% at specified points of the stimulus (left most part of the stimulus,
% right most part of the stimulus, upper most part, etc.) It then uses
% these positionings to calculate the radius of the stimulus (the opening
% of the Integration Sphere or whatever else the subject is being asked to
% look at).  In the main exeperimental loop, the radius is used to
% determine whether or not the subject is looking at the stimulus. If the
% distance between the tracked eye position and centerpoint of the stimulus
% is beyond the calculated radius, the data is labeled as "interrupted."

% Stores the position names into a struct array
circlepoint(1).position='up'; circlepoint(5).position='upperleft'; circlepoint(9).position='center';
circlepoint(2).position='down'; circlepoint(6).position='upperright'; circlepoint(10).position='finish';
circlepoint(3).position='left'; circlepoint(7).position='lowerleft';
circlepoint(4).position='right'; circlepoint(8).position='lowerright';

% Sets all the circlepoints as not finished by presetting them zero. The
% values then are set to 1 once each point has been recorded with its
% position.
for r=1:10
    circlepoint(r).iscalibrated=0;
end

% Specify the number of eye position measurements to average
% for each position measurement.
nAvg = 10;

% Receives input from the Mac to start calibration
beginCommand = VSGOLGetInput;
fprintf('Beginning target calibration procedure\n');
if (~strcmp(beginCommand, 'Begin tracker calibration'))
    error('Mac and Windows eye tracker communication out of sync');
end

% Loop until all points are calibrated
while(any(~[circlepoint.iscalibrated]))
    
    % Make some measurements
    vetStopTracking;
    
    % Initialize eye tracker for tracking.  Bitter experience
    % has taught us that it is necessary to insert pauses of
    % sufficient duration between certain calls the the eye tracker,
    % or else it will crash.  The particular durations used here
    % and elsewhere were tuned up by hand.
    vetStopTracking;
    vetDestroyCameraScreen;
    %WaitSecs(2);
    WaitSecs(2);
    
    % Step TAKE POINT or FINISH
    %
    % Wait for the Mac and then start tracking.  The
    % Mac tells us which posiition we are tracking.
    temp = VSGOLGetInput;
    index = -1;
    for i=1:10
        if (strcmp(temp,circlepoint(i).position))
            index=i;
        end
    end
    if (index == -1)
        error('We got a poistion command from the Mac that we don''t understand.')
    end
    
    % The finish option is not chosen, and we make a measurment
    % of one of the positions.  This is the
    % TAKE POINT fork in the code.
    if (index < 10)
        
        %WaitSecs(2);
        WaitSecs(2);
        vetCreateCameraScreen;
        %WaitSecs(2);
        WaitSecs(2);
        % Start tracking
        vetStartTracking;
        
        % Get current position as average of a number of measurements.
        sumOfPositions = [0 0];
        for j=1:nAvg
            
            % Continously tracks the eye until the eyetracker can track and
            % record a datapoint.  The routine vetGetLatestEyePosition returns
            % a structure with varios information in it.  The variable tracked indicates
            % whether the data in the structure are OK, so we wait for it to be true.
            % As noted above, the pauses inserted here prevent eye tracker crashes.
            current.tracked=0;
            while(current.tracked==0)
                %WaitSecs(1);
                WaitSecs(1);
                current=vetGetLatestEyePosition;
                % WaitSecs(.05);
                WaitSecs(1);
            end
            % Calculates the average by summing up all the values, then
            % later dividing it by 10
            sumOfPositions=sumOfPositions+current.mmPositions;
            
        end
        circlepoint(index).average=sumOfPositions/nAvg;
        circlepoint(index).iscalibrated=true;
        
        % Stop tracking
        %WaitSecs(1);
        WaitSecs(1);
        vetStopTracking;
        %WaitSecs(1);
        WaitSecs(1);
        
        % Step GET POINT
        % Sends the position name, and the average radius to the mac
        matlabUDP('send', circlepoint(index).position);
        %WaitSecs(1);
        WaitSecs(1);
        matlabUDP('send', num2str(circlepoint(index).average));
        fprintf('Sent %s for %s\n',num2str(circlepoint(index).average),circlepoint(index).position');
        
        % Do we have anything to report to Mac?  If so, report distances from center
        % to points for which we have measurements so far.  This also gets the
        % distancesStr all ready to send when the experimenter tells us we're finished.
        if (circlepoint(9).iscalibrated)
            distancesStr = ['Distances Summary | '];
            
            % Calculate distance for each point for which we have data
            for z=1:8
                % Determines if the circle point is recorded or not
                if(circlepoint(z).iscalibrated)
                    % Get distance between the circlepoint the center
                    circlepoint(z).distance = pdist([circlepoint(9).average; circlepoint(z).average],'euclidean');
                    
                    % Accumulate a string that provides the distances that we have measured so far
                    distancesStr = [distancesStr circlepoint(z).position ': ' num2str(circlepoint(z).distance) ' | '];
                end
            end
            
            % Send distances that we have so far
            matlabUDP('send', distancesStr);
        end
        % The user has chosen to finish the program. The boundaries of the
        % target have been calculated and the eyetracker will now stop tracking.
        % This is the FINISH forkin the code.
    elseif (index == 10)
        vetStopTracking;
        vetDestroyCameraScreen;
        
        % Sends all distances to the mac computer.
        matlabUDP('send', distancesStr);
        
        %Ends calibration of the target
        conclusion=VSGOLGetInput;
        if strcmp(conclusion, 'no')
            circlepoint(10).iscalibrated=true;
        end
        vetStopTracking;
        %WaitSecs(1);
        WaitSecs(1);
        vetDestroyCameraScreen;
    end
    
end

% Eyetracker now stops tracking
vetStopTracking;
vetDestroyCameraScreen;
fprintf('Target calibration completed\n');
vetClearDataBuffer;
radius = mean([circlepoint.distance]);
origin = circlepoint(9).average;
end

function data = VSGOLGetInput
% data = VSGOLGetInput Continuously checks for input from the Mac machine
% until data is actually available.
while matlabUDP('check') == 0; end
data = matlabUDP('receive');
end
