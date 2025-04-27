% Method to set the device exposure mode
function status = setDeviceExposureMode(obj, val)
    if (ismember(val, obj.validExposureModes))
        switch (val)
            case 'Auto'
                exposureModeID = 0;
            case 'Fixed'
                exposureModeID = 1;
        end % switch
    else
        fprintf(2,'Incorrect exposure mode:''%s''. Type CR250device.validExposureModes to see all available modes.', val);
    end
    
    % Pause for 1.5 seconds
    pause(1.5);

    % Set the exposure mode
    commandID = sprintf('SM ExposureMode %d', exposureModeID);
    [status, response] = CR250_device('sendCommand', commandID);
    
    if (status == 0) 
        if (~isempty(response))
            % Parse response
            [parsedResponse, fullResponse] = obj.parseResponse(response, commandID);
            if (contains(fullResponse, 'No errors'))
                if (~strcmp(obj.verbosity, 'min'))
                    fprintf('\nSuccessfully set device exposure mode to ''%s''.', val);
                end
            elseif (contains(fullResponse, 'Invalid Speed Mode'))
                fprintf(2,'\n-----------------------------------------------------------------');
                fprintf(2,'\nFailed to set device exposure mode to ''%s''.', val);
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
