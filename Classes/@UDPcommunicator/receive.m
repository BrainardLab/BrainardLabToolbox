function value = receive(obj, timeOutInSeconds)

    minArgs = 1;
    maxArgs = 2;
    narginchk(minArgs, maxArgs);
    
    if (nargin == 1)
        timeOutInSeconds = Inf;
    end
    
    fprintf('UDPcommunicator: Waiting to receive something ...');
    
    value = struct(...
        'timedOut', false, ...
        'paramName', [], ...
        'paramValue', [] ...
        );
    
    data = 0;
    if (timeOutInSeconds > 0)
        tic
    end
    while (data == 0) && (~value.timedOut)
        data = matlabUDP('check');
        if (toc > timeOutInSeconds)
            value.timedOut = true;
        end
    end
    
    if (~value.timedOut)
        % read the input
        data = matlabUDP('receive');
        
        % parse the input to see what we got
        % format should be two strings separated by \t
        tabPositions = strfind(data, '\t');
        if (isempty(tabPositions))
            error('Received data ''%s'' is inconsistent\n', data);
        end
        if (numel(tabPositions)>1)
            fprintf('Found more than 1 tabs. Using first one.\n');
            tabPositions = tabPositions(1);
        end
        value.paramName = data(1:tabPositions-1);
        value.paramValue = data(tabPositions+1:end);
    end

   return;
    
            
    % send the param name followed by the param value with a tab in-between
    matlabUDP('send', sprintf('%s \t %s', paramName, sprintf('%f', number)));

end