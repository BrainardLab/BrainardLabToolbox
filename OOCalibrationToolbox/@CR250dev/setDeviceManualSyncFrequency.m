% Method to set the device manual sync frequency
function status = setDeviceManualSyncFrequency(obj, val)

    if (~isnumeric(val))
        error('Manual sync frequency must be a scalar');
    end

    if (val >= 10) && (val <= 10*1000)
    else
        error('\nManual sync frequency (%2.3f) is out of [10 Hz - 10 kHz] range\n', val);
    end
    
    % Pause
    pause(obj.commandTriggerDelay);
    
    % Set the manual sync frequency mode
    commandID = sprintf('SM SyncFreq');
    syncFrequencyMilliHz = val;
    [status, response] = CR250_device('sendCommand', commandID, syncFrequencyMilliHz);

    if (status == 0) 
        if (~isempty(response))
            % Parse response
            [parsedResponse, fullResponse] = obj.parseResponse(response, commandID);
            if (contains(fullResponse, 'No errors'))
                if (obj.verbosityIsNotMinimum)
                    fprintf('\nSuccessfully set device sync frequency to %2.3f Hz.', val);
                end
            else %if (contains(fullResponse, 'Invalid Sync Mode'))
                fprintf(2,'\n-----------------------------------------------------------------');
                fprintf(2,'\nFailed to set the SYNC frequency to %2.3f.', val);
                fprintf(2,'\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
                for iResponseLine = 1:numel(parsedResponse)
                    fprintf(2,'\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
                end
                fprintf(2,'\n-----------------------------------------------------------------\n');
            end
        end
    else
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end
end