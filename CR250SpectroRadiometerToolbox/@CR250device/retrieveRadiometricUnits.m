% Method to retrieve the radiometric units

%  History:
%    April 2025  NPC  Wrote it


function [status, response] = retrieveRadiometricUnits(obj)

    % Retrieve the radiometric units
    commandID = sprintf('RM Radiometric');
    [status, response] = CR250_device('sendCommand', commandID);

    if (status == 0)
        if (~isempty(response))
            % Parse response
            [parsedResponse, fullResponse, responseIsOK] = obj.parseResponse(response, commandID);
            
            if (~responseIsOK)
                fprintf(2, 'Device response to retrieving the radiometric units is NOT OK !!\n')
            end

            fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
            for iResponseLine = 1:numel(parsedResponse)
                fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
            end

            if (numel(parsedResponse) == 1)
                theResponseString = parsedResponse{1};
                %    obj.manualSyncFrequency = str2num(strrep(theResponseString, 'Hz', ''));
            end
            fprintf('\n');
        end
    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

end