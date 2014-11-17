% Method to set sync frequency for source
% When value = 0, do not use sync mode
% When value = 1, use last sync measurement
function setSyncFreq(obj, syncFreq)  
    if (obj.verbosity > 9)
        fprintf('In PR650obj.setSyncFreq() method\n');
    end
    
    % Flush buffers.
    serialData = obj.readSerialPortData();

    % Send command
    if (syncFreq ~= 0)
        IOPort('write', obj.portHandle, ['s01,,,,' num2str(syncFreq) ',0,01,1' char(10)]);
    else
        IOPort('write', obj.portHandle, ['s01,,,,' ',0,01,1' char(10)]);
    end

    % Get response or time-out after 30 seconds
    timeOutPeriodInSeconds = 30;
    startTime = GetSecs;
    serialData = [];
    while ((isempty(serialData)) && (GetSecs-startTime < timeOutPeriodInSeconds))
        serialData = [serialData obj.readSerialPortData];
    end

    if (isempty(serialData))
        fprintf('* * * * Sync frequency could not be set. Timed-out after %2.1f seconds. * * * * \n', timeOutPeriodInSeconds);
    else
        qual = sscanf(serialData, '%f', 1);
        if qual ~= 0
            fprintf('Return string was %s\n', readStr);
            error('Can''t set parameters');
        else
            if (obj.verbosity > 9)
                fprintf('qual after set sync freq: %f\n', qual); 
            end
        end
    end
end