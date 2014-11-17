% Method to obtain device-speficic properties of PR-650
function serialNum = getDeviceSerialNumber(obj)
    if (obj.verbosity > 9)
        fprintf('In PR650obj.getDeviceSerialNumber() method\n');
    end
    
    % Flush buffers.
    serialData = obj.readSerialPortData();
    % Send command.
    IOPort('write', obj.portHandle, ['d110' char(10)]);
    % Get response or time-out after 5 seconds
    timeOutPeriodInSeconds = 5;
    startTime = GetSecs;
    serialData = [];
    while ((isempty(serialData)) && (GetSecs-startTime < timeOutPeriodInSeconds))
        serialData = [serialData obj.readSerialPortData()];
    end
    if (isempty(serialData))
        serialNum ='could not be retrieved';
        fprintf('Serial number could not be retrieved. TimedOut after %2.1f seconds.\n', timeOutPeriodInSeconds);
    else
        serialNum = serialData(1:8);
    end
end