function parameterValue = getMessageValueWithMatchingLabelOrFail(obj, messageLabel)

    % Wait for ever for a message to be received
    response = obj.waitForMessage(messageLabel, 'timeOutSecs', Inf);
    
    if (~strcmp(obj.verbosity,'none'))
        % Get this backtrace of all functions leading to this point
        dbs = dbstack;
        backTrace = ''; depth = length(dbs);
        while (depth >= 1)
            backTrace = sprintf('%s-> %s ', backTrace, dbs(depth).name);
            depth = depth - 1;
        end
    else
         backTrace = 'no backtrace';
    end
    
    % Check for communication error and abort if one occurred
    assert(strcmp(response.msgLabel, messageLabel), sprintf('%s: Exiting due to mismatch in message labels.\nExpected label: ''%s'', Received label: ''%s''.\n', backTrace, messageLabel, response.msgLabel));
    
    % Get the message value received
    parameterValue = response.msgValue;
end
