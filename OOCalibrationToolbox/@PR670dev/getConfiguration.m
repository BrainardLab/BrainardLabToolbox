function config = getConfiguration(obj)
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end
  
    % Write command to export the configuration
    obj.writeSerialPortCommand('commandString', 'D601');
  
    % Read the configuration
    timeoutInSeconds = 5;
    config = obj.getResponseOrTimeOut(timeoutInSeconds);

end
