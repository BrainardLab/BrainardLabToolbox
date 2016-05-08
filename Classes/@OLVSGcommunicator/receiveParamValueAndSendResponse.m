function receiveParamValueAndSendResponse(obj, paramNameAndValueToBeReceived, paramNameAndValueToBeSent, varargin)
    p = inputParser;
    p.addRequired('paramNameAndValueToBeReceived', @iscell);
    p.addRequired('paramNameAndValueToBeSent', @iscell);
    p.parse(paramNameAndValueToBeReceived, paramNameAndValueToBeSent);
    
    paramName = paramNameAndValueToBeReceived{1};
    expectedParamValue = paramNameAndValueToBeReceived{2};
    paramValue = receiveParamValue(obj,paramName, varargin{:});
    if (~strcmp(paramValue, expectedParamValue))
       error('Expected param value: ''%s'', received: ''%s'' .', expectedParamValue, paramValue);
    end
    
    sendParamValue(obj,paramNameAndValueToBeSent, 'timeOutSecs', 2, 'maxAttemptsNum', 1);
end


