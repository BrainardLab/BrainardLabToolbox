function [parsedResponse, fullResponse] = parseResponse(obj, response, commandID)
    
    fullResponse = response;

    % Remove 'OK:0: prefix
    prefixString = 'OK:0:';
    response = strrep(response, prefixString, '');

    % Remove commandID which is replicated
    response = strrep(response, sprintf('%s:',commandID), '');

    % find how many lines is contained in the response
    indexOfRETURNkeys = find(response == 13);

    iBegin = 1;
    parsedResponse = {};
    for responseLine = 1:numel(indexOfRETURNkeys)
        iEnd = indexOfRETURNkeys(responseLine);
        parsedResponse{responseLine} = char(response(iBegin:(iEnd-1)));
        iBegin = iEnd+2;
    end
end