% Method for setting up a UDPobject between 
% the local host computer and its sattelite (if local computer is base) 
% or between the local host computer and its base (if local computer is sattelite)

function UDPobj = instantiateObject(hostNames, hostIPs, hostRoles, beVerbose, varargin)
    % Parse optinal input parameters.
    p = inputParser;
    p.addRequired('hostNames', @iscell);
    p.addRequired('hostIPs', @iscell);
    p.addRequired('hostRoles', @iscell);
    p.addRequired('beVerbose',  @islogical);
    p.addParameter('transmissionMode', 'SINGLE_BYTES', @ischar);    
    p.parse(hostNames, hostIPs, hostRoles,  beVerbose, varargin{:});
    
    if (beVerbose)
        verbosity = 'max';
    else
        verbosity = 'min';
    end
    
    % Comm ports for the different connections
    commPorts = {nan, 2007, 2008, 2009, 2010, 2011};
        
    % Establish the localIP
    localHostName = UDPBaseSatelliteCommunicator.getLocalHostName();
    index = find(strcmpi(hostNames, localHostName));
    if (isempty(index))
        for k = 1:numel(hostNames)
            fprintf(2,'\nlocal host name: ''%s'' not found in hostname: ''%s''', localHostName, hostNames{k});
        end
        error('local host name not found in hostnames cell array');
    end
    localIP = hostIPs{index};
    
    % Collect baseInfo
    baseIndex = find(strcmpi(hostRoles, 'base'));
    baseInfo.baseHostName = lower(hostNames{baseIndex(1)});
    baseInfo.baseIP = hostIPs{baseIndex(1)};
    
    % Collect satelliteInfo
    satelliteInfo = containers.Map();
    satelliteIndices = find(strcmpi(hostRoles, 'satellite'));
    for k = 1:numel(satelliteIndices)
        d.satelliteChannelID = k-1;
        d.portNo = commPorts{satelliteIndices(k)};
        d.satelliteIP = hostIPs{satelliteIndices(k)};
        satelliteName = lower(hostNames{satelliteIndices(k)});
        satelliteInfo(satelliteName) = d;
    end
        
    % Instantiate a UDPBaseSatelliteCommunicator using the collected information
    UDPobj = UDPBaseSatelliteCommunicator( ...
        localIP, ...                                        % REQUIRED: the local host IP
        baseInfo, ...                                       % REQUIRED: the base info
        satelliteInfo, ...                                  % REQUIRED: the satellite info
        'verbosity', verbosity, ...                         % REQUIRED, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        'transmissionMode', p.Results.transmissionMode ...  % OPTIONAL: choose between 'SINGLE_BYTES' (default) and 'WORDS'
    );
end
