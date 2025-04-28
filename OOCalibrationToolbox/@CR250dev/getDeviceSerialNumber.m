function deviceSerialNum = getDeviceSerialNumber(obj)

    % Send the command
    commandID = 'RC ID';
    [status, response] = CR250_device('sendCommand', commandID);

    if ((status == 0) && (~isempty(response) > 0))
        % Parse response
        [parsedResponse, fullResponse, responseIsOK] = obj.parseResponse(response, commandID);

        if (~responseIsOK)
            fprintf(2, 'Device response to retrieving info is NOT OK !!\n')
        end

        if (obj.verbosityIsNotMinimum)
            fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        end

        for iResponseLine = 1:numel(parsedResponse)
            if (obj.verbosityIsNotMinimum)
                fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
            end
            deviceSerialNum = parsedResponse{iResponseLine};

        end
        if (obj.showDeviceFullResponse) && (obj.verbosityIsNotMinimum)
            fprintf('\nFull response: ''%s''.', fullResponse);
        end

    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end


end
