% Method to query the CR250 for various infos

%  History:
%    April 2025  NPC  Wrote it

function retrieveDeviceInfo(obj, commandID, showFullResponse)
    
    % Send the command
    [status, response] = CR250_device('sendCommand', commandID);

    if ((status == 0) && (~isempty(response) > 0))
        % Parse response
        [parsedResponse, fullResponse, responseIsOK] = obj.parseResponse(response, commandID);

        if (~responseIsOK)
            fprintf(2, 'Device response to retrieving info is NOT OK !!\n')
        end

        if (~strcmp(obj.verbosity, 'min'))
            fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        end

        for iResponseLine = 1:numel(parsedResponse)
            if (~strcmp(obj.verbosity, 'min'))
                fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
            end
            switch (commandID)
                case 'RC ID'
                    obj.deviceSerialNum = parsedResponse{iResponseLine};
                case 'RC Firmware'
                    obj.firmware = parsedResponse{iResponseLine};
                case 'RS SyncMode'
                    obj.syncMode = parsedResponse{iResponseLine};
            end
        end
        if (showFullResponse) && (~strcmp(obj.verbosity, 'min'))
            fprintf('\nFull response: ''%s''.', fullResponse);
        end
    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

end