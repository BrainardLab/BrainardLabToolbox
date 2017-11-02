function shortBaseMultiSatteliteDemo

    %% Start fresh
    fprintf('\nClearing stuff\n');
    clear all;
    fprintf('\n\n');
    
    %% Define a 2-sattelite scheme
    baseHostName = 'manta';
    sattelite1HostName = 'ionean';
    sattelite2HostName = 'gka06';
    sattelite3HostName = 'monkfish';
    
    %% Define a 3-sattelite scheme
    hostNames       = {baseHostName,    sattelite1HostName,  sattelite2HostName,  sattelite3HostName};
    hostIPs         = {'128.91.12.90',  '128.91.12.144',     '128.91.12.160',     '128.91.12.161'};
    hostRoles       = {'base',          'sattelite',         'sattelite',         'sattelite'};
    
    %% Control what is printed on the command window
    beVerbose = false;
    displayPackets = true;
    
    %% Instantiate the UDPBaseSatteliteCommunicator object
    UDPobj = UDPBaseSatteliteCommunicator.instantiateObject(hostNames, hostIPs, hostRoles, beVerbose);
    
    
    %% Use 10 second time out for all comms
    timeOutSecs = 30;
    
    %% Make the packetSequences for the base
    if (contains(UDPobj.localHostName, baseHostName))
        satteliteNames = {...
            sattelite1HostName, ...
            sattelite2HostName, ...
            sattelite3HostName};
        satteliteChannelIDs = {...
            UDPobj.satteliteInfo(sattelite1HostName).satteliteChannelID, ...
            UDPobj.satteliteInfo(sattelite2HostName).satteliteChannelID, ...
            UDPobj.satteliteInfo(sattelite3HostName).satteliteChannelID, ...
            };
        packetSequence = designPacketSequenceForBase(baseHostName, ...
                satteliteNames,...
                satteliteChannelIDs, ...
                timeOutSecs);    
    end
    
    %% Make the packetSequences for the sattelite(s)
    if (contains(UDPobj.localHostName, sattelite3HostName))
        packetSequence = designPacketSequenceForSattelite3(baseHostName, ...
            sattelite3HostName, ...
            UDPobj.satteliteInfo(sattelite3HostName).satteliteChannelID, ...
            timeOutSecs);
    
    elseif (contains(UDPobj.localHostName, sattelite2HostName))
        packetSequence = designPacketSequenceForSattelite2(baseHostName, ...
            sattelite2HostName, ...
            UDPobj.satteliteInfo(sattelite2HostName).satteliteChannelID, ...
            timeOutSecs);
        
    elseif (contains(UDPobj.localHostName, sattelite1HostName))
        packetSequence = designPacketSequenceForSattelite1(baseHostName, ...
            sattelite1HostName, ...
            UDPobj.satteliteInfo(sattelite1HostName).satteliteChannelID, ...
            timeOutSecs);
    end
    
    %% Establish the base / multi-sattelite communication
    triggerMessage = 'Go!';
    allSattelitesAreAGOMessage = 'All Sattelites Are A GO!';
    UDPobj.initiateCommunication(hostRoles,  hostNames, triggerMessage, allSattelitesAreAGOMessage, 'beVerbose', beVerbose);
    
    if (UDPobj.localHostIsBase)
        videoOBJ = VideoWriter('UDPdata.mp4', 'MPEG-4'); % H264 format
    	videoOBJ.FrameRate = 30; 
        videoOBJ.Quality = 100;
        videoOBJ.open();
    end
    
    %% Execute communication protocol
    for packetNo = 1:numel(packetSequence)
        [theMessageReceived, theCommunicationStatus, roundTipDelayMilliSecs] = ...
            UDPobj.communicate(packetNo, packetSequence{packetNo}, ...
                'beVerbose', beVerbose, ...
                'displayPackets', displayPackets...
             );
         
         % If we are the base, plot what we receive from our sattelites
         if (UDPobj.localHostIsBase)
             if (packetNo == 1)
                radial_coeff = [];
                cos_coeff = [];
                sin_coeff = [];
                dataP = 0;
                sat1 = [];
                sat2 = [];
                sat3 = [];
                hFig = figure(1); clf;
                set(hFig, 'Position', [1000 918 560 420], 'Color', [1 1 1])
             end
             
             if (~isempty(theMessageReceived))
                 if (contains(theMessageReceived.label, 'SIN_COEFF'))
                     sin_coeff = cat(1,sin_coeff, theMessageReceived.data);
                     dataP = dataP + 1;
                     sat1 = cat(1,sat1, sin_coeff );
                     sat2 = cat(1,sat2, 0);
                     sat3 = cat(1,sat3, 0);
                 end
                 if (contains(theMessageReceived.label, 'COS_COEFF'))
                     cos_coeff = cat(1,cos_coeff, theMessageReceived.data);
                     dataP = dataP + 1;
                     sat2 = cat(1,sat2, cos_coeff);
                     sat1 = cat(1,sat1, 0);
                     sat3 = cat(1,sat3, 0);
                 end
                 if (contains(theMessageReceived.label, 'RADIAL_COEFF'))
                     radial_coeff = cat(1,radial_coeff, theMessageReceived.data);
                     dataP = dataP + 1;
                     sat3 = cat(1,sat3, radial_coeff);
                     sat1 = cat(1,sat1, 0);
                     sat2 = cat(1,sat2, 0);
                 end

                 dataPoints = min([numel(sin_coeff) numel(cos_coeff) numel(radial_coeff)]);
                 if (dataPoints > 0)
                     x = radial_coeff(1:dataPoints).*cos_coeff(1:dataPoints);
                     y = radial_coeff(1:dataPoints).*sin_coeff(1:dataPoints);
                     maxRange = max([max(abs(x(:))) max(abs(y(:)))]);
                     subplot(1,2,1);
                     plot(x,y, '-', 'LineWidth', 5.0, 'Color', [0.7 0.7 0.4]); hold on; plot(x,y, '*-', 'LineWidth', 1.5); hold off;
                     set(gca, 'XLim', maxRange * [-1 1], 'YLim', maxRange * [-1 1]);
                     axis 'square';
                     grid 'on'
                     grid on
                     subplot(1,2,2);
                     stem(1:numel(sat1), sat1, 'ro'); hold on
                     stem(1:numel(sat2), sat2, 'mo');
                     stem(1:numel(sat3), sat3, 'bo'); hold off
                     set(gca, 'XLim', [1 300], 'YLim', [-1 1]);
                     legend('sat-1', 'sat-2', 'sat-3');
                     drawnow;
                    videoOBJ.writeVideo(getframe(hFig));
                 end
             end % ~isempty
         end % if we are base
         
    end % packetNo
    
    if (UDPobj.localHostIsBase)
        videoOBJ.close();
    end
end

%
% DESIGN PACKET SEQUENCE FOR SATTELITE-1
%
function packetSequence = designPacketSequenceForSattelite1(baseHostName, satteliteHostName, satteliteChannelID, timeOutSecs)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Sattelite receiving from Base
    direction = sprintf('%s -> %s', baseHostName, satteliteHostName);
    expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteHostName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction, ...
        expectedMessageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                             % Wait for this many secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite receiving from Base
    direction = sprintf('%s -> %s', baseHostName, satteliteHostName); 
    expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satteliteHostName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID,...
        direction, ...
        expectedMessageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                            % Wait for this many secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite sending to Base
    direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT', satteliteHostName);
    messageData = struct('a', 12, 'b', [1 2 3; 4 5 6; 7 8 9]);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite sending to Base 100 cosine coefficients
    for k = 1:100
        
        % Sattelite waits to receive trigger message from Base to send next cos-coefficient
        direction = sprintf('%s -> %s', baseHostName, satteliteHostName); 
        expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_COS_COEFF', baseHostName, satteliteHostName);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID,...
            direction, ...
            expectedMessageLabel, ...
            'timeOutSecs', timeOutSecs, ...                                            % Wait for this many secs to receive this message
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
            'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );

        direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_COS_COEFF', satteliteHostName);
        messageData = cos(2*pi*k/100);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID, ...
            direction, ...
            messageLabel, 'withData', messageData, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    end
    
end

%
% DESIGN PACKET SEQUENCE FOR SATTELITE-2
%
function packetSequence = designPacketSequenceForSattelite2(baseHostName, satteliteHostName, satteliteChannelID, timeOutSecs)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Sattelite receiving from Base
    direction = sprintf('%s -> %s', baseHostName, satteliteHostName);
    expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteHostName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction, ...
        expectedMessageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                             % Wait for this many secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite receiving from Base
    direction = sprintf('%s -> %s', baseHostName, satteliteHostName);
    expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satteliteHostName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction, ...
        expectedMessageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                                    % Wait for this many secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite sending to Base
    direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT', satteliteHostName);
    messageData = struct('a', 12, 'b', [10 20; 30 40; 50 60; 70 80; 90 100]);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction,...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                    % Allow this many secs to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
   );

    % Sattelite sending to Base 100 sine coefficients
    for k = 1:100
        
        % Sattelite waits to receiv trigger message from Base to send next sin-coefficient
        direction = sprintf('%s -> %s', baseHostName, satteliteHostName);
        expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_SIN_COEFF', baseHostName, satteliteHostName);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction, ...
        expectedMessageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                                    % Wait for this many secs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );

        direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_SIN_COEFF', satteliteHostName);
        messageData = sin(2*pi*k/100);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID, ...
            direction, ...
            messageLabel, 'withData', messageData, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    end
    
end

%
% DESIGN PACKET SEQUENCE FOR SATTELITE-3
%
function packetSequence = designPacketSequenceForSattelite3(baseHostName, satteliteHostName, satteliteChannelID, timeOutSecs)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Sattelite receiving from Base
    direction = sprintf('%s -> %s', baseHostName, satteliteHostName);
    expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteHostName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction,...
        expectedMessageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                             % Wait for timeOutSecsto receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite receiving from Base
    direction =  sprintf('%s -> %s', baseHostName, satteliteHostName);
    expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satteliteHostName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction, ...
        expectedMessageLabel,...
        'timeOutSecs', timeOutSecs, ...                                            % Wait for timeOutSecs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite sending to Base
    direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT', satteliteHostName);
    messageData = struct('a', 12, 'b', rand(5,5));
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                    % Allow timeOutSecs  to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite sending to Base 100 radial coefficients
    for k = 1:100
        
        % Sattelite waits to receive message from Base to send next radial coeff
        direction =  sprintf('%s -> %s', baseHostName, satteliteHostName);
        expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_RADIAL_COEFF', baseHostName, satteliteHostName);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID, ...
            direction, ...
            expectedMessageLabel,...
            'timeOutSecs', timeOutSecs, ...                                            % Wait for timeOutSecs to receive this message
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
            'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );

        direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_RADIAL_COEFF', satteliteHostName);
        messageData = 1-(k/100)*0.4;
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID, ...
            direction, ...
            messageLabel, 'withData', messageData, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    end
    
end


%
% DESIGN PACKET SEQUENCE FOR BASE
%
function packetSequence = designPacketSequenceForBase(baseHostName, satteliteHostNames, satteliteChannelIDs, timeOutSecs)
    % Define the communication  packetSequence
    packetSequence = {};

    % Base sending to Sattelite-1 the number pi
    satteliteChannelID = satteliteChannelIDs{1};
    satteliteName = satteliteHostNames{1};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteName);
    messageData = pi;
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID,...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                    % Allow timeOutSecsto receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Base sending to Sattelite-2 the number pi^2
    satteliteName = satteliteHostNames{2};
    satteliteChannelID = satteliteChannelIDs{2};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteName);
    messageData = pi^2;
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID,...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                     % Allow timeOutSecs to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 2 ...
    );

    % Base sending to Sattelite-3 the number sqrt(pi)
    satteliteName = satteliteHostNames{3};
    satteliteChannelID = satteliteChannelIDs{3};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteName);
    messageData = sqrt(pi);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID,...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                     % Allow timeOutSecs to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 3 ...
    );

    % Base sending to Sattelite-1 the string "tra la la #1"
    satteliteName = satteliteHostNames{1};
    satteliteChannelID = satteliteChannelIDs{1};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satteliteName);
    messageData = 'tra la la #1';
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction,...
        messageLabel,  'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                        % Allow timeOutSecs to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );
    
    % Base sending to Sattelite-2 the string "tra la la #2"
    satteliteName = satteliteHostNames{2};
    satteliteChannelID = satteliteChannelIDs{2};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satteliteName);
    messageData = 'tra la la #2';
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction,...
        messageLabel,  'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                        % Allow timeOutSecs to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );
    
    % Base sending to Sattelite-3 the string "tra la la #3"
    satteliteName = satteliteHostNames{3};
    satteliteChannelID = satteliteChannelIDs{3};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satteliteName);
    messageData = 'tra la la #3';
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction,...
        messageLabel,  'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                        % Allow timeOutSecsto receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR}));
    );
    
    % Sattelite1 sending struct to base
    satteliteName = satteliteHostNames{1};
    satteliteChannelID = satteliteChannelIDs{1};
    direction = sprintf('%s <- %s', baseHostName, satteliteName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT',satteliteName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction,...
        messageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                         % Allow timeOutSecs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite2 sending struct to base
    satteliteName = satteliteHostNames{2};
    satteliteChannelID = satteliteChannelIDs{2};
    direction = sprintf('%s <- %s', baseHostName, satteliteName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT',satteliteName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction,...
        messageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                         % Allow timeOutSecs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite3 sending struct to base
    satteliteName = satteliteHostNames{3};
    satteliteChannelID = satteliteChannelIDs{3};
    direction = sprintf('%s <- %s', baseHostName, satteliteName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT',satteliteName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteChannelID, ...
        direction, ...
        messageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                         % Allow timeOutSecs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    for k = 1:100
        % Tell sattelite-1 to send next cos-coefficient
        satteliteHostName = satteliteHostNames{1};
        satteliteChannelID = satteliteChannelIDs{1};
        direction = sprintf('%s -> %s', baseHostName, satteliteHostName); 
        messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_COS_COEFF', baseHostName, satteliteHostName);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID,...
            direction, ...
            messageLabel, 'withData', 'right now, please',...
            'timeOutSecs', timeOutSecs, ...                                            % Wait for this many secs to receive this message
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
            'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    
        % Read cos-coeff from sattelite-1
        satteliteHostName = satteliteHostNames{1};
        satteliteChannelID = satteliteChannelIDs{1};
        direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_COS_COEFF', satteliteHostName);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID, ...
            direction, ...
            messageLabel, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    
    
        % Tell sattelite-2 to send next sin-coefficient
        satteliteHostName = satteliteHostNames{2};
        satteliteChannelID = satteliteChannelIDs{2};
        direction = sprintf('%s -> %s', baseHostName, satteliteHostName); 
        messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_SIN_COEFF', baseHostName, satteliteHostName);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID,...
            direction, ...
            messageLabel, 'withData', 'right now, please',...
            'timeOutSecs', timeOutSecs, ...                                            % Wait for this many secs to receive this message
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
            'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    
        % Read sin-coeff from sattelite-2
        satteliteHostName = satteliteHostNames{2};
        satteliteChannelID = satteliteChannelIDs{2};
        direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_SIN_COEFF', satteliteHostName);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID, ...
            direction, ...
            messageLabel, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );

    
        % Tell sattelite-3 to send next sin-coefficient
        satteliteHostName = satteliteHostNames{3};
        satteliteChannelID = satteliteChannelIDs{3};
        direction = sprintf('%s -> %s', baseHostName, satteliteHostName); 
        messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_RADIAL_COEFF', baseHostName, satteliteHostName);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID,...
            direction, ...
            messageLabel, 'withData', 'right now, please',...
            'timeOutSecs', timeOutSecs, ...                                            % Wait for this many secs to receive this message
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
            'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    
        % Read radial coeff from sattelite-3
        satteliteHostName = satteliteHostNames{3};
        satteliteChannelID = satteliteChannelIDs{3};
        direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_RADIAL_COEFF', satteliteHostName);
        messageData = k;
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteChannelID, ...
            direction, ...
            messageLabel, 'withData', messageData, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    end
    
end