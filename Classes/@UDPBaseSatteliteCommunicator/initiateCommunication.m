function initiateCommunication(obj, hostRoles, hostNames, triggerMessage, varargin)

    p = inputParser;
    p.addOptional('beVerbose', true, @islogical);
    parse(p,varargin{:});
    beVerbose = p.Results.beVerbose;
    
    % Who are we?
    localHostName = obj.localHostName;
    
    % What role do we have?
    iAmTheBase  = localHostRoleIs(localHostName, hostNames, hostRoles, 'base');
    iAmASattelite = localHostRoleIs(localHostName, hostNames, hostRoles, 'sattelite');
    if ((~iAmTheBase) && (~iAmASattelite))
        error('Localhost (''%s'') does not have a ''base'' or a ''sattelite'' role.', localHostName);
    end
   
    if (beVerbose)
        if (iAmTheBase)
            fprintf('<strong>Setting ''%s'' as the BASE with sattelite channel IDs: </strong>\n', localHostName);
        else
            fprintf('<strong>Setting ''%s'' as a SATTELITE  with sattelite channel IDs: </strong>\n', localHostName);
        end
    end
    
    
    if (iAmTheBase)
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
        end
    else
        % Set the current udpHandle
        obj.udpHandle = obj.satteliteInfo(obj.localHostName).satteliteChannelID; 
        % Wait for ever to receive the trigger message from the base
            packetReceived = obj.waitForMessage(triggerMessage, ...
                'timeOutSecs', Inf, ...
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
