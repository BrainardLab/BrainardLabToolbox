function shortBaseMultiSatteliteDemo

    %% Define the host names, IPs, roles, and communication port numbers
    hostNames       = {'manta',         'ionean',         'leviathan'};
    hostIPs         = {'128.91.12.90',  '128.91.12.144',  '128.91.12.155'};
    hostRoles       = {'base',          'sattelite',      'sattelite'};
    commPorts       = {nan,              2007,             2008};
        
   
    %% Control what is printed on the command window
    beVerbose = true;
    displayPackets = true;
    
    %% Instantiate our UDPcommunicator object
    UDPobj = UDPBaseSatteliteCommunicator.instantiateObject(hostNames, hostIPs, hostRoles, commPorts, beVerbose);
    
    %% Establish the communication
    triggerMessage = 'Go!';
    allSattelitesAreAGOMessage = 'All Sattelites Are A GO!';
    UDPobj.initiateCommunication(hostRoles,  hostNames, triggerMessage, allSattelitesAreAGOMessage, 'beVerbose', beVerbose);

    %% Make the packetSequence for the local host
    if (contains(UDPobj.localHostName, 'manta'))
        packetSequence = designShortPacketSequenceForBase(hostNames, UDPobj.satteliteInfo);
    elseif (contains(UDPobj.localHostName, 'ionean'))
        packetSequence = designShortPacketSequenceForIoneanSattelite(hostNames, UDPobj.satteliteInfo('ionean').satteliteChannelID);
    elseif (contains(UDPobj.localHostName, 'leviathan'))
        packetSequence = designShortPacketSequenceForLeviathanSattelite(hostNames, UDPobj.satteliteInfo('ionean').satteliteChannelID);
    end
    
    for packetNo = 1:numel(packetSequence)
        [theMessageReceived, theCommunicationStatus, roundTipDelayMilliSecs] = ...
            UDPobj.communicate(packetNo, packetSequence{packetNo}, ...
                'beVerbose', beVerbose, ...
                'displayPackets', displayPackets...
             );
         theMessageReceived
    end % packetNo
end

%
% DESIGN PACKET SEQUENCE FOR IONEAN (SATTELITE)
%
function packetSequence = designShortPacketSequenceForIoneanSattelite(hostNames, satteliteChannelID)

    udpHandle = 0;
    
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Manta sending, Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, hostNames,...
        'manta -> ionean', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                                     % Wait for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Manta sending, Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, hostNames,...
        'ionean <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
         'timeOutSecs', 1.0, ...                                                    % Wait for 1 secs to receive this message
         'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
         'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, hostNames,...
        'manta <- ionean', 'IONEAN_SENDING_SMALL_STRUCT', ...
        'timeOutSecs', 1.0, ...                                                     % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));
end

%
% DESIGN PACKET SEQUENCE FOR LEVIATHAN (SATTELITE)
%
function packetSequence = designShortPacketSequenceForLeviathanSattelite(hostNames, satteliteChannelID)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Manta sending, Leviathan receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, hostNames,...
        'manta -> leviathan', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                                     % Wait for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Manta sending, Leviathan receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, hostNames,...
         'leviathan <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
         'timeOutSecs', 1.0, ...                                                    % Wait for 1 secs to receive this message
         'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
         'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Leviathan sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, hostNames,...
        'manta <- leviathan', 'LEVIATHAN_SENDING_SMALL_STRUCT', ...
        'timeOutSecs', 1.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));
end

%
% DESIGN PACKET SEQUENCE FOR BASE (MANTA)
%
function packetSequence = designShortPacketSequenceForBase(hostNames, satteliteInfo)
    % Define the communication  packetSequence
    packetSequence = {};

    %  Manta sending (int: +1), Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteInfo('ionean').satteliteChannelID, hostNames,...
        'manta -> ionean', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 1 ...
    );

    %  Manta sending (int: -1), Leviathan receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteInfo('leviathan').satteliteChannelID, hostNames,...
        'manta -> leviathan', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', -1 ...
    );


    % Manta sending (char: tra la la #1), Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteInfo('ionean').satteliteChannelID, hostNames,...
        'ionean <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
        'timeOutSecs', 1.0, ...                                                 % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la #1');
    
    % Manta sending (char: tra la la #2), Leviathan receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteInfo('leviathan').satteliteChannelID, hostNames,...
        'leviathan <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
        'timeOutSecs', 1.0, ...                                                 % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la #2');
    
    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteInfo('ionean').satteliteChannelID, hostNames,...
        'manta <- ionean', 'IONEAN_SENDING_SMALL_STRUCT',...
        'timeOutSecs', 1.0, ...                                                 % Allow for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Leviathan sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteInfo('leviathan').satteliteChannelID, hostNames,...
        'manta <- leviathan', 'LEVIATHAN_SENDING_SMALL_STRUCT',...
        'timeOutSecs', 1.0, ...                                                 % Allow for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );
end
