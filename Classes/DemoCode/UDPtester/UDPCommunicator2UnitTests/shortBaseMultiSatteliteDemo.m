function shortBaseMultiSatteliteDemo

    %% Define a 2-sattelite scheme
    baseHostName = 'manta';
    sattelite1HostName = 'leviathan';
    sattelite2HostName = 'ionean';
    
    hostNames       = {baseHostName,    sattelite1HostName,  sattelite2HostName};
    hostIPs         = {'128.91.12.90',  '128.91.12.144',     '128.91.12.155'};
    hostRoles       = {'base',          'sattelite',         'sattelite'};
    
    commPorts       = {nan,              2007,               2008};
        
    %% Define a 1-sattelite scheme
     hostNames       = {baseHostName,    sattelite2HostName};
     hostIPs         = {'128.91.12.90',  '128.91.12.144'};
     hostRoles       = {'base',          'sattelite'};
     commPorts       = {nan,              2008};
    
    %% Control what is printed on the command window
    beVerbose = true;
    displayPackets = true;
    
    %% Instantiate our UDPcommunicator object
    UDPobj = UDPBaseSatteliteCommunicator.instantiateObject(hostNames, hostIPs, hostRoles, commPorts, beVerbose);
    
    %% Make the packetSequences
    if (contains(UDPobj.localHostName, baseHostName))
        if (numel(hostNames) == 3)
            packetSequence = designPacketSequenceForBaseWithTwoSatellites(baseHostName, sattelite1HostName, sattelite2HostName, ...
                UDPobj.satteliteInfo(sattelite1HostName).satteliteChannelID, UDPobj.satteliteInfo(sattelite2HostName).satteliteChannelID);
        elseif (numel(hostNames) == 2)
            packetSequence = designPacketSequenceForBaseWithOneSatellite(baseHostName, UDPobj.satteliteInfo(sattelite1HostName).satteliteChannelID);
        end
        
    elseif (contains(UDPobj.localHostName, sattelite2HostName))
        packetSequence = designPacketSequenceForSattelite2(baseHostName, sattelite2HostName, UDPobj.satteliteInfo(sattelite2HostName).satteliteChannelID);
        
    elseif (contains(UDPobj.localHostName, sattelite1HostName))
        packetSequence = designPacketSequenceForSattelite1(baseHostName, sattelite1HostName, UDPobj.satteliteInfo(sattelite1HostName).satteliteChannelID);
    end
    
    %% Establish the communication
    triggerMessage = 'Go!';
    allSattelitesAreAGOMessage = 'All Sattelites Are A GO!';
    UDPobj.initiateCommunication(hostRoles,  hostNames, triggerMessage, allSattelitesAreAGOMessage, 'beVerbose', beVerbose);

    
    
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
function packetSequence = designPacketSequenceForSattelite1(baseHostName, satteliteHostName, satteliteChannelID)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Base sending
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        sprintf('%s -> %s', baseHostName, satteliteHostName), sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteHostName),...
        'timeOutSecs', 4.0, ...                                                     % Wait for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Base sending
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID,...
        sprintf('%s -> %s', baseHostName, satteliteHostName), sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_A_CHAR_STRING', baseHostName, satteliteHostName),...
        'timeOutSecs', 4.0, ...                                                    % Wait for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite-2 sending
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID,...
        sprintf('%s <- %s', baseHostName, satteliteHostName), sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT', satteliteHostName),...
        'timeOutSecs', 4.0, ...                                                     % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));
end

%
% DESIGN PACKET SEQUENCE FOR LEVIATHAN (SATTELITE)
%
function packetSequence = designPacketSequenceForSattelite2(baseHostName, satteliteHostName, satteliteChannelID)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Base sending
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        sprintf('%s -> %s', baseHostName, satteliteHostName), sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteHostName),...
        'timeOutSecs', 4.0, ...                                                     % Wait for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Base sending 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
         sprintf('%s -> %s', baseHostName, satteliteHostName), sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_A_CHAR_STRING', baseHostName, satteliteHostName),...
         'timeOutSecs', 4.0, ...                                                    % Wait for 1 secs to receive this message
         'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
         'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite-2 sending
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        sprintf('%s <- %s', baseHostName, satteliteHostName), sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT', satteliteHostName),...
        'timeOutSecs', 4.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));
end

%
% DESIGN PACKET SEQUENCE FOR BASE (MANTA) WITH 2 SATTELITES
%
function packetSequence = designPacketSequenceForBaseWithTwoSatellites(baseHostName, sattelite1HostName, sattelite2HostName, sattelite1ChannelID, sattelite2ChannelID)
    % Define the communication  packetSequence
    packetSequence = {};

    % Base sending (int: +1), Sattelite1 receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        sattelite1ChannelID,...
        sprintf('%s -> %s', baseHostName, sattelite1HostName), sprintf('BASE(%s)_TO_SATTELITE-1(%s)___SENDING_SINGLE_INTEGER', baseHostName, sattelite1HostName),...
        'timeOutSecs', 4.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 1 ...
    );

     % Base sending (int: +1), Sattelite2 receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        sattelite2ChannelID, ...
        sprintf('%s -> %s', baseHostName, sattelite2HostName), sprintf('BASE(%s)_TO_SATTELITE-2(%s)___SENDING_SINGLE_INTEGER',baseHostName, sattelite2HostName),...
        'timeOutSecs', 4.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', -1 ...
    );


    % Base sending (char: tra la la #1), Sattelite1 receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        sattelite1ChannelID, ...
        sprintf('%s -> %s', baseHostName, sattelite1HostName), sprintf('BASE(%s)_TO_SATTELITE-1(%s)___SENDING_CHAR_STRING', baseHostName, sattelite1HostName),...
        'timeOutSecs', 4.0, ...                                                 % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la #1');
    
    % Base sending (char: tra la la #2), Sattelite2 receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        sattelite2ChannelID, ...
        sprintf('%s -> %s', baseHostName, sattelite2HostName), sprintf('BASE(%s)_TO_SATTELITE-2(%s)___SENDING_CHAR_STRING',baseHostName, sattelite1HostName), ...
        'timeOutSecs', 4.0, ...                                                 % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la #2');
    
    
    % Sattelite1 sending, Base receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        sattelite1ChannelID, ...
        sprintf('%s <- %s', baseHostName, sattelite1HostName), sprintf('SATTELITE-1(%s)_SENDING_SMALL_STRUCT',sattelite1HostName),...
        'timeOutSecs', 4.0, ...                                                 % Allow for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite2 sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        sattelite2ChannelID, ...
        sprintf('%s <- %s', baseHostName, sattelite2HostName), sprintf('SATTELITE-2(%s)_SENDING_SMALL_STRUCT',sattelite2HostName),...
        'timeOutSecs', 4.0, ...                                                 % Allow for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );
end

%
% DESIGN PACKET SEQUENCE FOR BASE (MANTA) WITH 1 SATTELITE (IONEAN)
%
function packetSequence = designPacketSequenceForBaseWithOneSatellite(baseHostName, satteliteHostName, satteliteChannelID)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Bse sending (int: +1), Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        sprintf('%s -> %s', baseHostName, satteliteHostName), sprintf('BASE(%s)_SENDING_SINGLE_INTEGER',baseHostName), ...
        'timeOutSecs', 4.0, ...                                             % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 1 ...
    );

    % Base sending (char: tra la la #1), Ionean receiving 
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        sprintf('%s -> %s', baseHostName, satteliteHostName), sprintf('BASE(%s)_SENDING_A_CHAR_STING',baseHostName), ...
        'timeOutSecs', 4.0, ...                                                 % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la #1');
    
    % Ionean sending, Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        sprintf('%s <- %s', baseHostName, satteliteHostName), sprintf('SATTELITE(%s)_SENDING_SMALL_STRUCT',satteliteHostName),...
        'timeOutSecs', 4.0, ...                                                 % Allow for 1 secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );
end

