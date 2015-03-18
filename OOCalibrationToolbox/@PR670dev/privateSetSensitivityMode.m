% Method to set a new value for the sensitivityMode property
function obj = privateSetSensitivityMode(obj, newSensitivityMode)

    if (obj.verbosity > 9)
        fprintf('In privateSetSensitivityMode\n');
    end
    
    % determine if new value is different than its private counterpart
    if (obj.valuesAreSame(newSensitivityMode, obj.privateSensitivityMode))
        return;
    end
    
    timeoutInSeconds = 10;
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end

    % Check validitity of input
    if (~ismember(newSensitivityMode, obj.validSensitivityModes))
        error('SensitivityMode must be set to either ''%s'', or ''%s'' !', obj.validSensitivityModes{1}, obj.validSensitivityModes{2}); 
    end
    
    if (strcmp(newSensitivityMode, 'STANDARD'))
        validExposureRange = obj.validExposureTimes{2};
        if (obj.privateExposureTime > validExposureRange(2))
            error('The sensitivityMode must be set to ''%s'' for an exposureTime of %d milliseconds.', obj.validSensitivityModes{2}, obj.privateExposureTime);
        end
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