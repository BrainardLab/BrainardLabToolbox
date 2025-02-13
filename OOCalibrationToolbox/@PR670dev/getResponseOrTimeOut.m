% Method to read a response from the PR670 or timeout after timeoutInSeconds
function response = getResponseOrTimeOut(obj, timeoutInSeconds, timeoutString)

    if (obj.emulateHardware)
        response = '';
        fprintf(2,'PR670obj.getResponseOrTimeOut()- Emulating hardware\n');
        return;
    end
    
    waited = 0;
    inStr =[];
    while isempty(inStr) && (waited < timeoutInSeconds)
        WaitSecs(1);
        waited = waited+1;
        inStr = obj.readSerialPortData;
    end
    
    if (waited == timeoutInSeconds)
       error(timeoutString);
    end

    % Pick up entire buffer.
    response = inStr;
    while ~isempty(inStr)
        inStr = obj.readSerialPortData;
        response = [response inStr]; 
    end

    % Parse the return and make sure we got a 0.  Any other value means an error occured.
    qual = sscanf(response, '%d', 1);
    
    if qual ~= 0
        error('PR670dev.getResponseOrTimeOut received bad code: %d', qual);
    end
        
end

