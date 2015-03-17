% Method to set a new value for the sensitivityMode property
function obj = privateSetSensitivityMode(obj, newSensitivityMode)

    if (obj.verbosity > 9)
        fprintf('In privateSetSensitivityMode\n');
    end
    
    timeoutInSeconds = 10;
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end

    if (~ismember(newSensitivityMode, obj.validSensitivityModes))
        error('SensitivityMode must be set to either ''%s'', or ''%s'' !', obj.validSensitivityModes{1}, obj.validSensitivityModes{2}); 
    end
    
    % Set sensitivity mode
    if (strcmp(newSensitivityMode, 'STANDARD'))
        obj.writeSerialPortCommand('commandString', 'SH0');
    else
        obj.writeSerialPortCommand('commandString', 'SH1');
    end

    % Check the response.
    obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after SHx command');
        
    % update the private copy
    obj.privateSensitivityMode = newSensitivityMode;
end