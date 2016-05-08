function receivedResponse = sendParamValueAndWaitForResponse(obj, paramNameAndValue, expectedResponse, varargin)

    p = inputParser;
    p.addRequired('paramNameAndValue', @iscell);
    p.addRequired('expectedResponseLabel', @iscell);
    p.parse(paramNameAndValue, expectedResponse);
    
    obj.sendParamValue(paramNameAndValue, varargin{:});
    expectedResponseLabel = expectedResponse{1};
    receivedResponse = obj.receiveParamValue(expectedResponseLabel, 'timeOutSecs', Inf);

    if (numel(expectedResponse) == 2)
        expectedResponseValue = expectedResponse{2};
        if (~strcmp(receivedResponse, expectedResponseValue))
            if (strcmp(paramValue, obj.ABORT_MAC_DUE_TO_WINDOWS_FAILURE))
                Speak('Windows computer experienced a fatal error. Mac computer aborting now.');
                error('Windows computer experienced a fatal error. Mac computer aborting now.\n');
            else
                error('Expected response value: ''%s'', received: ''%s'' .', expectedResponseValue, receivedResponse);
            end
        end
    end
end

