function packet = waitForMessage(obj, msgLabel, varargin)
    
    p = inputParser;
    p.addRequired('msgLabel');
    p.addOptional('timeOutSecs', Inf,@isnumeric);
    p.addOptional('timeOutAction', obj.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {obj.NOTIFY_CALLER, obj.THROW_ERROR}))); 
    p.addOptional('badTransmissionAction', obj.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {obj.NOTIFY_CALLER, obj.THROW_ERROR}))); 
    parse(p,msgLabel,varargin{:});
    timeOutSecs = p.Results.timeOutSecs;
    expectedMessageLabel = p.Results.msgLabel;
    timeOutAction = p.Results.timeOutAction;
    badTransmissionAction = p.Results.badTransmissionAction;
    
    if isempty(expectedMessageLabel)
        expectedMessageLabel = '';
    end
    
    if (~ischar(expectedMessageLabel))
        error('%s The expected message label must be a string, or an empty array, i.e.: []\n',obj.waitForMessageSignature);
    end
    
    % initialize response struct
    packet = struct(...
        'messageLabel', '', ...                 % a string
        'messageData', [], ...                  % either empty or a struct
        'timedOutFlag', false, ...              % a flag indicating whether we timeout - is this needed?
        'badTransmissionFlag', false, ...       % a flag indicating whether we encountered bad transmiddion data
        'mismatchedMessageLabel', '' ...        % mistmatched label
    );

    % Wait until we receive something or we timeout
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting for message ''%s'' to arrive', expectedMessageLabel), timeOutAction);
        return;
    end
    
    % Read the leading packet label
    packet.messageLabel = matlabUDP('receive');

    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting to receive number of bytes for message ''%s''', expectedMessageLabel), timeOutAction);
        return;
    end
    
    % Read number of bytes of ensuing data
    bytesString = matlabUDP('receive');
    numBytes = str2double(bytesString);
    
    % Read all bytes
    theData = [];
    for k = 1:numBytes
        packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
        if (packet.timedOutFlag)
            obj.executeTimeOut(sprintf('while waiting to receive byte %d/%d of message ''%s''', k, numBytes, expectedMessageLabel), timeOutAction);
            return;
        end
        theData(k) = str2double(matlabUDP('receive'));
    end

    % Read the message label again
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting to verify the label of message ''%s''', expectedMessageLabel), timeOutAction);
        return;
    end
    
    trailingMessageLabel = matlabUDP('receive');
    if (~strcmp(packet.messageLabel,trailingMessageLabel))
        if (strcmp(badTransmissionAction, obj.THROW_ERROR))
            % ask remote host to abort
            obj.sendMessage(obj.ABORT_MESSAGE.label, obj.ABORT_MESSAGE.value);
            error('Trailing message label (''%s'') does not match leading message label (''%'').\nAsked remote host to abort.', trailingMessageLabel, packet.messageLabel)
        else
            packet.badTransmissionFlag = true;
            return;
        end
    end

    % Reconstruct data object
    if (numBytes > 0)
        packet.messageData = getArrayFromByteStream(uint8(theData));
    else
        packet.messageData = [];
    end
  
    % Send acknowledgment if all OK
    if (strcmp(expectedMessageLabel, packet.messageLabel))
        matlabUDP('send', obj.ACKNOWLEDGMENT);
    else
        packet.mismatchedMessageLabel = expectedMessageLabel;
        matlabUDP('send', obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED);
    end
end

    