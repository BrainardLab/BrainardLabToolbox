% Method to parse the device response stream

%  History:
%    April 2025  NPC  Wrote it


function [parsedResponse, fullResponse, responseIsOK] = parseResponse(obj, response, commandID)

    fullResponse = response;
    responseIsOK = true;

    prefixString = 'OK:0:';
    if (~contains(response, prefixString))
        parsedResponse = response;
        responseIsOK = false;
        return;
    end

    % Remove 'OK:0: prefix
    response = strrep(response, prefixString, '');

    % Remove commandID which is replicated
    response = strrep(response, sprintf('%s:',commandID), '');

    % find how many lines is contained in the response
    indexOfRETURNkeys = find(response == 13);

    if (isempty(indexOfRETURNkeys))
        indexOfRETURNkeys = numel(response)+1;
    end

    iBegin = 1;
    parsedResponse = {};
    for responseLine = 1:numel(indexOfRETURNkeys)
        iEnd = indexOfRETURNkeys(responseLine);
        parsedResponse{responseLine} = char(response(iBegin:(iEnd-1)));
        iBegin = iEnd+2;
    end
end