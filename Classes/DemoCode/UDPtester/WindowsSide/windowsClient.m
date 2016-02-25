function windowsClient
    global CRS;
    
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
    
    if (experimentMode)
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
    
    % Compose the program to run : specify sequence of messages (labels) expected to be received from the Mac
    % and the names of variables in which to store the received message values
    programList = {...
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
        programCommand = programList{k};
        messageValue = runProgramCommand(programCommand, UDPobj);
        eval(sprintf('%s = messageValue;', programCommand{2}));
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
        programCommand = programList{k};
        messageValue = runProgramCommand(programCommand, UDPobj);
        eval(sprintf('%s = messageValue;', programCommand{2}));
    end
    
    if (experimentMode)
        if (offline)
            % Figure out paths.

            % Set up the file name of the output file
            saveFile = fullfile(savePath, obsIDAndRun);

            %error('offline mode not implemented at this time.  There is unfinished offline code present in this state of the routine.  This error will be removed once the offline code is completed at a future time.');
        end
    end % experimentMode
    
    
    % print the variables we received
    for k = 1:numel(programList)
        c = programList{k};
        eval(c{2})
    end
    
end

function messageValue = runProgramCommand(programCommand, UDPobj)
    % Wait to receive the expect command from the Mac
    [communicationError, messageValue] = VSGOLGetMessage(UDPobj, programCommand{1});
    % Check for communication error and abort if one occurred
    assert(isempty(communicationError), 'Exiting windows client due to communication error.\n');
end

function [communicationError, protocolNameStr] = VSGOLGetMessage(UDPobj, messageLabel)
    % Reset return args
    communicationError = [];
    protocolNameStr = [];
    
    % Get this function's name
    dbs = dbstack;
    if length(dbs)>1
        functionName = dbs(1).name;
    end
    
    % Wait for ever for a message to be received
    response = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf, 'callingFunctionName', functionName);
    if (~strcmp(response.msgLabel, messageLabel)) 
        communicationError = sprintf('UDP comm got out of SYNC in ''%s'': Expected label: ''%s'', received label: ''%s''.', functionName, messageLabel, response.msgLabel);
        return;
    end
    
    % Get the message value received
    protocolNameStr = response.msgValue;
    
    % Report to user
    fprintf('<strong>''%s''</strong>:: %s received as: ''%s''.\n', functionName, messageLabel, protocolNameStr);
end

function data = VSGOLGetInput
    % data = VSGOLGetInput Continuously checks for input from the Mac machine
    % until data is actually available.
    %while matlabUDP('check') == 0; end
    %data = matlabUDP('receive');
    
    data = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf);
    
end

