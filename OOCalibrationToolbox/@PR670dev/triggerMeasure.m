function triggerMeasure(obj)
   
    % configure syncMode
    if (strcmp(obj.syncMode, 'AUTO'))
        % See if we can sync to the source and set sync mode appropriately.
        sourceFreq = obj.measureSourceFrequency();
        
        if (~isempty(sourceFreq))
            obj.setOptions('syncMode', 'AUTO');
        else
            obj.setOptions('syncMode', 'OFF');
        end
    end
    
    if (obj.emulateHardware)
        fprintf(2,'PR670obj.triggerMeasure()- Emulating hardware\n');
        return;
    end
    
    % Flushing buffers
    dumpStr = '0';
    while ~isempty(dumpStr)
        dumpStr = obj.readSerialPortData;
    end
    
    % Send the measurement command
    obj.writeSerialPortCommand('commandString', 'M5');
    
end