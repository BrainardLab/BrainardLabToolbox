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
        
        tryToOpen = true;
        attempts = 0;
        maxAttempts = 5;
        while (tryToOpen) && (attempts < maxAttempts)
            try
                hPort = IOPort('OpenSerialPort', obj.portString, handshakeCode);
                attempts = attempts + 1;
                tryToOpen = false;
            catch err
                fprintf('Could not open port. Will try again\n');
                IOPort('CloseAll');
                pause(0.2);
            end
        end
        
        if (obj.verbosity > 9)
            fprintf('\n\t1.Opened port %s\n', obj.portString);
        end
        IOPort('Close', hPort);
        if (obj.verbosity > 9)
            fprintf('\t2.Closed port %s\n', obj.portString);
        end
        WaitSecs(0.5);
        hPort = IOPort('OpenSerialPort', obj.portString, handshakeCode);
        if (obj.verbosity > 9)
            fprintf('\t3.Re-opened port %s\n', obj.portString);
        end
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
            fprintf('Failed to communicate with device at ''%s'' (port handle: %d) during attempt %d. If the device is off, turn it on; if it is on, turn it off and then on.\n',  obj.portString, obj.portHandle, attemptsNum);
        end
    end
    
    % Report result
    if ((isempty(status)) || (status == -1))
        error(sprintf('Failed to communicate with device at ''%s'' (port handle: %d) after %d attempts. If the device is off, turn it on; if it is on, turn it off and then on.\n', obj.portString, obj.portHandle, attemptsNum));
    else
        fprintf('Established communication with device at ''%s'' during attempt %d.\n', obj.portString, attemptsNum);
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

