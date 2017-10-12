function shortUDPcomm2Demo

    %% Define the host names, IPs, and roles
    % In this demo we have IPs for gka06.psych.upenn.edu and Monkfish.psych.upenn.edu
    hostNames       = {'gka06',         'monkfish'};
    hostIPs         = {'128.91.12.160',  '128.91.12.161'};
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
    if (contains(localHostName, 'gka06'))
        packetSequence = designShortPacketSequenceForGKA06(hostNames);
    else
        packetSequence = designShortPacketSequenceForMonkfish(hostNames);
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

function packetSequence = designShortPacketSequenceForMonkfish(hostNames)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % GKA06 sending, Monkfish receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'gka06 -> monkfish', 'gka06_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                         % Wait for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.THROW_ERROR ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

    % gka06 sending, Monkfish receiving 
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'monkfish <- gka06', 'gka06_SENDING_A_CHAR_STING', ...
         'timeOutSecs', 1.0, ...                                        % Wait for 1 secs to receive this message
         'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
         'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Monkfish sending, gka06 receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'gka06 <- monkfish', 'Monkfish_SENDING_SMALL_STRUCT', ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));
end


function packetSequence = designShortPacketSequenceForGKA06(hostNames)
    % Define the communication  packetSequence
    packetSequence = {};

    %  gka06 sending, Monkfish receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'gka06 -> monkfish', 'gka06_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 1 ...
    );

    % gka06 sending, Monkfish receiving 
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'monkfish <- gka06', 'gka06_SENDING_A_CHAR_STING', ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la #1');
    
    % Monkfish sending, gka06 receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'gka06 <- monkfish', 'Monkfish_SENDING_SMALL_STRUCT',...
        'timeOutSecs', 1.0, ...                                         % Allow for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

end
