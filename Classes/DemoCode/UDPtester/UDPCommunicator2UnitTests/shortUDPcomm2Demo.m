function shortUDPcomm2Demo

    %% Define the host names, IPs, and roles
    % In this demo we have IPs for manta.psych.upenn.edu and ionean.psych.upenn.edu
    hostNames       = {'manta',         'ionean'};
    hostIPs         = {'128.91.12.90',  '128.91.12.144'};
    hostRoles       = {'master',        'slave'};
    
    %% Get computer name
    localHostName = UDPcommunicator2.getLocalHostName();
    
    %% Control what is printed on the command window
    beVerbose = false;
    displayPackets = true;
    
    %% Instantiate our UDPcommunicator object
    UDPobj = UDPcommunicator2.instantiateObject(localHostName, hostNames, hostIPs, 'beVerbose', beVerbose);
    
    %% Establish the communication
    triggerMessage = 'Go!';
    UDPobj.initiateCommunication(localHostName, hostRoles,  hostNames, triggerMessage, 'beVerbose', beVerbose);
    
    %% Make the packetSequence for the local host
    if (contains(localHostName, 'manta'))
        packetSequence = designShortPacketSequenceForManta(hostNames);
    else
        packetSequence = designShortPacketSequenceForIonean(hostNames);
    end
    
    for packetNo = 1:numel(packetSequence)
        [theMessageReceived, theCommunicationStatus, roundTipDelayMilliSecs] = ...
            UDPobj.communicate(...
                localHostName, packetNo, packetSequence{packetNo}, ...
                'beVerbose', beVerbose, ...
                'displayPackets', displayPackets...
             );
         theMessageReceived
    end % packetNo
end

function packetSequence = designShortPacketSequenceForIonean(hostNames)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Manta sending, Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta -> ionean', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                         % Wait for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Manta sending, Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
         'timeOutSecs', 1.0, ...                                        % Wait for 1 secs to receive this message
         'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
         'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta <- ionean', 'IONEAN_SENDING_SMALL_STRUCT', ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));
end


function packetSequence = designShortPacketSequenceForManta(hostNames)
    % Define the communication  packetSequence
    packetSequence = {};

    %  Manta sending, Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta -> ionean', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 1 ...
    );

    % Manta sending, Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la #1');
    
    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta <- ionean', 'IONEAN_SENDING_SMALL_STRUCT',...
        'timeOutSecs', 1.0, ...                                         % Allow for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

end
