% Method to set a new value for the exposureTime property
function obj = privateSetExposureTime(obj, newExposureTime)

    if (obj.verbosity > 9)
        fprintf('In privateSetExposureTime\n');
    end
    
    if (obj.emulateHardware)
        obj.privateExposureTime = newExposureTime;
        fprintf(2,'PR670obj.privateSetExposureTime()- Emulating hardware\n');
        return;
    end
    
    % determine if new value is different than its private counterpart
    if (obj.valuesAreSame(newExposureTime, obj.privateExposureTime))
        return;
    end
    
    timeoutInSeconds = 10;
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end
    
    % Check validitity of input
    standardRange = obj.validExposureTimes{2};
    extendedRange = obj.validExposureTimes{3};
    if (ischar(newExposureTime))
        if (~strcmp(newExposureTime, obj.validExposureTimes{1}))
            error('Exposure time was set to ''%s''. It must be set to either a numeric value in range [%d - %d] (STANDARD sensitivity mode), or [%d - %d] (EXTENDED sensitivity mode), or equal to the string: ''%s''!', ...
                newExposureTime, standardRange(1), standardRange(2), extendedRange(1), extendedRange(2), obj.validExposureTimes{1}); 
        end 
    elseif (isnumeric(newExposureTime))
        if (strcmp(obj.privateSensitivityMode, 'STANDARD'))
            if (newExposureTime < standardRange(1)) || (newExposureTime > standardRange(2))
                error('Exposure time was set to ''%d'', while in ''%s'' sensitivity mode. In this sensitivity range it must be set to either a numeric value in range [%d - %d], or equal to the string ''%s''!', ...
                    newExposureTime, obj.privateSensitivityMode, standardRange(1), standardRange(2), obj.validExposureTimes{1}); 
            end
        else
            if (newExposureTime < extendedRange(1)) || (newExposureTime > extendedRange(2))
                error('Exposure time was set to ''%d'', while in ''%s'' sensitivity mode. In this sensitivity range it must be set to either a numeric value in range [%d - %d], or equal to the string ''%s''!', ...
                    newExposureTime, obj.privateSensitivityMode, extendedRange(1), extendedRange(2), obj.validExposureTimes{1}); 
            end
        end
    end
    
    % Set exposureTime
    if (ischar(newExposureTime))
        obj.writeSerialPortCommand('commandString', 'SE0');
    else
        obj.writeSerialPortCommand('commandString', sprintf('SE%.5d', newExposureTime));
    end
    
    % Check the response.
    obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after SEx command');
        
    % update the private copy
    obj.privateExposureTime = newExposureTime;
end

