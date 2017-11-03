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
    hostNames = {baseHostName,    sattelite1HostName,  sattelite2HostName,  sattelite3HostName};
    hostIPs   = {'128.91.12.90',  '128.91.12.144',     '128.91.12.160',     '128.91.12.161'};
    hostRoles = {'base',          'sattelite',         'sattelite',         'sattelite'};
    
    %% Control what is printed on the command window
    beVerbose = false;
    displayPackets = true;
    
    %% Use 10 second time out for all comms
    timeOutSecs = 30;
    
    %% Generate 50 data points for the spiral signal
    coeffPoints = 50;
    
    %% Record a video of the demo?
    recordVideo = true;
    
    %% Instantiate the UDPBaseSatteliteCommunicator object to handle all communications
    UDPobj = UDPBaseSatteliteCommunicator.instantiateObject(hostNames, hostIPs, hostRoles, beVerbose);
    
    %% Who the heck are we?
    iAmTheBase = contains(UDPobj.localHostName, baseHostName);
    iAmSattelite1 = contains(UDPobj.localHostName, sattelite1HostName);
    iAmSattelite2 = contains(UDPobj.localHostName, sattelite2HostName);
    iAmSattelite3 = contains(UDPobj.localHostName, sattelite3HostName);
    
     %% Make packetSequences for the base
    if (iAmTheBase)
        packetSequence = designPacketSequenceForBase(UDPobj, ...
            {sattelite1HostName, sattelite2HostName, sattelite3HostName},...
            timeOutSecs, coeffPoints);    
    end
    
    %% Make packetSequences for sattelite(s)
    if (iAmSattelite1)
        packetSequence = designPacketSequenceForSattelite1(UDPobj, ...
            sattelite1HostName, ...
            timeOutSecs, coeffPoints);
    end
    if (iAmSattelite2)
        packetSequence = designPacketSequenceForSattelite2(UDPobj, ...
            sattelite2HostName, ...
            timeOutSecs, coeffPoints);
    end
    if (iAmSattelite3)
        packetSequence = designPacketSequenceForSattelite3(UDPobj, ...
            sattelite3HostName, ...
            timeOutSecs, coeffPoints);
    end
    
    %% Initiate the base / multi-sattelite communication
    triggerMessage = 'Go!';                                     % Tell each sattelite to start listening
    allSattelitesAreAGOMessage = 'All Sattelites Are A GO!';    % Tell each sattelite that all its peers are ready-to-go
    UDPobj.initiateCommunication(hostRoles,  hostNames, triggerMessage, allSattelitesAreAGOMessage, 'beVerbose', beVerbose);
    
    %% Init demo
    if (recordVideo && iAmTheBase)
        visualizeDemoData('open');
    end
    
    %% Execute communication protocol
    for packetNo = 1:numel(packetSequence)
        % Transmit packet
        [theMessageReceived, theCommunicationStatus, roundTipDelayMilliSecs] = ...
            UDPobj.communicate(packetNo, packetSequence{packetNo}, ...
                'beVerbose', beVerbose, ...
                'displayPackets', displayPackets...
             );

         % Update demo
         if (recordVideo && iAmTheBase)
             visualizeDemoData('add');
         end
    end % packetNo
    
    %% Finalize demo
    if (recordVideo && iAmTheBase)
        visualizeDemoData('close');
    end
    
    
    %% Nested function for visualizing the demo
    function visualizeDemoData(mode)
        persistent videoOBJ
        
        if (strcmp(mode, 'open'))
            videoOBJ = VideoWriter('UDPdata.mp4', 'MPEG-4'); % H264 format
            videoOBJ.FrameRate = 30; 
            videoOBJ.Quality = 100;
            videoOBJ.open();
            return;
        end
        
        if (strcmp(mode, 'close'))
            videoOBJ.close();
            return;
        end
        
        if (packetNo == 1)
            radial_coeff = [];
            cos_coeff = [];
            sin_coeff = [];
            sat1 = [];
            sat2 = [];
            sat3 = [];
            hFig = figure(1); clf;
            set(hFig, 'Position', [1000 918 1000 420], 'Color', [1 1 1])
        end
        
        if (~isempty(theMessageReceived))
            if (contains(theMessageReceived.label, 'SIN_COEFF'))
                sin_coeff = cat(1,sin_coeff, theMessageReceived.data);
                sat1(numel(sat1)+1) = theMessageReceived.data;
                sat2(numel(sat2)+1) = 0;
                sat3(numel(sat3)+1) = 0;
            end
            
            if (contains(theMessageReceived.label, 'COS_COEFF'))
                cos_coeff = cat(1,cos_coeff, theMessageReceived.data);
                sat2(numel(sat2)+1) = theMessageReceived.data;
                sat1(numel(sat1)+1) = 0;
                sat3(numel(sat3)+1) = 0;
            end
            
            if (contains(theMessageReceived.label, 'RADIAL_COEFF'))
                radial_coeff = cat(1,radial_coeff, theMessageReceived.data);
                sat3(numel(sat3)+1) = theMessageReceived.data;
                sat1(numel(sat1)+1) = 0;
                sat2(numel(sat2)+1) = 0;
            end
            
            dataPoints = min([numel(sin_coeff) numel(cos_coeff) numel(radial_coeff)]);
            if (dataPoints > 0)
                x = radial_coeff(1:dataPoints).*cos_coeff(1:dataPoints);
                y = radial_coeff(1:dataPoints).*sin_coeff(1:dataPoints);
                maxRange = max([max(abs(x(:))) max(abs(y(:)))]);
                subplot(3,5,[1 2 6 7 11 12]);
                plot(x,y, '-', 'LineWidth', 5.0, 'Color', [0.7 0.7 0.4]); hold on; plot(x,y, '*-', 'LineWidth', 1.5); hold off;
                set(gca, 'XLim', maxRange * [-1 1], 'YLim', maxRange * [-1 1]);
                axis 'square';
                grid 'on'
                grid on
            end
            
            subplot(3,5, 3:5);
            if (~isempty(sat1))
                stem(sat1, 'filled');
                legend('sat-1');
            end
            set(gca, 'XLim', [1 300], 'YLim', [-1 1]);
            
            subplot(3,5, 8:10);
            
            if (~isempty(sat2))
                stem(sat2, 'filled');
                legend('sat-2');
            end
            
            set(gca, 'XLim', [1 300], 'YLim', [-1 1]);
            
            subplot(3,5, 13:15);
            if (~isempty(sat3))
                stem(sat3, 'filled');
                legend('sat-3');
            end
            set(gca, 'XLim', [1 300], 'YLim', [0 1]);
            drawnow;
            videoOBJ.writeVideo(getframe(hFig));
        end % if (~isempty(theMessageReceived))
    end % visualizeDemoData
end

%
% METHOD TO DESIGN PACKET SEQUENCE FOR SATTELITE-1
%
function packetSequence = designPacketSequenceForSattelite1(baseHostName, satteliteHostName, satteliteChannelID, timeOutSecs, coeffPoints)
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

    % Sattelite providing cosine coefficients whenever Base asks for one. 
    for k = 1:coeffPoints
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
        messageData = cos(2*pi*k/coeffPoints);
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
% METHOD TO DESIGN PACKET SEQUENCE FOR SATTELITE-2
%
function packetSequence = designPacketSequenceForSattelite2(baseHostName, satteliteHostName, satteliteChannelID, timeOutSecs, coeffPoints)
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

    % Sattelite providing sine coefficients whenever Base asks for one. 
    for k = 1:coeffPoints
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
        messageData = sin(2*pi*2*k/coeffPoints);
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
% METHOD TO DESIGN PACKET SEQUENCE FOR SATTELITE-3
%
function packetSequence = designPacketSequenceForSattelite3(UDPobj, satteliteHostName, timeOutSecs, coeffPoints)
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Get base host name
    baseHostName = UDPobj.baseInfo.baseHostName;
     
    % Sattelite receiving from Base
    direction = sprintf('%s -> %s', baseHostName, satteliteHostName);
    expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteHostName);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteHostName, ...
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
        satteliteHostName, ...
        direction, ...
        expectedMessageLabel,...
        'timeOutSecs', timeOutSecs, ...                                            % Wait for timeOutSecs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite sending to Base
    direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT', satteliteHostName);
    messageData = struct('a', 12, 'b', 1:100);
    packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
        satteliteHostName, ...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                    % Allow timeOutSecs  to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite providing sine coefficients whenever Base asks for one. 
    for k = 1:coeffPoints
        % Sattelite waits to receive message from Base to send next radial coeff
        direction =  sprintf('%s -> %s', baseHostName, satteliteHostName);
        expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_RADIAL_COEFF', baseHostName, satteliteHostName);
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteHostName, ...
            direction, ...
            expectedMessageLabel,...
            'timeOutSecs', timeOutSecs, ...                                            % Wait for timeOutSecs to receive this message
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
            'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );

        direction = sprintf('%s <- %s', baseHostName, satteliteHostName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_RADIAL_COEFF', satteliteHostName);
        messageData = 1-(k/coeffPoints)*0.6;
        packetSequence{numel(packetSequence)+1} = UDPBaseSatteliteCommunicator.makePacket(...
            satteliteHostName, ...
            direction, ...
            messageLabel, 'withData', messageData, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    end % for k = 1:coeffPoints
    
end


%
% METHOD TO DESIGN PACKET SEQUENCE FOR BASE
%
function packetSequence = designPacketSequenceForBase(UDPobj, satteliteHostNames, timeOutSecs, coeffPoints)
    % Define the communication  packetSequence
    packetSequence = {};

    % Get base host name
    baseHostName = UDPobj.baseInfo.baseHostName;
    
    % Base sending to Sattelite-1 the number pi
    satteliteName = satteliteHostNames{1};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteName);
    messageData = pi;
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satteliteName,...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                    % Allow timeOutSecsto receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Base sending to Sattelite-2 the number pi^2
    satteliteName = satteliteHostNames{2};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteName);
    messageData = pi^2;
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satteliteName,...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                     % Allow timeOutSecs to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 2 ...
    );

    % Base sending to Sattelite-3 the number sqrt(pi)
    satteliteName = satteliteHostNames{3};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satteliteName);
    messageData = sqrt(pi);
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satteliteName,...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                     % Allow timeOutSecs to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 3 ...
    );

    % Base sending to Sattelite-1 the string "tra la la #1"
    satteliteName = satteliteHostNames{1};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satteliteName);
    messageData = 'tra la la #1';
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satteliteName, ...
        direction,...
        messageLabel,  'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                        % Allow timeOutSecs to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );
    
    % Base sending to Sattelite-2 the string "tra la la #2"
    satteliteName = satteliteHostNames{2};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satteliteName);
    messageData = 'tra la la #2';
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satteliteName, ...
        direction,...
        messageLabel,  'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                        % Allow timeOutSecs to receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );
    
    % Base sending to Sattelite-3 the string "tra la la #3"
    satteliteName = satteliteHostNames{3};
    direction = sprintf('%s -> %s', baseHostName, satteliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satteliteName);
    messageData = 'tra la la #3';
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satteliteName, ...
        direction,...
        messageLabel,  'withData', messageData, ...
        'timeOutSecs', timeOutSecs, ...                                        % Allow timeOutSecsto receive ACK (from remote host) that message was received
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR}));
    );
    
    % Sattelite1 sending struct to base
    satteliteName = satteliteHostNames{1};
    direction = sprintf('%s <- %s', baseHostName, satteliteName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT',satteliteName);
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satteliteName, ...
        direction,...
        messageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                         % Allow timeOutSecs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite2 sending struct to base
    satteliteName = satteliteHostNames{2};
    direction = sprintf('%s <- %s', baseHostName, satteliteName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT',satteliteName);
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satteliteName, ...
        direction,...
        messageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                         % Allow timeOutSecs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Sattelite3 sending struct to base
    satteliteName = satteliteHostNames{3};
    direction = sprintf('%s <- %s', baseHostName, satteliteName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT',satteliteName);
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satteliteName, ...
        direction, ...
        messageLabel, ...
        'timeOutSecs', timeOutSecs, ...                                         % Allow timeOutSecs to receive this message
        'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...        % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ... % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
    );

    for k = 1:coeffPoints
        % Tell sattelite-1 to send next the cos-coefficient
        satteliteName = satteliteHostNames{1};
        direction = sprintf('%s -> %s', baseHostName, satteliteName); 
        messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_COS_COEFF', baseHostName, satteliteName);
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satteliteName,...
            direction, ...
            messageLabel, 'withData', 'right now, please',...
            'timeOutSecs', timeOutSecs, ...                                            % Wait for this many secs to receive this message
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
            'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    
        % Read the next cos-coeff from sattelite-1
        direction = sprintf('%s <- %s', baseHostName, satteliteName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_COS_COEFF', satteliteName);
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satteliteName, ...
            direction, ...
            messageLabel, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    
    
        % Tell sattelite-2 to send the next sin-coefficient
        satteliteName = satteliteHostNames{2};
        direction = sprintf('%s -> %s', baseHostName, satteliteName); 
        messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_SIN_COEFF', baseHostName, satteliteName);
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satteliteName,...
            direction, ...
            messageLabel, 'withData', 'right now, please',...
            'timeOutSecs', timeOutSecs, ...                                            % Wait for this many secs to receive this message
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
            'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    
        % Read the sin-coeff from sattelite-2
        direction = sprintf('%s <- %s', baseHostName, satteliteName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_SIN_COEFF', satteliteName);
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satteliteName, ...
            direction, ...
            messageLabel, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );

    
        % Tell sattelite-3 to send the next sin-coefficient
        satteliteName = satteliteHostNames{3};
        direction = sprintf('%s -> %s', baseHostName, satteliteName); 
        messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_RADIAL_COEFF', baseHostName, satteliteName);
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satteliteName,...
            direction, ...
            messageLabel, 'withData', 'right now, please',...
            'timeOutSecs', timeOutSecs, ...                                            % Wait for this many secs to receive this message
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
            'badTransmissionAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    
        % Read the next radial coeff from sattelite-3
        direction = sprintf('%s <- %s', baseHostName, satteliteName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_RADIAL_COEFF', satteliteName);
        messageData = k;
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satteliteName, ...
            direction, ...
            messageLabel, 'withData', messageData, ...
            'timeOutSecs', timeOutSecs, ...                                            % Allow this many secs to receive ACK (from remote host) that message was received 
            'timeOutAction', UDPBaseSatteliteCommunicator.NOTIFY_CALLER ...            % Do not throw an error, notify caller function instead (choose from UDPBaseSatteliteCommunicator.{NOTIFY_CALLER, THROW_ERROR})
        );
    end
end