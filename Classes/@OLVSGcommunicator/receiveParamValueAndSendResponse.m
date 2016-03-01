function receiveParamValueAndSendResponse(obj, paramNameAndValueToBeReceived, paramNameAndValueToBeSent, varargin)
    p = inputParser;
    p.addRequired('paramNameAndValueToBeReceived', @iscell);
    p.addRequired('paramNameAndValueToBeSent', @iscell);
    p.parse(paramNameAndValueToBeReceived, paramNameAndValueToBeSent);
    
    paramValue = obj.receiveParamValue(paramNameAndValueToBeReceived{1}, varargin);
    if (~strcmp(paramValue, paramNameAndValueToBeReceived{2}))
        error('Expected param value: ''%s'', received: ''%s'' .', paramNameAndValueToBeReceived{2}, paramValue);
    end
    
    obj.sendParamValue(paramNameAndValueToBeSent, 'timeOutSecs', 2, 'maxAttemptsNum', 1);
end


