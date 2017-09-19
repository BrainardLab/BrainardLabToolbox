function demoUDPcommunicator2

    %% Clear the command window
    clc
    
    % Less printing in command window
    beVerbose = false;
    debugPlots = true;
    displayPackets = true;
    
    %% Define the host names, IPs, and roles
    % In this demo we have IPs for manta.psych.upenn.edu and ionean.psych.upenn.edu
    hostNames       = {'manta',            'ionean'};
    hostIPs         = {'128.91.12.90',     '128.91.12.144'};
    hostRoles       = {'master',           'slave'};
    
    %% Get computer name
    localHostName = UDPcommunicator2.getLocalHostName();
    
    %% Instantiate our UDPcommunicator object
    UDPobj = UDPcommunicator2.instantiateObject(localHostName, hostNames, hostIPs, 'beVerbose', beVerbose);
    
    %% Establish the communication
    triggerMessage = 'Go!';
    UDPobj.initiateCommunication(localHostName, hostRoles,  hostNames, triggerMessage, 'beVerbose', beVerbose);

    %% Run protocol for local host
    maxReps = 100;
    rep = 0;
    abortRequestedFromRemoteHost = false;
    abortDueToCommunicationErrorDetectedInTheLocalHost = false;
    
    while (rep < maxReps) && (~abortRequestedFromRemoteHost) && (~abortDueToCommunicationErrorDetectedInTheLocalHost)
        
        rep = rep + 1;
        % Generate the parallel communication protocol for the 2 hosts
        if (contains(localHostName, 'manta'))
            protocolToRun = designPacketSequenceForManta(hostNames);
        else
            protocolToRun = designPacketSequenceForIonean(hostNames);
        end
    
        [messageList, commStatusList, roundTripDelayMilliSecsList(rep,:), ...
            abortRequestedFromRemoteHost, abortDueToCommunicationErrorDetectedInTheLocalHost] = ...
            runProtocol(UDPobj, localHostName, protocolToRun, ...
                        'debugPlots', debugPlots, ...
                        'beVerbose', beVerbose, ...
                        'displayPackets', displayPackets);
    end
    roundTripDelayMilliSecsList
    meanRountTripDelaysMilliSecs = mean(roundTripDelayMilliSecsList, 1)
    if (abortRequestedFromRemoteHost || abortDueToCommunicationErrorDetectedInTheLocalHost)
        fprintf('Loop terminated early due to errors\n');
    end
end

function packetSequence = designPacketSequenceForManta(hostNames)
    % Define the communication  packetSequence
    packetSequence = {};

    % Manta sending
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta -> ionean', sprintf('TRANSIT_MSG_LABEL_%d', 1), ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 1 ...
    );

    % Manta receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta <- ionean', sprintf('RECEIVE_MSG_LABEL_%d', 1),...
        'timeOutSecs', 1.0, ...                                         % Allow for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Manta sending (other direction specification)
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean <- manta', sprintf('REV_TRANSIT_MSG_LABEL_%d', 2), ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', 'tra la la');

    % Manta receiving (other direction specification)
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean -> manta', 'ReceptiveFieldData', ...
        'timeOutSecs', 1, ...                                           % Wait for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );
end


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

    % Ionean receiving
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta -> ionean', sprintf('TRANSIT_MSG_LABEL_%d', 1), ...
        'timeOutSecs', 1.0, ...                                         % Wait for 1 secs to receive this message
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...     % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Ionean sending
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'manta <- ionean', sprintf('RECEIVE_MSG_LABEL_%d', 1), ...
        'timeOutSecs', 1.0, ...                                         % Allow 1 sec to receive ACK (from remote host) that message was received 
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...            % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', struct('a', 12, 'b', rand(2,2)));

    % Ionean receiving (other direction)
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean <- manta', sprintf('REV_TRANSIT_MSG_LABEL_%d', 2), ...
         'timeOutSecs', 1.0, ...                                        % Wait for 1 secs to receive this message
         'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
         'badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER ...    % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
    );

    % Ionean sending (other direction)
    packetSequence{numel(packetSequence)+1} = UDPcommunicator2.makePacket(hostNames,...
        'ionean -> manta', 'ReceptiveFieldData', ...
        'timeOutSecs', 1.0, ...                                        % Allow 1 sec to receive ACK (from remote host) that message was received
        'timeOutAction', UDPcommunicator2.NOTIFY_CALLER, ...           % Do not throw an error, notify caller function instead (choose from UDPcommunicator2.{NOTIFY_CALLER, THROW_ERROR})
        'withData', rfStructTmp);
end


function [messageList, commStatusList, roundTripDelayMilliSecsList, ...
    abortRequestedFromRemoteHost, abortDueToCommunicationErrorDetectedInTheLocalHost] = ...
    runProtocol(UDPobj, localHostName, packetSequence, varargin)
    
    p = inputParser;
    p.addParameter('beVerbose', false, @islogical);
    p.addParameter('debugPlots', false, @islogical);
    p.addParameter('displayPackets', false, @islogical);
    
    p.parse(varargin{:});
    beVerbose = p.Results.beVerbose;
    debugPlots = p.Results.debugPlots;
    displayPackets = p.Results.displayPackets;

    %% Setup control variables
    abortRequestedFromRemoteHost = false;
    abortDueToCommunicationErrorDetectedInTheLocalHost = false;
    
    %% Initialize counter and messages list
    packetNo = 0;
    messageList    = {};
    commStatusList = {};
    roundTripDelayMilliSecsList = [];
    
    %% Start communicating
    while (packetNo < numel(packetSequence)) && ...
          (~abortRequestedFromRemoteHost) && ...
          (~abortDueToCommunicationErrorDetectedInTheLocalHost)
    
        packetNo = packetNo + 1;
        
        % Just for debugging
        if (debugPlots)
            if (strcmp(packetSequence{packetNo}.messageLabel, 'ReceptiveFieldData')) & ...
                (isfield(packetSequence{packetNo}, 'messageData')) & ...
                (~isempty(packetSequence{packetNo}.messageData))
                    %% Setup figure for displaying results
                    figure(1); clf;
                    colormap(gray(1024));
                    imagesc(packetSequence{packetNo}.messageData.rf);
                    title('Transmitted data');
                    set(gca, 'CLim', [-1 1]);
                    drawnow;
            end
        end
        
        % Communicate and collect roundtrip timing info
        tic
        [theMessageReceived, theCommunicationStatus] = ...
            UDPobj.communicate(...
                localHostName, packetNo, packetSequence{packetNo}, ...
                'beVerbose', beVerbose, ...
                'displayPackets', displayPackets...
             );
        roundTripDelayMilliSecsList(packetNo) = toc*1000;
        
        if (strcmp(theCommunicationStatus, UDPobj.ACKNOWLEDGMENT))
            % ALL_GOOD, do not print anything
        elseif (strcmp(theCommunicationStatus, UDPobj.GOOD_TRANSMISSION))
            % ALL_GOOD, print what we received
        elseif (strcmp(theCommunicationStatus, UDPobj.ABORT_MESSAGE.label))
            abortRequestedFromRemoteHost = true;
        else
            % If we reach here, there was a communication error (timeout
            % or bad data), which was not handled earlier.
            fprintf(2, 'Communication status: ''%s''\n', theCommunicationStatus);
            
            % Decice how to handle it. here just exit the loop
            abortDueToCommunicationErrorDetectedInTheLocalHost = true;
        end
        
         % Just for debugging
        if (debugPlots)
            if (~isempty(theMessageReceived))
                 % Just for debugging
                if (strcmp(theMessageReceived.label, 'ReceptiveFieldData'))
                    figure(1); clf;
                    colormap(gray(1024));
                    imagesc(theMessageReceived.data.rf)
                    title('Received data');
                    set(gca, 'CLim', [-1 1]);
                    drawnow;
                end
            end
        end
        
        messageList{packetNo} = theMessageReceived;
        commStatusList{packetNo} = theCommunicationStatus;
    end % while
    
    if (abortRequestedFromRemoteHost)
        fprintf(2,'Aborted communication loop because of an error detected by the remote host [packet no %d].\n', packetNo);
    end
    if (abortDueToCommunicationErrorDetectedInTheLocalHost)
        fprintf(2,'Aborted communication loop because of an error detected by the local host [packet no %d].\n', packetNo);
    end
    
    
    %% Shutdown the UDPobj
    if (beVerbose)
        fprintf('\nShutting down UDPobj...\n');
    end
    UDPobj.shutDown();
end