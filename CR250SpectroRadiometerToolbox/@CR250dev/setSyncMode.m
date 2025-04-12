function setSyncMode(obj, val)

    if (ismember(val, obj.validSyncModes))
        switch (val)
            case 'none'
                syncModeID = 0;
            case 'auto'
                syncModeID = 1;
            case 'manual'
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
    
    if ((status == 0) && (~isempty(response) > 0))
        % Parse response
        [parsedResponse, fullResponse] = obj.parseResponse(response, commandID);
        fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        for iResponseLine = 1:numel(parsedResponse)
            fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
        end
    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end
end
