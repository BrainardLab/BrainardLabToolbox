% Method to obtain device-speficic properties of PR-670
function serialNum = getDeviceSerialNumber(obj)
    if (obj.verbosity > 9)
        fprintf('In PR670obj.getDeviceSerialNumber() method\n');
    end
    
    if (obj.emulateHardware)
        serialNum = '0123456789';
        fprintf(2,'PR670obj.getDeviceSerialNumber()- Emulating hardware\n');
        return;
    end
    
    % Flush the buffers.
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData();
    end

    % Send the command to return the serial number.
    obj.writeSerialPortCommand('commandString', 'D110');

    % Get at least one character
    waited = 0;
    inStr = [];
    timeout = 30;
    while isempty(inStr) && (waited < timeout)
        WaitSecs(1);
        waited = waited + 1;
        inStr = obj.readSerialPortData();
    end
    if waited == timeout
        error('No response from PR670!');
    end

    % Pick up entire buffer.
    readStr = inStr;
    while ~isempty(inStr)
        inStr = obj.readSerialPortData();
        readStr = [readStr inStr];
    end

    % Parse return.  This may contain training blanks.
    A = textscan(readStr, '%d,%s');
    readStr = A{2}{1};
    serialNum  = readStr(1:8);
end
