function runModulationTrialSequencePupillometryNulled

    experimentMode = false;
    
    [rootDir, ~] = fileparts(fullfile(which(mfilename)));
    cd(rootDir); addpath('../Common');
    
    clc
    fprintf('\nStarting ''%s''\n', mfilename);
    
    % Instantiate a UDPcommunictor object
    udpParams = getUDPparams('NicolasOffice');
    UDPobj = UDPcommunicator( ...
          'localIP', udpParams.macHostIP, ...
         'remoteIP', udpParams.winHostIP, ...
          'udpPort', udpParams.udpPort, ...      % optional with default 2007
        'verbosity', 'min' ...             % optional with possible values {'min', 'normal', 'max'}, and default 'normal'
        );
    
    params.protocolName = 'ModulationTrialSequencePupillometryNulled';
    [communicationError] = OLVSGSendProtocolName(UDPobj, params.protocolName);
    if (~isempty(communicationError))
        fprintf('Exit due to communication error\n');
        return;
    end
    
            
end

function [communicationError] = OLVSGSendProtocolName(UDPobj, protocolName)
    communicationError = [];
    messageLabel = 'Protocol Name';
    
    status = UDPobj.sendMessage(messageLabel, 'withValue', protocolName, 'timeOutSecs', 2, 'maxAttemptsNum', 3);
    % check status for errors
    if (~strcmp(status, UDPobj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED)) 
        communicationError = sprintf('Transmitted and expected (by the other end) messages do not match! sendMessage() returned with this message: ''%s''\n', status);
    end
end
