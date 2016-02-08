function [data, params] = OLPDPupilDiameterSubjectWindows
% [data, params] = OLPDPupilDiameterSubjectWindows
%
% This function works in lockstep with the program
% BasicPupilDiameter that runs on the Mac host.
% It uses UDP to talk with the Mac, and controls
% the VSG eye tracker to do the Mac's bidding.
%
% xx/xx/12  dhb, sj         Written.
% 07/25/13  ms              Commented.

% Create a VSGCALIBRATE mode to make test runs of the programmer quicker.
VSGCALIBRATE = true;

%% Parameters
% There are some parameters we need for this to work, and
% our system for managing configuration parameters on Windows
% is not very evolved.  Indeed, we just set them here.
macHostIP = '130.91.74.234';
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
fprintf('Waiting for initialization params...\n');

if (~VSGCALIBRATE)
    %% Calibrating target size
    %
    % Routine for getting radius of the circle. VSGOLGetCalibrateTarget receives information
    % from the mac of the boundaries of the target the subject is looking at.
    % VSGOLGetCalibrateTarget then calculates the radius of the target and determines if the
    % subject is staring at the target, based on the subject's pupil's position
    % in comparison to the center of the target. It compares this distance to
    % the radius of the target to determine if the subject is staring within the
    % boundaries of the target
    [radius, origin] = VSGOLGetCalibrateTarget;
else
    radius = 1000;
    origin = [50 80];
end

% Creates a delay to allow the camera screen to finish loading loading
vetCreateCameraScreen;
pause(6);

%% Main Experiment Loop
% Get start command from Mac
fprintf('Waiting for Mac to tell us to go\n');
numStims = VSGOLGetNumberStims;
offline = VSGOLGetOffline;
if (offline)
    error('offline mode not implemented at this time.  There is unfinished offline code present in this state of the routine.  This error will be removed once the offline code is completed at a future time.');
end

%% Loop over trials
for i = 0:numStims
    %% Initializating variables
    good_counter = 1;
    interruption_counter = 1;
    clear diameter; % Clear some rvariables
    clear time;
    clear time_inter;
    clear totalData;
    clear direction;
    diameter(1) = 0;
    time(1) = 0;
    time_inter(1) = 0;
    interruption_time_seconds = 0;
    
    % Initiliazes variable to -100 to ensure to satisfy condition in the
    % while loop below
    time(1)=-100;
    lastTimeStamp=-100;
    totalCounter = 0;
    EndEarly = false;
    params.run = false;
    
    % Clear the buffer
    vetClearDataBuffer;
    
    % Stop the tracking in case it is still running
    vetStopTracking;

    % Pause for 3 seconds
    pause(3);

    % Check if we are ready to run
    while (params.run == false)
        userReady = VSGOLGetInput;
        fprintf('%s \n',userReady);
        if (offline == false)
            params = VSGOLEyeTrackerCheck(params);
        elseif (offline == true)
            direction = VSGOLGetDirection;
            params.run = true;
        end
    end
    
    % Stop the tracking
    vetStopTracking;

    % Pause for 1 second
    pause(1);
    
    % Start the tracking
    vetStartTracking;
    
    % If in OFFLINE mode, record to file
    if (offline == true)
        vetStartRecordingToFile(['TTF4D_' direction '_trial_' num2str(i) '_video'])
    end

    % Pause for 1 second
    pause(1);
    
    % Get the ' Go' signal
    recording = VSGOLReceiveEyeTrackerCommand;
    firstTime = true;
    while (recording == true)
        % Increment the counter
        totalCounter = totalCounter+1;
        
        % Get a position and send it over to the Mac. This is either 960 ms
        % or 980 ms.
        current = vetGetLatestEyePosition;
        if (firstTime == true)
            matlabUDP('send',num2str(current.timeStamps/1000));
        end
        
        % Pause for 40 ms.
        pause(.04);

        % Determines if the current time stamp is greater than the
        % previous one, if the eyetracker was able to track the eye,
        % and if the subject is looking within a target. If one of
        % these conditiosn fail, than the datapoint is considered an
        % interruption.  Otherwise it is a good measurement
        %
        % Disclaimer: I'm not sure I understand the logic here. (MS,
        % 07/25/2013).
        if ((current.timeStamps > lastTimeStamp) && (current.tracked ~= 0) && VSGOLIsWithinBounds(radius, origin, current.mmPositions))
            % Store the time stamp of the data point and diameter of the pupil
            diameter(good_counter) = current.pupilDiameter;
            time(good_counter) = current.timeStamps;
            
            %Send the values as strings to the Mac Program
            thisData = [num2str(diameter(good_counter)) ' ' num2str(time(good_counter)) ' 0 ' '0'];
            totalData(totalCounter) = {thisData};
            
            % Update the last time stamp for comparison use in the next iteration
            lastTimeStamp = current.timeStamps;
            good_counter = good_counter + 1;
            
            % Data point is considered an interruption. The
            % Timestamp of the point is recorded, and the amount of
            % seconds lost due to interruptions is calculated.
        else
            time_inter(interruption_counter) = current.timeStamps;
            interruption_ratio = (interruption_counter/(interruption_counter+good_counter));
            
            % Blankarray is an array filled with zeroes that
            % correspond to the timestamps of interruption points.
            % These time stmaps are then plotted with blankarray
            % later on.
            interruption_time_seconds = (interruption_ratio*lastTimeStamp);
            
            %Send the timestamps of the interruptions
            thisData = ['0' ' 0 ' '1 ' num2str(time_inter(interruption_counter))];
            totalData(totalCounter) = {thisData};
            
            % Record number of interruption points
            interruption_counter = interruption_counter + 1;
        end
        

        % Stop if we receive the stop signal.
        if matlabUDP('check') == 1
            data = matlabUDP('receive');
            if strcmp(data,'stop')
                matlabUDP('send',sprintf('Trial %f has ended!', i));
                recording = false;
            end
            
        end
        firstTime = false;
    end
    
    % If in OFFLINE mode, stop recording
    if (offline == true)
        vetStopRecording;
    end
    
    % Stop tracking
    vetStopTracking;
    vetDestroyCameraScreen;
    
    % Start the file transfer
    macCommand = 'fubar';
    if (offline == false)
        while (~strcmp(macCommand,'begin transfer'))
            macCommand = VSGOLGetInput;
        end
        
        matlabUDP('send','begin transfer');
        fprintf('Transfer beginning...\n');
        matlabUDP('send',num2str(length(totalData)));
        
        % Iterate over the data
        for y = 1:length(totalData)
            while (~strcmp(macCommand,['transfering ' num2str(y)]))
                macCommand = VSGOLGetInput;
            end
            matlabUDP('send',totalData{y});
        end
        
        % Finish up the transfer
        fprintf('Data transfer for trial %f ending...\n', i);
        
        while (~strcmp(macCommand,'end transfer'))
            macCommand = VSGOLGetInput;
        end
    end
end

%% After the trial, plot out a trace of the data. This is presumably to make sure that everything went ok.
% Calculates average pupil diameter.
average(1:length(time))=mean(diameter);

% Creates a figure with pupil diameter and interruptions over time. Also
% displays the average pupil diameter over time.
fig = plot(time/1000,diameter,'b', time/1000, average, 'g', time_inter/1000, zeros(size(time_inter)),'r.');

% Close the UDP connection
matlabUDP('close');
fprintf('Program completed successfully.\n');
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
%   - VSGOLGetNumberStims
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
else    data = false;
end
end

function params = VSGOLGetStart
% params = VSGOLGetStart
% This function calls VSGOLGetInput which listens for a "start" or "stop" from the
% Mac host. VSGOLProcessCommand will either allow the program to continue or
% close the UDP port respective of the command from the Mac host.
% Continuously checks for input from the Mac machine until data is actually available.
vetStartTracking;
while matlabUDP('check') == 0
    current = vetGetLatestEyePosition;
    if (current.tracked)
        matlabUDP('send','beep');
    else
        matlabUDP('send','no');
    end
    params.run = false;
    pause(.2);
end
vetStopTracking;
command = matlabUDP('receive');
params = VSGOLProcessCommand(params, command);
end

function params = VSGOLEyeTrackerCheck(params)
% params = VSGOLEyeTrackerCheck(params)
% This function calls VSGOLGetInput which listens for a "start" or "stop" from the
% Mac host. VSGOLProcessCommand will either allow the program to continue or
% close the UDP port respective of the command from the Mac host.
% Continuously checks for input from the Mac machine until data is actually available.
vetStopTracking;
pause(2);
vetCreateCameraScreen;
fprintf('Entered VSGOLEyeTrackerCheck');
waiting = VSGOLGetInput;
fprintf('%s',waiting);
pause(1);
if (strcmp(waiting,'startEyeTrackerCheck'))
    vetStartTracking;
    while matlabUDP('check') == 0
        current = vetGetLatestEyePosition;
        if (current.tracked)
            matlabUDP('send','beep');
        else
            matlabUDP('send','no');
        end
        params.run = false;
        %pause(.2);
        pause(.2);
    end
    vetStopTracking;
    vetDestroyCameraScreen;
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
temp = VSGOLGetInput;
matlabUDP('send',sprintf('Permission to begin recording received!!!'));
beginRecording = true;
end

function numStims = VSGOLGetNumberStims
% numStims = VSGOLGetNumberStims
% Get the number of trials from the Mac
temp = VSGOLGetInput;
fprintf('Number of stims (%s) received!',temp);
numStims = str2num(temp);
matlabUDP('send',sprintf('Number of stimuli: %f received!!!',numStims));
end

function offline = VSGOLGetOffline
% offline = VSGOLGetOffline
% Get the oFFLINE flag
temp = VSGOLGetInput;
fprintf('Offline flag received from mac! %s',temp);
if (strcmp('true',temp))
    offline = true;
elseif (strcmp('false',temp))
    offline = false;
else
    offline = 'not_received';
end
matlabUDP('send',sprintf('Flag received by windows! %s',temp));
end

function direction = VSGOLGetDirection
% direction = VSGOLGetDirection
% Get the modulation direction from the Mac. Only used in offline mode.
temp = VSGOLGetInput;
fprintf('Direction received from mac! %s',temp);
if (strcmp('0',temp))
    direction = 'backgroundAdapt';
elseif (strcmp('1',temp))
    direction = 'iso';
elseif (strcmp('2',temp))
    direction = 'lm';
elseif (strcmp('3',temp))
    direction = 'mel';
elseif (strcmp('4',temp))
    direction = 's';
else
    direction = 'no_direction_received';
end
matlabUDP('send',sprintf('Flag received by windows! %s',temp));
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
    %pause(2);
    pause(2);
    
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
        
        %pause(2);
        pause(2);
        vetCreateCameraScreen;
        %pause(2);
        pause(2);
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
                %pause(1);
                pause(1);
                current=vetGetLatestEyePosition;
                % pause(.05);
                pause(1);
            end
            % Calculates the average by summing up all the values, then
            % later dividing it by 10
            sumOfPositions=sumOfPositions+current.mmPositions;
            
        end
        circlepoint(index).average=sumOfPositions/nAvg;
        circlepoint(index).iscalibrated=true;
        
        % Stop tracking
        %pause(1);
        pause(1);
        vetStopTracking;
        %pause(1);
        pause(1);
        
        % Step GET POINT
        % Sends the position name, and the average radius to the mac
        matlabUDP('send', circlepoint(index).position);
        %pause(1);
        pause(1);
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
        %pause(1);
        pause(1);
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
