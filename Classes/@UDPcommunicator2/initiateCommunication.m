function initiateCommunication(obj, localHostName, hostRoles, hostNames, triggerMessage, varargin)

    p = inputParser;
    p.addOptional('beVerbose', true, @islogical);
    parse(p,varargin{:});
    beVerbose = p.Results.beVerbose;
    
    if (strcmp(hostRoles{1}, 'master'))
        masterHostName = hostNames{1};
    elseif (strcmp(hostRoles{2}, 'master'))
        masterHostName = hostNames{2};
    else
        error('There is no master role in hostRoles');
    end
    
    if (strcmp(hostRoles{1}, 'slave'))
        slaveHostName = hostNames{1};
    elseif (strcmp(hostRoles{2}, 'slave'))
        slaveHostName = hostNames{2};
    else
        error('There is no slave role in hostRoles');
    end
    
    assert(ismember(masterHostName, hostNames), sprintf('master host (''%s'') is not a valid host name.\n', masterHostName));
    assert(ismember(slaveHostName, hostNames), sprintf('slave host (''%s'') is not a valid host name.\n', slaveHostName));
    
    if (beVerbose)
        fprintf('<strong>Setting ''%s'' as MASTER and ''%s'' as SLAVE</strong>\n', masterHostName, slaveHostName);
    end
    
    if (strfind(localHostName, slaveHostName))
        % Wait for ever to receive the trigger message from the master
        packetReceived = obj.waitForMessage(triggerMessage, ...
            'timeOutSecs', Inf, ...
            'timeOutAction', obj.THROW_ERROR, ...
            'badTransmissionAction', obj.THROW_ERROR ...
        );
    
    elseif (strfind(localHostName, masterHostName))
        fprintf('Is ''%s'' running on the slave (''%s'') computer?. Hit enter if so.\n', mfilename, slaveHostName); pause; clc;
        % Send trigger and wait for up to 4 seconds to receive acknowledgment
        transmissionStatus = obj.sendMessage(triggerMessage, '', ...
            'timeOutSecs',  4, ...
            'timeOutAction', obj.THROW_ERROR ...
        );
    else
        error('Local host name (''%s'') does not match the slave (''%s'') or the master (''%s'') host name.', localHostName, slaveHostName, masterHostName);
    end
end