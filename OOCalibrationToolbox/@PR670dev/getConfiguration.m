function PR670config = getConfiguration(obj)
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end
  
    % Write command to export the configuration
    obj.writeSerialPortCommand('commandString', 'D602');
  
    % Read the configuration
    timeoutInSeconds = 5;
    response = obj.getResponseOrTimeOut(timeoutInSeconds, 'Timedout during ''D602'' (configuration) command');
    obj.generateConfigStruct(response);
    
    PR670config = obj.currentConfiguration;
end
