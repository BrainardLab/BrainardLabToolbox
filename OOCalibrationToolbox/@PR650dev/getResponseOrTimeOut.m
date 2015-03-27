% Method to read a response from the PR650 or timeout after timeoutInSeconds
function response = getResponseOrTimeOut(obj, timeoutInSeconds, timeoutString)

    waited = 0;
    inStr =[];
    while isempty(inStr) && (waited < timeoutInSeconds)
        WaitSecs(1);
        waited = waited+1;
        inStr = obj.readSerialPortData;
    end
    if waited == timeoutInSeconds
        error(timeoutString);
    end

    % Pick up entire buffer.
    response = inStr;
    while ~isempty(inStr)
        inStr = obj.readSerialPortData;
        response = [response inStr]; 
    end
end
