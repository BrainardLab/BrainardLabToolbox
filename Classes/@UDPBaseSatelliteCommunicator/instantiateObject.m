function UDPobj = instantiateObject(hostNames, hostIPs, hostRoles,  beVerbose)
    % Parse optinal input parameters.
    p = inputParser;
    p.addRequired('hostNames', @iscell);
    p.addRequired('hostIPs', @iscell);
    p.addRequired('hostRoles', @iscell);
    p.addRequired('beVerbose',  @islogical);
    p.parse(hostNames, hostIPs, hostRoles,  beVerbose);
    
    if (beVerbose)
        verbosity = 'max';
    else
        verbosity = 'min';
    end
    
    % Comm ports for the different connections
    commPorts = {nan, 2007, 2008, 2009, 2010, 2011};
        
    % Establish the localIP
    localHostName = UDPBaseSatelliteCommunicator.getLocalHostName();
    localIP = hostIPs{find(strcmp(lower(hostNames), localHostName))};
    
    % Assemble baseInfo
    baseIndex = find(strcmp(lower(hostRoles), 'base'));
    baseInfo.baseHostName = lower(hostNames{baseIndex(1)});
    baseInfo.baseIP = hostIPs{baseIndex(1)};
    
    % Assemble satelliteInfo
    satelliteInfo = containers.Map();
    satelliteIndices = find(strcmp(lower(hostRoles), 'satellite'));
    for k = 1:numel(satelliteIndices)
        d.satelliteChannelID = k-1;
        d.portNo = commPorts{satelliteIndices(k)};
        d.satelliteIP = hostIPs{satelliteIndices(k)};
        satelliteName = lower(hostNames{satelliteIndices(k)});
        satelliteInfo(satelliteName) = d;
    end
        
    UDPobj = UDPBaseSatelliteCommunicator( ...
            localIP, ...                       % REQUIRED: the local host IP
            baseInfo, ...                      % REQUIRED: the base info
            satelliteInfo, ...                 % REQUIRED: the satellite info
            'verbosity', verbosity ...         % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
    );
end
