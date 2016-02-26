function messageValue = VSGOLGetParameter(UDPobj, messageLabel)

    % Get this function's name
    dbs = dbstack;
    backTrace = ''; depth = 1;
    while (depth <= length(dbs))
        backTrace = sprintf('%s -> %s ', backTrace, dbs(depth).name);
        depth = depth + 1;
    end
    
    % Wait for ever for a message to be received
    response = UDPobj.waitForMessage(messageLabel, 'timeOutSecs', Inf);
    
    % Check for communication error and abort if one occurred
    assert(strcmp(response.msgLabel, messageLabel), sprintf('%s: Exiting due to communication error.\nExpected label: ''%s'', received label: ''%s''.\n', backTrace, messageLabel, response.msgLabel));
    
    % Get the message value received
    messageValue = response.msgValue;
end