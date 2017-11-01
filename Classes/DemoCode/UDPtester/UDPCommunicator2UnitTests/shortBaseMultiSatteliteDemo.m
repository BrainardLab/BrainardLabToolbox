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
    UDPobj.initiateCommunication(hostRoles,  hostNames, triggerMessage, 'beVerbose', beVerbose);

    %% Make the packetSequence for the local host
    if (contains(localHostName, 'manta'))
        packetSequence = designShortPacketSequenceForBase(hostNames, UDPobj.satteliteChannelIDs);
    elseif (contains(localHostName, 'ionean'))
        packetSequence = designShortPacketSequenceForIoneanSattelite(hostNames, UDPobj.satteliteChannelIDs('ionean'));
    elseif (contains(localHostName, 'leviathan'))
        packetSequence = designShortPacketSequenceForLeviathanSattelite(hostNames, UDPobj.satteliteChannelIDs('leviathan'));
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
function packetSequence = designShortPacketSequenceForIoneanSattelite(hostNames, satteliteChannel)

    udpHandle = 0;
    
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Manta sending, Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannel, hostNames,...
        'manta -> ionean', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                                     % Wait for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Manta sending, Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannel, hostNames,...
        'ionean <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
         'timeOutSecs', 1.0, ...                                                    % Wait for 1 secs to receive this message
         'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
         'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannel, hostNames,...
        'manta <- ionean', 'IONEAN_SENDING_SMALL_STRUCT', ...
        'timeOutSecs', 1.0, ...                                                     % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));
end

%
% DESIGN PACKET SEQUENCE FOR LEVIATHAN (SATTELITE)
%
function packetSequence = designShortPacketSequenceForLeviathanSattelite(hostNames, satteliteChannel)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Manta sending, Leviathan receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannel,hostNames,...
        'manta -> leviathan', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                                     % Wait for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Manta sending, Leviathan receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannel, hostNames,...
         'leviathan <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
         'timeOutSecs', 1.0, ...                                                    % Wait for 1 secs to receive this message
         'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
         'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Leviathan sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannel, hostNames,...
        'manta <- leviathan', 'LEVIATHAN_SENDING_SMALL_STRUCT', ...
        'timeOutSecs', 1.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));
end

%
% DESIGN PACKET SEQUENCE FOR BASE (MANTA)
%
function packetSequence = designShortPacketSequenceForBase(hostNames, satteliteChannels)
    % Define the communication  packetSequence
    packetSequence = {};

    %  Manta sending (int: +1), Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannels('ionean'), hostNames,...
        'manta -> ionean', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 1 ...
    );

    %  Manta sending (int: -1), Leviathan receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannels('leviathan'), hostNames,...
        'manta -> leviathan', 'MANTA_SENDING_SINGLE_INTEGER', ...
        'timeOutSecs', 1.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', -1 ...
    );


    % Manta sending (char: tra la la #1), Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannels('ionean'), hostNames,...
        'ionean <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
        'timeOutSecs', 1.0, ...                                                 % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la #1');
    
    % Manta sending (char: tra la la #2), Leviathan receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannels('leviathan'), hostNames,...
        'leviathan <- manta', 'MANTA_SENDING_A_CHAR_STING', ...
        'timeOutSecs', 1.0, ...                                                 % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la #2');
    
    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannels('ionean'), hostNames,...
        'manta <- ionean', 'IONEAN_SENDING_SMALL_STRUCT',...
        'timeOutSecs', 1.0, ...                                                 % Allow for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Leviathan sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannels('leviathan'), hostNames,...
        'manta <- leviathan', 'LEVIATHAN_SENDING_SMALL_STRUCT',...
        'timeOutSecs', 1.0, ...                                                 % Allow for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );
end
