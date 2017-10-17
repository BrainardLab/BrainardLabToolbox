function initiateCommunication(obj, localHostName, hostRoles, hostNames, triggerMessage, varargin)

    p = inputParser;
    p.addOptional('beVerbose', true, @islogical);
    parse(p,varargin{:});
    beVerbose = p.Results.beVerbose;
    
    localHostName = lower(localHostName);
    
    if (strcmp(lower(hostRoles{1}), 'base'))
        baseHostName = lower(hostNames{1});
    elseif (strcmp(lower(hostRoles{2}), 'base'))
        baseHostName = lower(hostNames{2});
    else
        error('There is no base role in hostRoles');
    end
    
    if (strcmp(lower(hostRoles{1}), 'satellite'))
        satelliteHostName = lower(hostNames{1});
    elseif (strcmp(lower(hostRoles{2}), 'satellite'))
        satelliteHostName = lower(hostNames{2});
    else
        error('There is no satellite role in hostRoles');
    end
    
    assert(ismember(baseHostName, hostNames), sprintf('base host (''%s'') is not a valid host name.\n', baseHostName));
    assert(ismember(satelliteHostName, hostNames), sprintf('satellite host (''%s'') is not a valid host name.\n', satelliteHostName));
    
    if (beVerbose)
        fprintf('<strong>Setting ''%s'' as BASE and ''%s'' as SATELLITE</strong>\n', baseHostName, satelliteHostName);
    end
    
    if (strfind(localHostName, satelliteHostName))
        % Wait for ever to receive the trigger message from the base
        packetReceived = obj.waitForMessage(triggerMessage, ...
            'timeOutSecs', Inf, ...
            'timeOutAction', obj.THROW_ERROR, ...
            'badTransmissionAction', obj.THROW_ERROR ...
        );
    
    elseif (strfind(localHostName, baseHostName))
        fprintf('Is the satellite (''%s'') computer ready to go?. Hit enter if so.\n', satelliteHostName); pause; clc;
        % Send trigger and wait for up to 4 seconds to receive acknowledgment
        transmissionStatus = obj.sendMessage(triggerMessage, '', ...
            'timeOutSecs',  4, ...
            'timeOutAction', obj.THROW_ERROR ...
        );
    else
        error('Local host name (''%s'') does not match the satellite (''%s'') or the base (''%s'') host name.', localHostName, satelliteHostName, baseHostName);
    end
end