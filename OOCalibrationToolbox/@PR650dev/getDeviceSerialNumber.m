% Method to obtain device-speficic properties of PR-650
function serialNum = getDeviceSerialNumber(obj)
    if (obj.verbosity > 9)
        fprintf('In PR650obj.getDeviceSerialNumber() method\n');
    end
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end
    
    % Send command.
    IOPort('write', obj.portHandle, ['d110' char(10)]);
    
    timeoutInSeconds = 10;
    
    % Check the response.
    response = obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after D110 command. Serial number not retrieved.');
    
    if (~isempty(response))
        serialNum = response(1:8);
    end
end