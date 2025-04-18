% Method to set the device sync mode
function status = setDeviceSyncMode(obj, val)
    if (ismember(val, obj.validSyncModes))
        switch (val)
            case 'None'
                syncModeID = 0;
            case 'Auto'
                syncModeID = 1;
            case 'Manual'
                syncModeID = 2;
            case 'NTSC'
                syncModeID = 3;
            case 'PAL'
                syncModeID = 4;
            case 'CINEMA'
                syncModeID = 5;
        end % switch
    else
        fprintf(2,'Incorrect sync mode:''%s''. Type CR250dev.validSyncModes to see all available modes.', val);
    end
    
    % Set the sync mode
    commandID = sprintf('SM SyncMode %d', syncModeID);
    [status, response] = CR250_device('sendCommand', commandID);
    
    if (status == 0) 
        if (~isempty(response))
            % Parse response
            [parsedResponse, fullResponse] = obj.parseResponse(response, commandID);
            if (contains(fullResponse, 'No errors'))
                fprintf('\nSuccessfully set device sync mode to ''%s''.', val);
            elseif (contains(fullResponse, 'Invalid Sync Mode'))
                fprintf(2,'\n-----------------------------------------------------------------');
                fprintf(2,'\nFailed to set device sync mode to ''%s''.', val);
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
