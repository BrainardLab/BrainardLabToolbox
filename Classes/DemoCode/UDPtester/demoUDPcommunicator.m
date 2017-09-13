function demoUDPcommunicator
    clc;
    
    % Get computer info
    systemInfo = GetComputerInfo();
    
    %% Instantiate a UDPcommunicator object according to computer name
    % In this demo we have IPs for 2 computers: manta.psych.upenn.edu and ionean.psych.upenn.edu
    if (strfind(systemInfo.networkName, 'manta'))
        UDPobj = UDPcommunicator( ...
            'localIP',   '128.91.12.90', ...    % REQUIRED: the IP of manta.psych.upenn.edu (local host)
            'remoteIP',  '128.91.12.144', ...   % REQUIRED: the IP of ionean.psych.upenn.edu (remote host)
            'verbosity', 'normal', ...             % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
            'useNativeUDP', false ...           % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    elseif (strfind(systemInfo.networkName, 'ionean'))
        UDPobj = UDPcommunicator( ...
        'localIP',   '128.91.12.144', ...       % REQUIRED: the IP of ionean.psych.upenn.edu (local host)
        'remoteIP',  '128.91.12.90', ...        % REQUIRED: the IP of manta.psych.upenn.edu (remote host)
        'verbosity', 'normal', ...                 % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        'useNativeUDP', false ...               % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    else
        error('No configuration for computer named ''%s''.', systemInfo.networkName);
    end

    %% Set up'manta' as the slave (listener) and 'ionean' as the master (emitter)
    % Configure the communication trigger message 
    triggerMessage = struct('label', 'GO !', 'value', 'now');
    
    if (strfind(systemInfo.networkName, 'manta'))
        startSlaveCommunication(UDPobj, triggerMessage);
    else
        fprintf('Is ''%s'' running on the slave computer?. Hit enter if so.\n', mfilename); pause; clc;
        startMasterCommunication(UDPobj, triggerMessage);
    end

    UDPobj.shutDown();
end


function startSlaveCommunication(UDPobj, expectedMessage)
    % Wait for ever to receive the syncMessage
    receiverTimeOutSecs = Inf;   
    % Start listening
    messageReceived = UDPobj.waitForMessage(expectedMessage.label, ...
        'timeOutSecs', receiverTimeOutSecs...
        );
    % Assert that we received the expected message value
    assert(strcmp(messageReceived.msgValue,expectedMessage.value), 'expected and received message values differ');
end

% Method that triggers the communication by sending a SYNC message.
% This methods waits to receive acknowledgment with a timeout period of 4 seconds
function startMasterCommunication(UDPobj, messageToTransmit)
    % Wait for 4 secs to receive an ack that the syncMessage was received
    acknowledgmentTimeOutSecs = 4;   
    % Send the message
    status = UDPobj.sendMessage(messageToTransmit.label, messageToTransmit.value, ...
        'timeOutSecs', acknowledgmentTimeOutSecs, ...
        'maxAttemptsNum', 1 ...
    );
    assert(~strcmp(status,'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT'), 'Timed out waiting for acknowledgment');
end
