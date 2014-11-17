function syncFreq = measureSyncFreq(obj)
    if (obj.verbosity > 9)
        fprintf('In PR650obj.measureSyncFreq() method\n');
    end
    
    % Flush buffers.
    serialData = obj.readSerialPortData();
    % Send command.
    IOPort('write', obj.portHandle, ['f' char(10)]);
    % Get response or time-out after 30 seconds
    timeOutPeriodInSeconds = 30;
    startTime = GetSecs;
    serialData = [];
    while ((isempty(serialData)) && (GetSecs-startTime < timeOutPeriodInSeconds))
        serialData = [serialData obj.readSerialPortData];
    end
    if (isempty(serialData))
        fprintf('* * * * Sync frequency could not be retrieved. Timed-out after %2.1f seconds. * * * *\n', timeOutPeriodInSeconds);
    else

        serialData = [serialData obj.readSerialPortData];
        qual = -1;
        [raw, count] = sscanf(serialData,'%f,%f',2);
        if (count == 2)
            qual = raw(1);
            syncFreq = raw(2);
            if (obj.verbosity > 9)
                disp('syncFreq, qual:');
                [syncFreq qual]
            end
        end
        if qual ~= 0
            syncFreq = [];
        end
    end
end
        
    
    
