function receivedResponse = sendParamValueAndWaitForResponse(obj, paramNameAndValue, expectedResponse, varargin)

    p = inputParser;
    p.addRequired('paramNameAndValue', @iscell);
    p.addRequired('expectedResponseLabel', @iscell);
    p.parse(paramNameAndValue, expectedResponse);
    
    obj.sendParamValue(paramNameAndValue, varargin{:});
    expectedResponseLabel = expectedResponse{1};
    receivedResponse = obj.receiveParamValue(expectedResponseLabel, 'timeOutSecs', Inf, 'consoleMessage', 'What is the response ?');

    if (numel(expectedResponse) == 2)
        expectedResponseValue = expectedResponse{2};
        if (~strcmp(receivedResponse, expectedResponseValue))
            error('Expected response value: ''%s'', received: ''%s'' .', expectedResponseValue, receivedResponse);
        end
    end
end

