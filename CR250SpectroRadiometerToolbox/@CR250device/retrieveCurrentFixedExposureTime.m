% Method to retrieve the current fixed exposure time

%  History:
%    April 2025  NPC  Wrote it


function [status, response, val] = retrieveCurrentFixedExposureTime(obj, showFullResponse)

    % Retrieve the fixed exposure time
    commandID = sprintf('RS Exposure');
    [status, response] = CR250_device('sendCommand', commandID);
    val = [];
    
    if (status == 0)
        if (~isempty(response))
            % Parse response
            [parsedResponse, fullResponse, responseIsOK] = obj.parseResponse(response, commandID);
            
            if (~responseIsOK)
                fprintf(2, 'Device response to retrieving the fixed exposure time is NOT OK !!\n')
            end

            if (~strcmp(obj.verbosity, 'min'))
                fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
                for iResponseLine = 1:numel(parsedResponse)
                    fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
                end
                fprintf('\n');
            end

 
            if (numel(parsedResponse) == 1)
                 theResponseString = parsedResponse{1};
                 val = str2num(strrep(theResponseString, 'msec', ''));
            end
            
        end
    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

end