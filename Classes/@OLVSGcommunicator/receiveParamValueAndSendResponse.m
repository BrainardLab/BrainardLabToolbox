function receiveParamValueAndSendResponse(obj, paramNameAndValueToBeReceived, paramNameAndValueToBeSent, varargin)
    p = inputParser;
    p.addRequired('paramNameAndValueToBeReceived', @iscell);
    p.addRequired('paramNameAndValueToBeSent', @iscell);
    p.parse(paramNameAndValueToBeReceived, paramNameAndValueToBeSent);
    
    paramName = paramNameAndValueToBeReceived{1};
    expectedParamValue = paramNameAndValueToBeReceived{2};
    paramValue = receiveParamValue(obj,paramName, varargin{:});
    if (~strcmp(paramValue, expectedParamValue))
        
        if (strcmp(paramValue, obj.ABORT_MAC_DUE_TO_WINDOWS_FAILURE))
            Speak('Windows computer experienced a fatal error. Mac computer aborting now.');
            error('Windows computer experienced a fatal error. Mac computer aborting now.\n');
        else
            error('Expected param value: ''%s'', received: ''%s'' .', expectedParamValue, paramValue);
        end
    end
    
    sendParamValue(obj,paramNameAndValueToBeSent, 'timeOutSecs', 2, 'maxAttemptsNum', 1);
end


