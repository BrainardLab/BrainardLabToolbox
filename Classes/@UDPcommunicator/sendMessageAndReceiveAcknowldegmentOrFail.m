function sendMessageAndReceiveAcknowldegmentOrFail(obj, messageTuple)
    % unwrap message
    if (numel(messageTuple) == 1)
        messageLabel = messageTuple{1};
        messageValue = [];
    else
        messageLabel = messageTuple{1};
        messageValue = messageTuple{2};
    end
    
    % Send the message
    if (isempty(messageValue))
        status = obj.sendMessage(messageLabel, 'timeOutSecs', 2, 'maxAttemptsNum', 3);
    else
        status = obj.sendMessage(messageLabel, 'withValue', messageValue, 'timeOutSecs', 2, 'maxAttemptsNum', 3);
    end
    
    % Get this backtrace of all functions leading to this point
    dbs = dbstack;
    backTrace = ''; depth = length(dbs);
    while (depth >= 1)
        backTrace = sprintf('%s-> %s ', backTrace, dbs(depth).name);
        depth = depth - 1;
    end
    
    % Check status to ensure we received a 'TRANSMITTED_MESSAGE_MATCHES_EXPECTED' message
    assert(strcmp(status, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED), sprintf('%s: Exiting due to communication error.\nExpected label: ''%s'', Received label: ''%s''.\n', backTrace, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED, status));
end
