% Method to retrieve a measurements
function retrieveMeasurement(obj)
    
    Speak('Retrieving data. Please wait.')
    tic

    switch (obj.measurementType)
        case 'spectrum'
            commandID = 'RM Spectrum';

        otherwise
            obj.validMeasurementTypes
            fprintf(2, 'Unknown measurement type: ''%s''.', measurementType);
    end

    % Retrieve the measurement
    [status, response] = CR250_device('sendCommand', commandID);

    if ((status == 0) && (~isempty(response) > 0))
        [parsedResponse, fullResponse, responseIsOK] = obj.parseResponse(response, commandID);
        
        if (~responseIsOK)
            fprintf(2, 'Device response to retrieving the data is NOT OK !! \n');
            Speak('Data are compromised');
        end

        fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
        for iResponseLine = 1:numel(parsedResponse)
            fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
        end
        if (obj.showDeviceFullResponse)
            fprintf('\nFull response: ''%s''.', fullResponse);
        end

    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

    % Report back
    doneText = sprintf('\nRetrieved data after %2.1f seconds\n', toc);
    Speak(doneText);

    disp(doneText);

end