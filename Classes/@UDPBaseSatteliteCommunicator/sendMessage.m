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
    fprintf('Sending message label: %s\n', messageLabel);
    matlabNUDP('send', udpHandle, messageLabel);
    
    % Serialize data
    fprintf('Serializing data\n');
    byteStream = getByteStreamFromArray(messageData);
     
    % Send number of bytes to read
    fprintf('Sending# of bytes (%d) for messageData: %s\n', numel(byteStream), messageData);
    matlabNUDP('send', udpHandle, sprintf('%d', numel(byteStream)));
        
    % Send each byte separately
    for k = 1:numel(byteStream)
       fprintf('Sedning byte %d of %d\n', k, numel(byteStream);
       matlabNUDP('send', udpHandle, sprintf('%03d', byteStream(k)));
    end
    
    % Send the trailing message label
    fprintf('Sending the trailing message label\n');
    matlabNUDP('send', udpHandle, messageLabel);
       
    % Wait for acknowledgment that the message was received OK
    fprintf('Waiting for ACK\n');
    timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
    fprintf('Reading ACK\n');
    if (timedOutFlag)
        executeTimeOut(obj, 'while waiting to receive acknowledgment for message sent', timeOutAction);
        transmissionStatus = obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD;
        return;
    else
        transmissionStatus = matlabNUDP('receive', udpHandle);
    end
end

