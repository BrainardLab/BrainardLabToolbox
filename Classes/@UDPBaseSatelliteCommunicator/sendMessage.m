function transmissionStatus = sendMessage(obj, msgLabel, msgData, varargin)
    p = inputParser;
    p.addRequired('msgLabel',@ischar);
    p.addRequired('msgData');
    p.addOptional('timeOutSecs', 5, @isnumeric);
    p.addOptional('timeOutAction', obj.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {obj.NOTIFY_CALLER, obj.THROW_ERROR}))); 
    p.addOptional('maxAttemptsNum',1, @isnumeric);
    parse(p,  msgLabel, msgData, varargin{:});

    messageLabel = p.Results.msgLabel;
    messageData  = p.Results.msgData;
    timeOutSecs  = p.Results.timeOutSecs;
    timeOutAction = p.Results.timeOutAction;
    maxAttemptsNum = p.Results.maxAttemptsNum;
    udpHandle    = obj.udpHandle;
    
    % Send the leading message label
    matlabNUDP('send', udpHandle, messageLabel);
    
    % Serialize data
    byteStream = getByteStreamFromArray(messageData);
     
    % Send number of bytes to read
    matlabNUDP('send', udpHandle, sprintf('%d', numel(byteStream)));
        
    % Send each byte separately
    for k = 1:numel(byteStream)
       matlabNUDP('send', udpHandle, sprintf('%03d', byteStream(k)));
    end
    
    % Send the trailing message label
    matlabNUDP('send', udpHandle, messageLabel);
       
    % Wait for acknowledgment that the message was received OK
    pauseTimeSecs = 0;
    timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseTimeSecs );
    if (timedOutFlag)
        executeTimeOut(obj, 'while waiting to receive acknowledgment for message sent', timeOutAction);
        transmissionStatus = obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD;
        return;
    else
        transmissionStatus = matlabNUDP('receive', udpHandle);
    end
end

