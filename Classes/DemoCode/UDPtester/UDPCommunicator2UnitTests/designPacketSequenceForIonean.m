function packetSequence = designPacketSequenceForIonean(hostNames)
    % Define the communication  packetSequence
    packetSequence = {};
    
    spatialSupport = linspace(-1,1,17);
    XY = meshgrid(spatialSupport , spatialSupport);
    sigmaX = 0.2;
    sigmaY = 0.33;
    rfStruct = struct(...
        'neuronID', 0, ...
        'rf', exp(-0.5*((XY/sigmaX).^2) + (XY/sigmaY).^2));
    
    rfStructTmp.neuronID = 1;
    rfStructTmp.rf = rfStruct.rf .* (1+0.2*randn(size(rfStruct.rf)));
    rfStructTmp.rf = rfStructTmp.rf / max(abs(rfStructTmp.rf(:)));

    % Manta sending, Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta -> ionean', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                         % Wait for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta <- ionean', 'IONEAN_SENDING_SMALL_STRUCT', ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));

    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta <- ionean', 'IONEAN_SENDING_A_MATRIX', ...
        'timeOutSecs', 10.0, ...                                         % Allow 10 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...             % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('theMatrix', rand(23,50,3)));
    
    % Manta sending, Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
         'timeOutSecs', 1.0, ...                                        % Wait for 1 secs to receive this message
         'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
         'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );
   
    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean -> manta', 'IONEAN_SENDING_RF_DATA', ...
        'timeOutSecs', 1.0, ...                                        % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', rfStructTmp);
end
