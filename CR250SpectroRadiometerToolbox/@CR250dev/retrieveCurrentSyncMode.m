% Method to retrieve the current syncMode
function val = retrieveCurrentSyncMode(obj)

    % Retrieve the sync mode
    commandID = sprintf('RS SyncMode');
    [status, response] = CR250_device('sendCommand', commandID)

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

    val = parsedResponse;
end