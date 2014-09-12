function triggerMeasure(obj)
%
    % Configure syncMode
    if (strcmp(obj.syncMode, 'ON'))
        if (obj.verbosity > 5)
            disp('Measure with synMode ON');
        end
        syncFreq = obj.measureSyncFreq();
        if (~isempty(syncFreq))
            obj.setSyncFreq(1);
        else
            obj.setSyncFreq(0);
        end
    else
        if (obj.verbosity > 5)
            disp('Measure with synMode OFF');
        end
        obj.setSyncFreq(0);
    end
    
    % Flush buffers.
    serialData = obj.readSerialPortData();

    % Send command
    IOPort('write', obj.portHandle, ['m0' char(10)]);
end 