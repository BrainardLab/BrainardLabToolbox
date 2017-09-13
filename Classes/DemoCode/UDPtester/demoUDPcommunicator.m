function demoUDPcommunicator

    % Get computer info
    systemInfo = GetComputerInfo();
    
    %% Instantiate a UDPcommunicator object according to computer name
    % In this demo we have IPs for 2 computers: manta.psych.upenn.edu and ionean.psych.upenn.edu
    if (strfind(systemInfo.networkName, 'manta'))
        UDPobj = UDPcommunicator( ...
            'localIP',   '128.91.12.90', ...    % REQUIRED: the IP of manta.psych.upenn.edu (local host)
            'remoteIP',  '128.91.12.144', ...   % REQUIRED: the IP of ionean.psych.upenn.edu (remote host)
            'verbosity', 'max', ...             % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
            'useNativeUDP', false ...           % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    elseif (strfind(systemInfo.networkName, 'ionean'))
        UDPobj = UDPcommunicator( ...
        'localIP',   '128.91.12.144', ...       % REQUIRED: the IP of ionean.psych.upenn.edu (local host)
        'remoteIP',  '128.91.12.90', ...        % REQUIRED: the IP of manta.psych.upenn.edu (remote host)
        'verbosity', 'max', ...                 % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        'useNativeUDP', false ...               % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    else
        error('No configuration for computer named ''s''.', systemInfo.networkName);
    end

    %% We begin by setting up 'manta' as a slave (listener) and 'ionean' as master (emitter)
    % Configure the message we are expecting and how long we should wait for it
    syncMessage = 'GO !';
    if (strfind(systemInfo.networkName, 'manta'))
        fprintf('Ready to receive the sync message from the master computer\n');
        % Wait for ever to receive the syncMessage
        receiverTimeOutSecs = Inf;   
        % Start listening
        messageReceived = UDPobj.waitForMessage(syncMessage, ...
            'timeOutSecs', receiverTimeOutSecs...
            );
        % Feedback to user
        {'Message Received', messageReceived.msgLabel, messageReceived.msgValue, messageReceived.msgValueType, messageReceived.timeOutFlag};
    else
        fprintf('Is ''%s'' running on the slave computer?. Hit enter if so.\n', mfilename);
        pause;
        % Wait for 4 secs to receive ack that the syncMessage was received
        acknowledgmentTimeOutSecs = 4;   
        % Send the SYNC message
        ackReceived = UDPobj.sendMessage(syncMessage, ...
            'timeOutSecs', acknowledgmentTimeOutSecs, ...
            'maxAttemptsNum', 1 ...
        );
        % Feedback to user
        fprintf('''%s'' sent ''%s'' and received the following acknowledgment: ''%s''\n', systemInfo.networkName, syncMessage, ackReceived);
    end

    UDPobj.shutDown();
end

