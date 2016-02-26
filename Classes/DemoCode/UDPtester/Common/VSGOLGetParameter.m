function messageValue = VSGOLGetParameter(UDPobj, messageLabel, callingFunctionName2)

    % Get this function's name
    dbs = dbstack;
    if length(dbs)>1
        functionName = dbs(1).name
        callingFunctionName = dbs(2).name
    end
    
    % Wait for ever for a message to be received
    response = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf, 'callingFunctionName', functionName);
    
    % Check for communication error and abort if one occurred
    assert(~strcmp(response.msgLabel, messageLabel), sprintf('BackTrace: %s->%s. Exiting due to communication error.\nExpected label: ''%s'', received label: ''%s''.\n', callingFunctionName, functionName, messageLabel, response.msgLabel));
    
    % Get the message value received
    messageValue = response.msgValue;
    
    % Report to user
    fprintf('<strong>''%s''</strong>:: %s received as: ''%s''.\n', functionName, messageLabel, messageValue);
end