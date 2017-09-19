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
    maxReps = 10;
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
            if (strcmp(packetSequence{packetNo}.messageLabel, 'IONEAN_SENDING_RF_DATA')) & ...
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
            
            if (strcmp(packetSequence{packetNo}.messageLabel,'IONEAN_SENDING_A_MATRIX')) & ...
                (isfield(packetSequence{packetNo}, 'messageData')) & ...
                (~isempty(packetSequence{packetNo}.messageData))
                %% Setup figure for displaying results
                hFig = figure(2); clf;
                set(hFig, 'Position', [600 1000 400 400]);
                imshow(packetSequence{packetNo}.messageData.theMatrix);
                title('Transmitted data');
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
                if (strcmp(theMessageReceived.label, 'IONEAN_SENDING_RF_DATA'))
                    figure(1); clf;
                    colormap(gray(1024));
                    imagesc(theMessageReceived.data.rf)
                    title('Received data');
                    set(gca, 'CLim', [-1 1]);
                    drawnow;
                end
                
                if (strcmp(theMessageReceived.label,'IONEAN_SENDING_A_MATRIX'))
                    %% Setup figure for displaying results
                    hFig = figure(2); clf;
                    set(hFig, 'Position', [600 1000 400 400]);
                    imshow(theMessageReceived.data.theMatrix);
                    title('Received data');
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