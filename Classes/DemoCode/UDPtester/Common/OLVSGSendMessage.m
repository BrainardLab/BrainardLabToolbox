function [communicationError] = OLVSGSendMessage(UDPobj, messageTuple)
    % unwrap message
    if (numel(messageTuple) == 1)
        messageLabel = messageTuple{1};
        messageValue = [];
    else
        messageLabel = messageTuple{1};
        messageValue = messageTuple{2};
    end
    
    % Reset return args
    communicationError = [];
    
    % Get this function's name
    dbs = dbstack;
    if length(dbs)>1
        functionName = dbs(1).name;
    end
    
    if (isempty(messageValue))
        status = UDPobj.sendMessage(messageLabel, 'timeOutSecs', 2, 'maxAttemptsNum', 3, 'callingFunctionName', functionName);
    else
        status = UDPobj.sendMessage(messageLabel, 'withValue', messageValue, 'timeOutSecs', 2, 'maxAttemptsNum', 3, 'callingFunctionName', functionName);
    end
    % check status for errors
    if (~strcmp(status, UDPobj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED)) 
        communicationError = sprintf('Transmitted and expected (by the other end) messages do not match! sendMessage() returned with this message: ''%s''\n', status);
    end
end