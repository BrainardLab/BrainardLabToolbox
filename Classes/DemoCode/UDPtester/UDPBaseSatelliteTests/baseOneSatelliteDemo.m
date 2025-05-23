% A testing program to test UDP communication between a base and a
% satellite using the @UDPBaseSatelliteCommunicator class. 
%
% Adjust the timeOutSecs param so that you minimize the transmission errors.
% Let it run for as long as you want, then ^C to terminate.
% To use the pauseUnpauseDropbox method, you must first use tbUseProject('OLApproach_Squint)
%
% 1/12/2018  NPC Wrote it

function baseOneSatelliteDemo

    %% Allow up to this many attempts to send/read a packet
    maxAttemptsNum = 10;

    totalReps = input('Run an infinite loop (default) or a predefined number of reps (e.g. 800) : ');
    if isempty(totalReps)
        totalReps = Inf;
    end
    
    %% Pause dropbox syncing ?
    pauseDropBox = input('Pause dropbox syncing [y/n], (default: y)');
    if (isempty(pauseDropBox)) || ((ischar(pauseDropBox))&&(strcmpi(pauseDropBox, 'y')))
        dropBoxSyncingStatus = pauseUnpauseDropbox('command', '--pause');
        fprintf('DropBox syncing status set to %d\n',dropBoxSyncingStatus);
        pauseDropBox = true;
    else
        pauseDropBox = false;
    end
    
    %% Select location (this detemines what computers are playing together)
    location = 'manta_ionean';
    
    switch (location)  
        case 'manta_ionean'
            % Define communication scheme
            baseHostName = 'manta';
            satelliteHostName = 'ionean';
            hostNames = {baseHostName,    satelliteHostName };
            hostIPs   = {'128.91.12.90',  '128.91.12.144' };
            hostRoles = {'base',          'satellite' };

            % Set the timeOutSecs param
            timeOutSecs = 60/1000;
            
        otherwise
            error('The computer configuration in location ''%s'' is not known\n', location)
    end
    
    %% Control what is printed on the command window
    beVerbose = false;
    displayPackets = false;
    fprintf('\n\n');
    
    %% Generate 50 data points for the test signal
    coeffPoints = 50;
    
    %% Record a video of the demo?
    recordVideo = false;
    %% Visualize the communication. You can set this to false if you want to test faster
    visualizeComm = false;
    
    %% Instantiate the UDPBaseSatelliteCommunicator object to handle all communications
    UDPobj = UDPBaseSatelliteCommunicator.instantiateObject(hostNames, hostIPs, hostRoles, beVerbose, 'transmissionMode', 'WORDS');

    %% Set some custom properties
    UDPobj.maxSecondsToWaitForReceivingAnExpectedMessage = 10;       % seconds to sit and wait until a message arrives
    UDPobj.lazyPollIntervalSeconds = 20/1000;                        % how long to wait between polls when waiting for a message
    
    %% Who the heck are we?
    localHostIsTheBase      = contains(UDPobj.localHostName, baseHostName);
    localHostIsTheSatellite = contains(UDPobj.localHostName, satelliteHostName);
    
     %% Make packetSequences for the base
    if (localHostIsTheBase)
        packetSequence = designPacketSequenceForBase(UDPobj, ...
            {satelliteHostName},...
            timeOutSecs, coeffPoints);
    end

    %% Make packetSequences for satellite(s)
    if (localHostIsTheSatellite)
        packetSequence = designPacketSequenceForSatellite(UDPobj, ...
            satelliteHostName, ...
            timeOutSecs, coeffPoints);
    end
    

    %% Initiate the base / multi-satellite communication
    triggerMessage = 'Go!';                                     % Tell each satellite to start listening
    allSatellitesAreAGOMessage = 'All Satellites Are A GO!';    % Tell each satellite that all its peers are ready-to-go
    UDPobj.initiateCommunication(hostRoles,  hostNames, triggerMessage, allSatellitesAreAGOMessage, maxAttemptsNum, 'beVerbose', beVerbose);

    %% Init demo
    if (localHostIsTheBase && visualizeComm)
        visualizeDemoData('open', recordVideo, {satellite1HostName, satellite2HostName});
    end

    %% Init the attempts package counter
    attemptsCounter = zeros(1,maxAttemptsNum);
    
    %% Init repetition number
    r = 0;
    
    %% Enter the testing loop
    while r < totalReps
        r = r + 1;
        roundTipDelayMilliSecsTransmit = [];
        roundTipDelayMilliSecsReceive = [];

        %% Execute communication protocol
        for packetNo = 1:numel(packetSequence)
            % Communicate packet
            [theMessageReceived, theCommunicationStatus, roundTipDelayMilliSecs, attemptsForThisPacket] = ...
                UDPobj.communicate(packetNo, packetSequence{packetNo}, ...
                    'maxAttemptsNum', maxAttemptsNum, ...
                    'beVerbose', beVerbose, ...
                    'displayPackets', displayPackets...
                 );

            % Update stats
            attemptsCounter(attemptsForThisPacket) = attemptsCounter(attemptsForThisPacket) + 1;
            
            if (UDPobj.isATransmissionPacket(packetSequence{packetNo}.direction, UDPobj.localHostName))
                roundTipDelayMilliSecsTransmit(numel(roundTipDelayMilliSecsTransmit)+1) = roundTipDelayMilliSecs;
            else
                roundTipDelayMilliSecsReceive(numel(roundTipDelayMilliSecsReceive)+1) = roundTipDelayMilliSecs;
            end

            % Update demo
            if (localHostIsTheBase && visualizeComm)
                 visualizeDemoData('add', recordVideo, {satellite1HostName, satellite2HostName});
            end
        end % packetNo

        fprintf('\nRepetition %d\n', r);
        for k = 1:maxAttemptsNum
            fprintf('Numer of packages that required %d attempt(s): %d\n', k, attemptsCounter(k));
        end
        fprintf('MEAN and STD roundtrip for transmitting packages: %2.3f %2.3f msec\n', mean(roundTipDelayMilliSecsTransmit), std(roundTipDelayMilliSecsTransmit));
        fprintf('MEAN and STD roundtrip for receiving packages: %2.3f %2.3f msec\n\n', mean(roundTipDelayMilliSecsReceive), std(roundTipDelayMilliSecsReceive));
    end  % while (r < totalReps)
    
    %% Resume dropbox syncing
    if (pauseDropbox)
        dropBoxSyncingStatus = pauseUnpauseDropbox('command','--resume');
        fprintf('DropBox syncing status set to %d\n',dropBoxSyncingStatus);
    end
    
    %% Close video file
    if (localHostIsTheBase && visualizeComm)
        visualizeDemoData('close', recordVideo, {satelliteHostName});
    end

    %% Nested function for visualizing the demo
    function visualizeDemoData(mode, recordVideo, satteliteNames)
        persistent videoOBJ
        persistent radial_coeff;
        persistent cos_coeff;
        persistent sin_coeff;
        persistent sat1;
        persistent sat2;
        persistent sat3;
        persistent hFig;
        persistent p1;
        persistent p2;
        persistent p3;
        persistent p4;
        
        if (strcmp(mode, 'open')) 
            if (recordVideo)
                videoOBJ = VideoWriter('UDPdata.mp4', 'MPEG-4'); % H264 format
                videoOBJ.FrameRate = 30;
                videoOBJ.Quality = 100;
                videoOBJ.open();
            end
            return;
            
        elseif (strcmp(mode, 'close')) 
            if (recordVideo)
                videoOBJ.close();
            end
            return;
        elseif (~strcmp(mode, 'add'))
            error('Unknown mode in visualizeDemoData(): ''%s'' \n', mode);
        end

        if (packetNo == 1)
            radial_coeff = [];
            cos_coeff = [];
            sin_coeff = [];
            sat1 = [];
            sat2 = [];
            sat3 = [];
            p1 = [];
            p2 = [];
            p3 = [];
            p4 = [];
            hFig = figure(1); clf;
            set(hFig, 'Position', [1000 918 1000 420], 'Color', [1 1 1])
            % Always 1, since there is no sat-3 to provide this
            t = 1:(coeffPoints*4+10);
            radial_coeff = 4+0.5*cos(t'/coeffPoints*30);
        end

        
        if (~isempty(theMessageReceived))
            
            if (contains(theMessageReceived.label, 'SIN_COEFF'))
                sin_coeff = cat(1,sin_coeff, theMessageReceived.data);
                sat1(numel(sat1)+1) = theMessageReceived.data;
                sat2(numel(sat2)+1) = nan;
                sat3(numel(sat3)+1) = radial_coeff(numel(sat1)+1);
            end

            if (contains(theMessageReceived.label, 'COS_COEFF'))
                cos_coeff = cat(1,cos_coeff, theMessageReceived.data);
                sat2(numel(sat2)+1) = theMessageReceived.data;
                sat1(numel(sat1)+1) = nan;
                sat3(numel(sat3)+1) = radial_coeff(numel(sat2)+1);
            end

            if (contains(theMessageReceived.label, 'RADIAL_COEFF'))
                radial_coeff = cat(1,radial_coeff, theMessageReceived.data);
                sat3(numel(sat3)+1) = theMessageReceived.data;
                sat1(numel(sat1)+1) = nan;
                sat2(numel(sat2)+1) = nan;
            end

            dataPoints = min([numel(sin_coeff) numel(cos_coeff) numel(radial_coeff)]);
            if (dataPoints > 2)
                x = radial_coeff(1:dataPoints).*cos_coeff(1:dataPoints);
                y = radial_coeff(1:dataPoints).*sin_coeff(1:dataPoints);
                subplot(3,5,[1 2 6 7 11 12]);
                if (isempty(p1))
                    p1 = plot(x,y, 'ro-', 'LineWidth', 2.0);
                    set(gca, 'XLim', [-5 5], 'YLim', [-5 5], 'FontSize', 12);
                    axis 'square';
                    grid on
                    title('Base');
                else
                    set(p1, 'XData', x, 'YData', y);
                end
            end

            subplot(3,5, 3:5);
            if (~isempty(sat1))
                if (isempty(p2))
                    p2 = stem([0 0], 'filled');
                    hL = legend(sprintf('data from %s',satteliteNames{1}));
                    set(hL, 'FontSize', 16);
                    set(gca, 'XLim', [1 coeffPoints*2], 'YLim', [-1 1], 'FontSize', 12);
                else
                    set(p2, 'XData', 1:numel(sat1), 'YData', sat1);
                end
            end
            
            subplot(3,5, 8:10);
            if (~isempty(sat2))
                if (isempty(p3))
                    p3 = stem([0 0], 'filled');
                   hL = legend(sprintf('data from %s',satteliteNames{2}));
                    set(hL, 'FontSize', 16);
                    set(gca, 'XLim', [1 coeffPoints*2], 'YLim', [-1 1], 'FontSize', 12);
                else
                    set(p3, 'XData', 1:numel(sat2), 'YData', sat2);
                end
            end

            subplot(3,5, 13:15);
            if (~isempty(sat3))
                if (isempty(p4))
                    p4 = stem([0 0], 'filled');
                    hL = legend('data from virtual - sattelite');
                    set(hL, 'FontSize', 16);
                    set(gca, 'XLim', [1 coeffPoints*2], 'YLim', [0 7], 'FontSize', 12);
                else
                    set(p4, 'XData', 1:numel(sat3), 'YData', sat3);
                end
            end
            
            drawnow;
            
            if (recordVideo)
                videoOBJ.writeVideo(getframe(hFig));
            end
        end % if (~isempty(theMessageReceived))
    end % visualizeDemoData
end
%
% METHOD TO DESIGN PACKET SEQUENCE FOR SATTELITE
%
function packetSequence = designPacketSequenceForSatellite(UDPobj, satelliteHostName, timeOutSecs, coeffPoints)
    % Define the communication  packetSequence
    packetSequence = {};

    % Get base host name
    baseHostName = UDPobj.baseInfo.baseHostName;

    % Satellite receiving from Base
    direction = sprintf('%s -> %s', baseHostName, satelliteHostName);
    expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satelliteHostName);
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satelliteHostName, ...
        direction, ...
        expectedMessageLabel, ...
        'timeOutSecs', timeOutSecs ...                                             % Wait for this many secs to receive this message
    );

    % Satellite receiving from Base
    direction = sprintf('%s -> %s', baseHostName, satelliteHostName);
    expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satelliteHostName);
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satelliteHostName,...
        direction, ...
        expectedMessageLabel, ...
        'timeOutSecs', timeOutSecs ...                                            % Wait for this many secs to receive this message
    );

    % Satellite sending to Base
    direction = sprintf('%s <- %s', baseHostName, satelliteHostName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT', satelliteHostName);
    messageData = struct('a', 12, 'b', [1 2 3; 4 5 6; 7 8 9]);
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satelliteHostName, ...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs ...                                            % Allow this many secs to receive ACK (from remote host) that message was received
    );

    % Satellite providing cosine coefficients whenever Base asks for one.
    for k = 1:coeffPoints
        % Satellite waits to receive trigger message from Base to send next cos-coefficient
        direction = sprintf('%s -> %s', baseHostName, satelliteHostName);
        expectedMessageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_COS_COEFF', baseHostName, satelliteHostName);
 
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satelliteHostName,...
            direction, ...
            expectedMessageLabel, ...
            'timeOutSecs', timeOutSecs ...                                            % Wait for this many secs to receive this message
        );

        direction = sprintf('%s <- %s', baseHostName, satelliteHostName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_COS_COEFF', satelliteHostName);
        messageData = cos(2*pi*k/coeffPoints);

        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satelliteHostName, ...
            direction, ...
            messageLabel, 'withData', messageData, ...
            'timeOutSecs', timeOutSecs ...                                            % Allow this many secs to receive ACK (from remote host) that message was received
        );
    end

end

%
% METHOD TO DESIGN PACKET SEQUENCE FOR BASE
%
function packetSequence = designPacketSequenceForBase(UDPobj, satelliteHostNames, timeOutSecs, coeffPoints)
    % Define the communication  packetSequence
    packetSequence = {};

    % Get base host name
    baseHostName = UDPobj.baseInfo.baseHostName;

    % Base sending to Satellite-1 the number pi
    satelliteName = satelliteHostNames{1};
    direction = sprintf('%s -> %s', baseHostName, satelliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_SINGLE_INTEGER', baseHostName, satelliteName);
    messageData = pi;
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satelliteName,...
        direction, ...
        messageLabel, 'withData', messageData, ...
        'timeOutSecs', timeOutSecs ...                                    % Allow timeOutSecsto receive ACK (from remote host) that message was received
    );

    % Base sending to Satellite-1 the string "tra la la #1"
    satelliteName = satelliteHostNames{1};
    direction = sprintf('%s -> %s', baseHostName, satelliteName);
    messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SENDING_CHAR_STRING', baseHostName, satelliteName);
    messageData = 'tra la la #1';
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satelliteName, ...
        direction,...
        messageLabel,  'withData', messageData, ...
        'timeOutSecs', timeOutSecs ...                                        % Allow timeOutSecs to receive ACK (from remote host) that message was received
    );



    % Satellite1 sending struct to base
    satelliteName = satelliteHostNames{1};
    direction = sprintf('%s <- %s', baseHostName, satelliteName);
    messageLabel = sprintf('SATTELITE(%s)___SENDING_SMALL_STRUCT',satelliteName);
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
        satelliteName, ...
        direction,...
        messageLabel, ...
        'timeOutSecs', timeOutSecs ...                                         % Allow timeOutSecs to receive this message
    );


    for k = 1:coeffPoints
        % Tell satellite-1 to send next the cos-coefficient
        satelliteName = satelliteHostNames{1};
        direction = sprintf('%s -> %s', baseHostName, satelliteName);
        messageLabel = sprintf('BASE(%s)_TO_SATTELITE(%s)___SEND_ME_NEXT_COS_COEFF', baseHostName, satelliteName);
        
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satelliteName,...
            direction, ...
            messageLabel, 'withData', 'right now, please',...
            'timeOutSecs', timeOutSecs ...                                            % Wait for this many secs to receive this message
        );

        % Read the next cos-coeff from satellite-1
        direction = sprintf('%s <- %s', baseHostName, satelliteName);
        messageLabel = sprintf('SATTELITE(%s)___SENDING_COS_COEFF', satelliteName);
        
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satelliteName, ...
            direction, ...
            messageLabel, ...
            'timeOutSecs', timeOutSecs ...                                            % Allow this many secs to receive ACK (from remote host) that message was received
        );

    end
end
