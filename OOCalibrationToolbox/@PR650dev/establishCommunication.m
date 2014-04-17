% Function to establish communication with the device
function obj = establishCommunication(obj)    
    if (obj.verbosity > 9)
        fprintf('In PR650obj.establishCommunication() method\n');
    end
    
    % Attempt to open the port
    handshakeCode = 'Lenient DontFlushOnWrite=1 FlowControl=None ';
    if (isempty(obj.portHandle)) 
        % Open the port
        oldverbo = IOPort('Verbosity', 2);
        hPort = IOPort('OpenSerialPort', obj.portString, handshakeCode);
        IOPort('Close', hPort);
        WaitSecs(0.5);
        hPort = IOPort('OpenSerialPort', obj.portString, handshakeCode);
        IOPort('Verbosity', oldverbo);
        obj.portHandle = hPort;
        % Check port validity
        obj.checkPortValidity(obj.invalidPortStrings);
    end
    
    % Attempt to communicate. 
    status = []; attemptsNum = 0;
    while ((isempty(status)) && (attemptsNum < 5))
        attemptsNum = attemptsNum + 1;
        status = attemptContact(obj.portHandle);
        % Check to see if the device is responding.
        if ((isempty(status)) || (status == -1))
            fprintf('Failed to communicate with %s during attempt %d. If the device is off, turn it on; if it is on, turn it off and then on.\n', obj.modelName, attemptsNum);
        end
    end
    
    % Report result
    if ((isempty(status)) || (status == -1))
        error(sprintf('Failed to communicate with %s after %d attempts. If the device is off, turn it on; if it is on, turn it off and then on.\n', obj.modelName, attemptsNum));
    else
        fprintf('Established communication during attempt %d.\n', attemptsNum);
    end      
end


% Helper function to attempt contact with the device
function status = attemptContact(portHandle)
    % Send set backlight command to high level to check
    % whether we are talking to the meter.
    startTime = GetSecs;
    IOPort('write', portHandle, ['b3' char(10)]);
    % Wait until meter responds, or time-out after 10 seconds
    serialData = [];
    timeOutPeriodInSeconds = 10;
    while ((isempty(serialData)) && (GetSecs-startTime < timeOutPeriodInSeconds))
        serialData = readPort(portHandle);
        % audible feedback that we are waiting for device to respond
        for k = 1:5
        if (GetSecs-startTime > k*2) && (GetSecs-startTime < k*2+0.01/k)
            sound(sin([1:1024]/1024*2*pi*50*k));
        end
        end
    end
    status = sscanf(serialData,'%f');
end  % status = attemptContact(obj)
        
        
function serialData = readPort(portHandle) 
    data = IOPort('Read', portHandle);
    serialData = char(data);

    % If data exists keep reading off the port until there's nothing left.
    if ~isempty(serialData)
        tmpData = 1;
        while ~isempty(tmpData)
            WaitSecs(0.050);
            tmpData = IOPort('Read', portHandle);
            serialData = [serialData, char(tmpData)];
        end
    end
end

