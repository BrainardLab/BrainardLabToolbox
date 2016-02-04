function send(obj, paramName, paramValue, timeOutInSeconds)

    minArgs = 3;
    maxArgs = 4;
    narginchk(minArgs, maxArgs);
    
    if (nargin == 3)
        timeOutInSeconds = 0;
    end
    
    if (~ischar(paramName))
        fprintf(2,'send command usage: udpObd.send(''param name'', paramValue, [timeOutInSeconds]\n');
        error('Incorrect usage of send command. The first argument to the send command must be the parameter name, as a string.\n');
    end
            
    % send the param name followed by the param value with a tab in-between
    matlabUDP('send', sprintf('%s \t %s', paramName, sprintf('%f', number)));

    timeOutInSeconds = 2;
    messageInResponseToCommandSend = obj.receive(timeOutInSeconds)
    
end

