% Method to conduct a measurement

%  History:
%    April 2025  NPC  Wrote it


function measure(obj)
    Speak('Measuring. Please wait.')
    tic

    % Conduct a measurement
    commandID = 'M';
    [status, response] = CR250_device('sendCommand', commandID);

    % Wait for response
    if ((status == 0) && (~isempty(response) > 0))
        [parsedResponse, fullResponse] = obj.parseResponse(response, commandID);
        fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        for iResponseLine = 1:numel(parsedResponse)
            fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
        end
        theFirstLine = parsedResponse{1};
        if (~strcmp(theFirstLine, 'No errors'))
            fprintf(2,'\nError in measurement\n');
        end

        if (obj.showDeviceFullResponse)
            fprintf('\nFull response: ''%s''.', fullResponse);
        end

    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

    % Report back
    doneText = sprintf('\nCompleted after %2.1f seconds\n', toc);
    Speak(doneText);

    disp(doneText);

end