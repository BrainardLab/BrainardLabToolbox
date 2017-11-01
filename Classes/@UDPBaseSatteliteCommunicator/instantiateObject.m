function UDPobj = instantiateObject(hostNames, hostIPs, hostRoles, commPorts, beVerbose)
    % Parse optinal input parameters.
    p = inputParser;
    p.addRequired('hostNames', @iscell);
    p.addRequired('hostIPs', @iscell);
    p.addRequired('hostRoles', @iscell);
    p.addRequired('commPorts', @iscell);
    p.addRequired('beVerbose',  @islogical);
    p.parse(hostNames, hostIPs, hostRoles, commPorts, beVerbose);
    
    if (beVerbose)
        verbosity = 'max';
    else
        verbosity = 'min';
    end
    
    % Establish the localIP
    localHostName = UDPBaseSatteliteCommunicator.getLocalHostName();
    localIP = hostIPs{find(strcmp(lower(hostNames), localHostName))};
    
    % Establish satteliteChannelIDs
    satteliteInfo = containers.Map();
    satteliteIndices = find(strcmp(lower(hostRoles), 'sattelite'));
    for k = 1:numel(satteliteIndices)
        d.satteliteChannelID = k-1;
        d.portNo = commPorts{satteliteIndices(k)};
        d.remoteIP = hostIPs{satteliteIndices(k)};
        satteliteName = lower(hostNames{satteliteIndices(k)});
        satteliteInfo(satteliteName) = d;
    end
        
    UDPobj = UDPBaseSatteliteCommunicator( ...
            localIP, ...                       % REQUIRED: the local host IP
            satteliteInfo, ...                 % REQUIRED: the sattelite info
            'verbosity', verbosity ...         % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
    );
end
