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
    end
    
    % Receiving initial information from Mac
    fprintf('*** Waiting for Mac to tell us to go\n');
    fprintf('*** Run OLFlickerSensitivity on Mac and select protocol...\n');
    
    % Main Experiment Loop
    % Get start command from Mac
    [communicationError, protocolNameStr] = VSGOLGetProtocolName(UDPobj);
    if (~isempty(communicationError))
        fprintf('Exit due to communication error\n');
        return;
    end
    
%     obsID = VSGOLGetObsID;
%     obsIDAndRun = VSGOLGetObsIDAndRun;

end

function [communicationError, protocolNameStr] = VSGOLGetProtocolName(UDPobj)
    communicationError = [];
    protocolNameStr = [];
    
    dbs = dbstack;
    if length(dbs)>1
        functionName = dbs(1);
    end

    messageLabel = 'Protocol Name';
    response = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf);
    if (~strcmp(response.msgLabel, messageLabel)) 
        communicationError = sprintf('UDP comm got out of SYNC in ''%s'': Expected label: ''%s'', received label: ''%s''.', functionName, messageLabel, response.msgLabel);
        return;
    end
    protocolNameStr = response.msgValue;
    fprintf('<strong>''%s''</strong>:: Protocol name received as: ''%s''.\n', functionName, protocolNameStr);
end

function data = VSGOLGetInput
    % data = VSGOLGetInput Continuously checks for input from the Mac machine
    % until data is actually available.
    %while matlabUDP('check') == 0; end
    %data = matlabUDP('receive');
    
    data = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf);
    
end
