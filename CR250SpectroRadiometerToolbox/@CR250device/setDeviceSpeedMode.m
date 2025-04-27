% Method to set the device speed mode
function status = setDeviceSpeedMode(obj, val)
    if (ismember(val, obj.validSpeedModes))
        switch (val)
            case 'Slow'
                speedModeID = 0;
            case 'Normal'
                speedModeID = 1;
            case 'Fast'
                speedModeID = 2;
            case '2x Fast'
                speedModeID = 3;
        end % switch
    else
        fprintf(2,'Incorrect speed mode:''%s''. Type CR250device.validSpeedModes to see all available modes.', val);
    end
    
    % Pause
    pause(obj.commandTriggerDelay);

    % Set the speed mode
    commandID = sprintf('SM Speed %d', speedModeID);
    [status, response] = CR250_device('sendCommand', commandID);
    
    if (status == 0) 
        if (~isempty(response))
            % Parse response
            [parsedResponse, fullResponse] = obj.parseResponse(response, commandID);
            if (contains(fullResponse, 'No errors'))
                if (~strcmp(obj.verbosity, 'min'))
                    fprintf('\nSuccessfully set device speed mode to ''%s''.', val);
                end
            elseif (contains(fullResponse, 'Invalid Speed Mode'))
                fprintf(2,'\n-----------------------------------------------------------------');
                fprintf(2,'\nFailed to set device speed mode to ''%s''.', val);
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
