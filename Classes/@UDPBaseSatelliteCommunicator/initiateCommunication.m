% Method to open UDP communication channels between base and sattelites.
% Once UDP channels are open, we instruct the base to send the triggerMessage to all
% the sattelites, and we wait for all sattelites to respond with an allSatellitesAreAGOMessage
function initiateCommunication(obj, hostRoles, hostNames, triggerMessage, allSatellitesAreAGOMessage, varargin)

    p = inputParser;
    p.addOptional('beVerbose', true, @islogical);
    parse(p,varargin{:});
    beVerbose = p.Results.beVerbose;
    
    % Time out duration and max attempts num to establish communication
    timeOutSecs = 10;
    maxAttemptsNum = 5;
    displayPackets = false;
    
    % Who are we?
    localHostName = obj.localHostName;
    
    % What role do we have?
    obj.localHostIsBase  = localHostRoleIs(localHostName, hostNames, hostRoles, 'base');
    obj.localHostIsSatellite = localHostRoleIs(localHostName, hostNames, hostRoles, 'satellite');
    if ((~obj.localHostIsBase) && (~obj.localHostIsSatellite))
        error('Localhost (''%s'') does not have a ''base'' or a ''satellite'' role.', localHostName);
    end
   
    if (beVerbose)
        if (obj.localHostIsBase)
            fprintf('<strong>Setting ''%s'' as the BASE with satellite channel IDs: </strong>\n', localHostName);
        else
            fprintf('<strong>Setting ''%s'' as a SATTELITE  with satellite channel IDs: </strong>\n', localHostName);
        end
    end
    
    % initialize UDP communication(s)
    if (obj.localHostIsBase)
        satelliteHostNames = keys(obj.satelliteInfo);
    else
        satelliteHostNames{1} = obj.localHostName;
    end
    
    for udpHandle = obj.MIN_UDP_HANDLE:obj.MAX_UDP_HANDLE
        matlabNUDP('close', udpHandle);
    end
    
    if (obj.localHostIsBase)
        % We are the base
        for k = 1:numel(satelliteHostNames)  
            % Set updHandle for communication with this satellite
            satelliteName = satelliteHostNames{k};
            obj.udpHandle = obj.satelliteInfo(satelliteName).satelliteChannelID;

            if strcmp(obj.verbosity,'max')
                fprintf('%s Opening connection to/from ''%s'' via udpChannel:%d and port:%d, (local:%s remote:%s)\n', obj.selfSignature, satelliteName, obj.udpHandle, obj.satelliteInfo(satelliteName).portNo, obj.localIP,  obj.satelliteInfo(satelliteName).satelliteIP);
            end
            
            % Close udp channel, then re-open it
            matlabNUDP('close', obj.udpHandle);
            matlabNUDP('open', obj.udpHandle, obj.localIP, obj.satelliteInfo(satelliteName).satelliteIP, obj.satelliteInfo(satelliteName).portNo);        
            obj.flushQueue();
        end
        
        % design trigger sequence
        packetSequence = designTriggerPacketSequenceForBase(obj, satelliteHostNames, triggerMessage, timeOutSecs);
        fprintf('<strong>Are the satellite(s) ready to go?. Hit enter if so.</strong>\n'); pause; clc; 
    
        fprintf('<strong>Sending the trigger message to all satellites.</strong>\n'); 
    else 
        % We are a satellite
        % Set updHandle for communicating with base
        satelliteName = satelliteHostNames{1};
        obj.udpHandle = obj.satelliteInfo(satelliteName).satelliteChannelID;
            
        if strcmp(obj.verbosity,'max')
            fprintf('%s Opening connection to/from ''%s'' via udpChannel:%d and port:%d, (local:%s remote:%s)\n', obj.selfSignature, satelliteName, obj.udpHandle, obj.satelliteInfo(satelliteName).portNo, obj.localIP,  obj.baseInfo.baseIP);
        end

        % Close udp channel, then re-open it
        matlabNUDP('close', obj.udpHandle);
        matlabNUDP('open', obj.udpHandle, obj.localIP, obj.baseInfo.baseIP, obj.satelliteInfo(satelliteName).portNo); 
        obj.flushQueue();
        
        % design trigger sequence
        pauseTimeSecsInLazyWaitForMessage = 0.05;
        packetSequence = designTriggerPacketSequenceForSatellite(obj, satelliteName, triggerMessage, Inf, pauseTimeSecsInLazyWaitForMessage); 
    
        fprintf('<strong>Waiting for the trigger message from base.</strong>\n'); 
    end
    
    
        
    % Communicate the triggerMessage      
    for packetNo = 1:numel(packetSequence)
       % Communicate packet
       [theMessageReceived, theCommunicationStatus, roundTipDelayMilliSecs, attemptsForThisPacket] = ...
                obj.communicate(packetNo, packetSequence{packetNo}, ...
                    'maxAttemptsNum', maxAttemptsNum, ...
                    'beVerbose', beVerbose, ...
                    'displayPackets', displayPackets...
                 );
    end % packetNo
        
    % If we reach this point, we have sent the trigger message and all sattelites have replied.
    % Now send the allSatellitesAreAGOMessage
    
    if (obj.localHostIsBase)
        packetSequence = designTriggerPacketSequenceForBase(obj, satelliteHostNames, allSatellitesAreAGOMessage, timeOutSecs);
        fprintf('<strong>Sending the ''all satellites are a GO'' message to all satellites.</strong>\n'); 
    else
        pauseTimeSecsInLazyWaitForMessage = 0.0;
        packetSequence = designTriggerPacketSequenceForSatellite(obj, satelliteName, allSatellitesAreAGOMessage, timeOutSecs, pauseTimeSecsInLazyWaitForMessage);
        fprintf('<strong>Waiting for the ''all satellites are a GO'' message from base.</strong>\n');
    end
    
    % Communicate the  allSatellitesAreAGOMessage   
    for packetNo = 1:numel(packetSequence)
       % Communicate packet
       [theMessageReceived, theCommunicationStatus, roundTipDelayMilliSecs, attemptsForThisPacket] = ...
                obj.communicate(packetNo, packetSequence{packetNo}, ...
                    'maxAttemptsNum', maxAttemptsNum, ...
                    'beVerbose', beVerbose, ...
                    'displayPackets', displayPackets...
                 );
    end % packetNo
    
    if (obj.localHostIsBase)
        fprintf('Successfully established communication with all sattelites.\n');
    else
        fprintf('Successfully established communication with the base.\n');
    end   
end

function packetSequence = designTriggerPacketSequenceForBase(UDPobj, satelliteHostNames, triggerMessage, timeOutSecs)
    % Define the communication  packetSequence
    packetSequence = {};

    % Get base host name
    baseHostName = UDPobj.baseInfo.baseHostName;
    
    for satIndex = 1:numel(satelliteHostNames)
        satelliteHostName = satelliteHostNames{satIndex};
        direction = sprintf('%s -> %s', baseHostName, satelliteHostName);
        messageLabel = triggerMessage;
        messageData = '';
        packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satelliteHostName,...
            direction, ...
            messageLabel, 'withData', messageData, ...
            'timeOutSecs', timeOutSecs ...
        );
    end % satIndex
end

function packetSequence = designTriggerPacketSequenceForSatellite(UDPobj, satelliteHostName, triggerMessage, timeOutSecs, pauseTimeSecsInLazyWaitForMessage) 
    % Define the communication  packetSequence
    packetSequence = {};
    
    % Get base host name
    baseHostName = UDPobj.baseInfo.baseHostName;
    
    direction = sprintf('%s -> %s', baseHostName, satelliteHostName);
    expectedMessageLabel = triggerMessage;
    
    packetSequence{numel(packetSequence)+1} = UDPobj.makePacket(...
            satelliteHostName,...
            direction, ...
            expectedMessageLabel, ...
            'pauseTimeSecsInLazyWaitForMessage', pauseTimeSecsInLazyWaitForMessage, ...
            'timeOutSecs', timeOutSecs ...
    );
end

function iHaveThatRole  = localHostRoleIs(localHostName, hostNames, hostRoles, theRole)
    iHaveThatRole = false;
    roleIndices = find(strcmp(hostRoles, theRole));
    for k = 1:numel(roleIndices)
        if (strcmp(hostNames{roleIndices(k)}, localHostName))
            iHaveThatRole = true;
        end
    end
end