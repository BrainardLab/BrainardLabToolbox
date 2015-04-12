% Method to set a new value for the apertureSize property
function obj = privateSetApertureSize(obj, newApertureSize)
    if (obj.verbosity > 9)
        fprintf('In privateSetApertureSize\n');
    end
    
    % determine if new value is different than its private counterpart
    if (obj.valuesAreSame(newApertureSize, obj.privateApertureSize))
        return;
    end
    
    timeoutInSeconds = 10;
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end
    
    if (~ismember(newApertureSize, obj.validApertureSizes))
        error('Aperture size must be set to either ''%s'', ''%s'', ''%s'', or ''%s'' !', obj.validApertureSizes{1}, obj.validApertureSizes{2}, obj.validApertureSizes{3}, obj.validApertureSizes{4}); 
    end
    
    % Tell the device we're specifying a user defined frequency.
    if (strcmp(newApertureSize, '1 DEG'))
        obj.writeSerialPortCommand('commandString', 'SF0');
    elseif (strcmp(newApertureSize, '1/2 DEG'))
        obj.writeSerialPortCommand('commandString', 'SF1');
    elseif (strcmp(newApertureSize, '1/4 DEG'))
        obj.writeSerialPortCommand('commandString', 'SF2');
    elseif (strcmp(newApertureSize, '1/8 DEG'))
        obj.writeSerialPortCommand('commandString', 'SF3');
    end

    % Check the response.
    obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after SFx command');
        
    % update the private copy
    obj.privateApertureSize = newApertureSize;
end

