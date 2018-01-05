function initiateCommunication(obj, hostRoles, hostNames, triggerMessage, allSatellitesAreAGOMessage, varargin)

    p = inputParser;
    p.addOptional('beVerbose', true, @islogical);
    parse(p,varargin{:});
    beVerbose = p.Results.beVerbose;
    
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
        iSatelliteNames = keys(obj.satelliteInfo);
    else
        iSatelliteNames{1} = obj.localHostName;
    end
    
    for udpHandle = obj.MIN_UDP_HANDLE:obj.MAX_UDP_HANDLE
        matlabNUDP('close', udpHandle);
    end
    
    if (obj.localHostIsBase)
        % We are the base
        for k = 1:numel(iSatelliteNames)  
            % Set updHandle for communication with this satellite
            satelliteName = iSatelliteNames{k};
            obj.udpHandle = obj.satelliteInfo(satelliteName).satelliteChannelID;

            if strcmp(obj.verbosity,'max')
                fprintf('%s Opening connection to/from ''%s'' via udpChannel:%d and port:%d, (local:%s remote:%s)\n', obj.selfSignature, satelliteName, obj.udpHandle, obj.satelliteInfo(satelliteName).portNo, obj.localIP,  obj.satelliteInfo(satelliteName).satelliteIP);
            end
            
            % Close udp channel, then re-open it
            matlabNUDP('close', obj.udpHandle);
            matlabNUDP('open', obj.udpHandle, obj.localIP, obj.satelliteInfo(satelliteName).satelliteIP, obj.satelliteInfo(satelliteName).portNo);

            % flush any remaining bits
            obj.flushQueue();
        end
    else 
        % We are a satellite
        % Set updHandle for communicating with base
        satelliteName = iSatelliteNames{1};
        obj.udpHandle = obj.satelliteInfo(satelliteName).satelliteChannelID;
            
        if strcmp(obj.verbosity,'max')
            fprintf('%s Opening connection to/from ''%s'' via udpChannel:%d and port:%d, (local:%s remote:%s)\n', obj.selfSignature, satelliteName, obj.udpHandle, obj.satelliteInfo(satelliteName).portNo, obj.localIP,  obj.baseInfo.baseIP);
        end

        matlabNUDP('close', obj.udpHandle);
        matlabNUDP('open', obj.udpHandle, obj.localIP, obj.baseInfo.baseIP, obj.satelliteInfo(satelliteName).portNo);

        % flush any remaining bits
        obj.flushQueue();   
    end

    
    if (obj.localHostIsBase)
        fprintf('Are the satellite(s) ready to go?. Hit enter if so.\n'); pause; clc; 
        iSatelliteNames = keys(obj.satelliteInfo);
        for k = 1:numel(iSatelliteNames)
            satelliteName = iSatelliteNames{k};
            fprintf('Initiating communication with satellite ''%s''.\n', satelliteName);
            % Set the current udpHandle
            obj.udpHandle = obj.satelliteInfo(satelliteName).satelliteChannelID; 
            % Send trigger and wait for up to 4 seconds to receive acknowledgment
            transmissionStatus = obj.sendMessage(triggerMessage, '', ...
                'timeOutSecs',  5 ...
                );
        end % for k
        
        for k = 1:numel(iSatelliteNames)
            satelliteName = iSatelliteNames{k};
            fprintf('Sending the * all satellites are a go * message to ''%s''.\n', satelliteName);
            % Set the current udpHandle
            obj.udpHandle = obj.satelliteInfo(satelliteName).satelliteChannelID; 
            % Send trigger and wait for up to 4 seconds to receive acknowledgment
            transmissionStatus = obj.sendMessage(allSatellitesAreAGOMessage, '', ...
                'timeOutSecs',  5 ...
                );
        end % for k
        
    else
        % Set the current udpHandle
        obj.udpHandle = obj.satelliteInfo(obj.localHostName).satelliteChannelID; 
        % Wait for ever to receive the trigger message from the base
        packetReceived = obj.waitForMessage(triggerMessage, ...
                'timeOutSecs', Inf, ...
                'pauseTimeSecs', 0.05 ...
                );      
            
        fprintf('Received the trigger message, will wait 5 seconds for the BASE to transmit that all satellites are a GO !\n');
        % Wait for 5 seconds to receive the allSatellitesAreAGOMessage message from the base
        packetReceived = obj.waitForMessage(allSatellitesAreAGOMessage, ...
                'timeOutSecs', 5 ...
                ); 
    end
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