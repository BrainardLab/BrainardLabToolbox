function serialData = readSerialPortData(obj) 
    if (obj.verbosity > 9)
        fprintf('In PR670obj.readSerialPortData() method\n');
    end
    
    % Look for any data on the serial port.
    data = IOPort('Read', obj.portHandle);
    serialData = char(data);
    
    % If data exists keep reading off the port until there's nothing left.
    if ~isempty(serialData)
        data = 1;
        while ~isempty(data)
            WaitSecs(0.050);
            data = IOPort('Read', obj.portHandle);
            serialData = [serialData, char(data)];
        end
    end

end

