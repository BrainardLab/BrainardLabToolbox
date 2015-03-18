% Method to set a new value for the cyclesToAverage property
function obj = privateSetCyclesToAverage(obj, newCyclesToAverage)

    if (obj.verbosity > 9)
        fprintf('In privateSetCyclesToAverage\n');
    end
    
    % determine if new value is different than its private counterpart
    if (obj.valuesAreSame(newCyclesToAverage, obj.privateCyclesToAverage))
        return;
    end
    
    timeoutInSeconds = 10;
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end

    if ((newCyclesToAverage < 1) || (newCyclesToAverage > 99))
        error('Cycles to average must be in the range [1-99]');
    end
    
    % Tell the device we're specifying a user defined frequency.
    obj.writeSerialPortCommand('commandString', sprintf('SN%.2d', newCyclesToAverage));

    % Check the response.
    obj.getResponseOrTimeOut(timeoutInSeconds, 'No response after SNxx command');
        
    % update the private copy
    obj.privateCyclesToAverage = newCyclesToAverage;
end

