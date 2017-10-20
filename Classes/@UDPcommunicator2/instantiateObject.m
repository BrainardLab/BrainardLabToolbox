function UDPobj = instantiateObject(localHostName, hostNames, hostIPs, varargin)
    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('beVerbose', false, @islogical);
    p.parse(varargin{:});
    beVerbose = p.Results.beVerbose;
    
    if (beVerbose)
        verbosity = 'max';
    else
        verbosity = 'min';
    end
    
    if (strfind(localHostName, lower(hostNames{1})))
        UDPobj = UDPcommunicator2( ...
            'localIP',   hostIPs{1}, ...        % REQUIRED: the local host IP
            'remoteIP',  hostIPs{2}, ...        % REQUIRED: the remote host IP
            'verbosity', verbosity, ...         % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
            'useNativeUDP', false ...           % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    elseif (strfind(localHostName, lower(hostNames{2})))
        UDPobj = UDPcommunicator2( ...
        'localIP',   hostIPs{2}, ...            % REQUIRED: the local host IP
        'remoteIP',  hostIPs{1}, ...            % REQUIRED: the remote host IP
        'verbosity', verbosity, ...             % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        'useNativeUDP', false ...               % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    else
        error('No configuration for computer named ''%s''.', localHostName);
    end
end
