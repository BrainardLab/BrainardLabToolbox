% Method to set the device fixed exposure time (in milliseconds)
function status = setDeviceFixedExposureTimeMilliseconds(obj, val)


    if (~isnumeric(val))
        error('Exposure time must be a scalar');
    end

    % Check that we are in the range
    [status, response, minExposure, maxExposure] = obj.retrieveExposureTimeRange(obj.showDeviceFullResponse);
    if (status == 0)
        if (~isempty(response))
            if (val < minExposure)
                error('Exposure time (%d) is less than the minimum allowable value (%d)\n', val, minExposure);
            end
            if (val > maxExposure)
                error('Exposure time (%d) is greater than the maximum allowable value (%d)\n', val, maxExposure);
            end
        end
    end


    % Pause for 1.5 seconds
    pause(2.0);

    % Set the fixed exposure time
    commandID = sprintf('SM Exposure');
    exposureTimeMilliseconds = val;
    [status, response] = CR250_device('sendCommand', commandID, exposureTimeMilliseconds);

    if (status == 0) 
        if (~isempty(response))
            % Parse response
            [parsedResponse, fullResponse] = obj.parseResponse(response, commandID);
            if (contains(fullResponse, 'No errors'))
                if (~strcmp(obj.verbosity, 'min'))
                    fprintf('\nSuccessfully set device exposure time to %2.0f milliseconds', val);
                end
            else  %if (contains(fullResponse, 'Invalid '))
                fprintf(2,'\n-----------------------------------------------------------------');
                fprintf(2,'\nFailed to set the device exposute time to %2.0f milliseconds.', val);
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
