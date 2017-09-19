function packetSequence = designPacketSequenceForManta(hostNames)
    % Define the communication  packetSequence
    packetSequence = {};

    %  Manta sending, Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta -> ionean', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 1 ...
    );

     % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta <- ionean', 'IONEAN_SENDING_SMALL_STRUCT',...
        'timeOutSecs', 1.0, ...                                         % Allow for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Manta sending, Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta -> ionean', 'MANTA_SENDING_A_MATRIX', ...
        'timeOutSecs', 30.0, ...                                         % Allow 10 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...             % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('theMatrix', uint8(127+randn(20,40,3)*30)) ...
    );
    
     % Manta sending, Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la');

    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean -> manta', 'IONEAN_SENDING_RF_DATA', ...
        'timeOutSecs', 1, ...                                           % Wait for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );
end