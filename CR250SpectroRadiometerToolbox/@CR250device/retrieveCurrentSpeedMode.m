% Method to retrieve the current speedMode

%  History:
%    April 2025  NPC  Wrote it


function [status, response, val] = retrieveCurrentSpeedMode(obj, showFullResponse)

    % Retrieve the sync mode
    commandID = sprintf('RS Speed');
    [status, response] = CR250_device('sendCommand', commandID);

    val = [];
    
    if (status == 0)
        if (~isempty(response))
            % Parse response
            [parsedResponse, fullResponse, responseIsOK] = obj.parseResponse(response, commandID);
            
            if (~responseIsOK)
                fprintf(2, 'Device response to retrieving the SPEED mode is NOT OK !!\n')
            end

            if (~strcmp(obj.verbosity, 'min'))
                fprintf('\n---> DEVICE_RESPONSE to ''%s'' command has %d lines', commandID, numel(parsedResponse));
                for iResponseLine = 1:numel(parsedResponse)
                    fprintf('\n\tLine-%d: ''%s''', iResponseLine, parsedResponse{iResponseLine});
                end
            end

            if (numel(parsedResponse) == 1)
                theResponseString = parsedResponse{1};
                val = theResponseString;
            end

            if (showFullResponse) && (~strcmp(obj.verbosity, 'min'))
                fprintf('\nFull response: ''%s''.', fullResponse);
            end
        end
    elseif (status ~= 0)
        fprintf(2, 'Command failed!!!. Status = %d!!!', status);
    end

end