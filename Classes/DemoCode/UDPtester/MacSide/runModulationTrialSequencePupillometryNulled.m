function runModulationTrialSequencePupillometryNulled

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
        'obsIDandRun', 'nicolas 10', ...
        'nTrials', 10, ...,
        'whichTrialToStartAt', 3, ...
        'VSGOfflineMode', true ...
    );
    

    % Compose the program to run: sequence of commands to transmit to Windows
    programList = {...
            {'Protocol Name',       params.protocolName} ...  % {messageLabel, messageValue}
            {'Observer ID',         params.obsID} ...
            {'Observer ID and Run', params.obsIDandRun} ...
            {'Number of Trials',    params.nTrials} ...
            {'Starting Trial No',   params.whichTrialToStartAt} ...
            {'Offline',             params.VSGOfflineMode}
    };

    % Run program
    for k = 1:numel(programList)
        [communicationError] = OLVSGSendMessage(UDPobj, programList{k});
        assert(isempty(communicationError), 'Exiting ''%s'' due to communication error.\n', mfilename);
    end

    
            
end

function [communicationError] = OLVSGSendMessage(UDPobj, messageTuple)
    % unwrap message
    messageLabel = messageTuple{1};
    messageValue = messageTuple{2};
    
    % Reset return args
    communicationError = [];
    
    % Get this function's name
    dbs = dbstack;
    if length(dbs)>1
        functionName = dbs(1).name;
    end
    
    status = UDPobj.sendMessage(messageLabel, 'withValue', messageValue, 'timeOutSecs', 2, 'maxAttemptsNum', 3, 'callingFunctionName', functionName);
    % check status for errors
    if (~strcmp(status, UDPobj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED)) 
        communicationError = sprintf('Transmitted and expected (by the other end) messages do not match! sendMessage() returned with this message: ''%s''\n', status);
    end
end
