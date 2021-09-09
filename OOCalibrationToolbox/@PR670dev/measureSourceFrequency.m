function sourceFreq = measureSourceFrequency(obj)

    if (obj.verbosity > 9)
        fprintf('In measureSourceFrequency\n');
    end
    
    if (obj.emulateHardware)
        sourceFreq = 0;
        fprintf(2,'PR670obj.measureSourceFrequency()- Emulating hardware\n');
        return;
    end
    
    timeoutInSeconds = 10;
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end

    % Send command.
    obj.writeSerialPortCommand('commandString', 'F');
    
    % Check the response.
    response = obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after F command. Source frequency could not be determined.');
    readStr = response;

    % Parse the return string.
    errorCode = -1;
    [raw, count] = sscanf(readStr,'%f,%f',2);
    switch count
        % Error occured
        case 1
            errorCode = raw(1);
            fprintf(2,'Could not measure source frequency: error code: %s', errorCode);
            sourceFreq = [];

        % No error
        case 2
            errorCode = raw(1);
            sourceFreq = raw(2);
    end

end



