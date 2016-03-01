function response = sendParamValueAndWaitForResponse(obj, paramNameAndValue, expectedResponseLabel, varargin)

    p = inputParser;
    p.addRequired('paramNameAndValue', @iscell);
    p.addRequired('expectedResponseLabel', @iscell);
    p.parse(paramNameAndValue, expectedResponseLabel);
    
    obj.sendParamValue(paramNameAndValue, varargin{:});
    response = obj.receiveParamValue(expectedResponseLabel{1}, 'timeOutSecs', Inf, 'consoleMessage', 'What is the response ?');
end

