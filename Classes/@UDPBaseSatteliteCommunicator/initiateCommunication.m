function initiateCommunication(obj, hostRoles, hostNames, triggerMessage, allSattelitesAreAGOMessage, varargin)

    p = inputParser;
    p.addOptional('beVerbose', true, @islogical);
    parse(p,varargin{:});
    beVerbose = p.Results.beVerbose;
    
    % Who are we?
    localHostName = obj.localHostName;
    
    % What role do we have?
    obj.localHostIsBase  = localHostRoleIs(localHostName, hostNames, hostRoles, 'base');
    obj.localHostIsSattelite = localHostRoleIs(localHostName, hostNames, hostRoles, 'sattelite');
    if ((~obj.localHostIsBase) && (~obj.localHostIsSattelite))
        error('Localhost (''%s'') does not have a ''base'' or a ''sattelite'' role.', localHostName);
    end
   
    if (beVerbose)
        if (obj.localHostIsBase)
            fprintf('<strong>Setting ''%s'' as the BASE with sattelite channel IDs: </strong>\n', localHostName);
        else
            fprintf('<strong>Setting ''%s'' as a SATTELITE  with sattelite channel IDs: </strong>\n', localHostName);
        end
    end
    
    % initialize UDP communication(s)
    if (obj.localHostIsBase)
        iSatteliteNames = keys(obj.satteliteInfo);
    else
        iSatteliteNames{1} = obj.localHostName;
    end
    for k = 1:numel(iSatteliteNames)  
        % Set updHandle
        satteliteName = iSatteliteNames{k};
        obj.udpHandle = obj.satteliteInfo(satteliteName).satteliteChannelID;

        if strcmp(obj.verbosity,'max')
            fprintf('%s Opening connection to/from ''%s'' via udpChannel:%d and port:%d, (local:%s remote:%s)\n', obj.selfSignature, satteliteName, obj.udpHandle, obj.satteliteInfo(satteliteName).portNo, obj.localIP,  obj.satteliteInfo(satteliteName).remoteIP);
        end

        matlabNUDP('close', obj.udpHandle);
        matlabNUDP('open', obj.udpHandle, obj.localIP, obj.satteliteInfo(satteliteName).remoteIP, obj.satteliteInfo(satteliteName).portNo);

        % flash any remaining bits
        obj.flashQueue();
    end

    
    if (obj.localHostIsBase)
        fprintf('Are the satellite(s) ready to go?. Hit enter if so.\n'); pause; clc; 
        iSatteliteNames = keys(obj.satteliteInfo);
        for k = 1:numel(iSatteliteNames)
            satteliteName = iSatteliteNames{k};
            fprintf('Initiating communication with sattelite ''%s''\n', satteliteName);
            % Set the current udpHandle
            obj.udpHandle = obj.satteliteInfo(satteliteName).satteliteChannelID; 
            % Send trigger and wait for up to 4 seconds to receive acknowledgment
            transmissionStatus = obj.sendMessage(triggerMessage, '', ...
                'timeOutSecs',  4, ...
                'timeOutAction', obj.THROW_ERROR ...
                );
        end % for k
        
        for k = 1:numel(iSatteliteNames)
            satteliteName = iSatteliteNames{k};
            fprintf('Sendint the * all sattelites are a go * message ''%s''\n', satteliteName);
            % Set the current udpHandle
            obj.udpHandle = obj.satteliteInfo(satteliteName).satteliteChannelID; 
            % Send trigger and wait for up to 4 seconds to receive acknowledgment
            transmissionStatus = obj.sendMessage(allSattelitesAreAGOMessage, '', ...
                'timeOutSecs',  4, ...
                'timeOutAction', obj.THROW_ERROR ...
                );
        end % for k
        
    else
        % Set the current udpHandle
        obj.udpHandle = obj.satteliteInfo(obj.localHostName).satteliteChannelID; 
        % Wait for ever to receive the trigger message from the base
        packetReceived = obj.waitForMessage(triggerMessage, ...
                'timeOutSecs', Inf, ...
                'timeOutAction', obj.THROW_ERROR, ...
                'badTransmissionAction', obj.THROW_ERROR ...
                );      
            
        fprintf('Received the trigger message, will wait 5 seconds for the BASE to transmit that all sattelites are a GO !\n');
        % Wait for 5 seconds to receive the allSattelitesAreAGOMessage message from the base
        packetReceived = obj.waitForMessage(allSattelitesAreAGOMessage, ...
                'timeOutSecs', 5, ...
                'timeOutAction', obj.THROW_ERROR, ...
                'badTransmissionAction', obj.THROW_ERROR ...
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