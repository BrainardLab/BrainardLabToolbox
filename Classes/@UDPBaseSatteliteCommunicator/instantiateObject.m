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
    localHostName = UDPBaseSatteliteCommunicator.getLocalHostName();
    localIP = hostIPs{find(strcmp(lower(hostNames), localHostName))};
    
    % Assemble baseInfo
    baseIndex = find(strcmp(lower(hostRoles), 'base'));
    baseInfo.baseHostName = lower(hostNames{baseIndex(1)});
    baseInfo.baseIP = hostIPs{baseIndex(1)};
    
    % Assemble satteliteInfo
    satteliteInfo = containers.Map();
    satteliteIndices = find(strcmp(lower(hostRoles), 'sattelite'));
    for k = 1:numel(satteliteIndices)
        d.satteliteChannelID = k-1;
        d.portNo = commPorts{satteliteIndices(k)};
        d.satteliteIP = hostIPs{satteliteIndices(k)};
        satteliteName = lower(hostNames{satteliteIndices(k)});
        satteliteInfo(satteliteName) = d;
    end
        
    UDPobj = UDPBaseSatteliteCommunicator( ...
            localIP, ...                       % REQUIRED: the local host IP
            baseInfo, ...                      % REQUIRED: the base info
            satteliteInfo, ...                 % REQUIRED: the sattelite info
            'verbosity', verbosity ...         % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
    );
end
