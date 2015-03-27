function serialData = readSerialPortData(obj) 
    if (obj.verbosity > 9)
        fprintf('In PR650obj.readSerialPortData() method\n');
    end

    % Look for any data on the serial port.
    data = IOPort('Read', obj.portHandle);
    serialData = char(data);

    % If data exists keep reading off the port until there's nothing left.
    if ~isempty(serialData)
        tmpData = 1;
        while ~isempty(tmpData)
            WaitSecs(0.050);
            tmpData = IOPort('Read', obj.portHandle);
            serialData = [serialData, char(tmpData)];
        end
    end
end  % function serialData = read(obj) 
        