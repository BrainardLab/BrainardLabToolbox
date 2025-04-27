% Method to set the device fixed exposure time (in milliseconds)
function status = setDeviceFixedExposureTimeMilliseconds(obj, val)
    %if (val >= 10) && (val <= 10*1000)
    %else
    %    fprintf(2,'Manual sync frequency (%2.3f) is out of [10 Hz - 10 kHz] range\n', val);
    %end
    
    % Set the manual sync frequency mode
    commandID = sprintf('SM Exposure');
    exposureTimeMilliseconds = int32((val));
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
