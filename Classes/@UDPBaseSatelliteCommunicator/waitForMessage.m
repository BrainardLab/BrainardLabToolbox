function packet = waitForMessage(obj, msgLabel, varargin)
    
    p = inputParser;
    p.addRequired('msgLabel');
    p.addOptional('timeOutSecs', Inf,@isnumeric);
    p.addOptional('pauseTimeSecs', 0, @isnumeric);
    p.addOptional('timeOutAction', obj.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {obj.NOTIFY_CALLER, obj.THROW_ERROR}))); 
    p.addOptional('badTransmissionAction', obj.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {obj.NOTIFY_CALLER, obj.THROW_ERROR}))); 
    parse(p,msgLabel,varargin{:});
    
    pauseTimeSecs = p.Results.pauseTimeSecs;
    timeOutSecs = p.Results.timeOutSecs;
    expectedMessageLabel = p.Results.msgLabel;
    timeOutAction = p.Results.timeOutAction;
    badTransmissionAction = p.Results.badTransmissionAction;
    
    % Always set it to notify caller
    badTransmissionAction = obj.NOTIFY_CALLER
    timeOutAction = obj.THROW_ERROR
    
    
    udpHandle = obj.udpHandle;
        
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
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseTimeSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting for message ''%s'' to arrive', expectedMessageLabel), timeOutAction);
        return;
    end
    
    % Read the leading packet label
    packet.messageLabel = matlabNUDP('receive', udpHandle);
    
    % test
    if (strfind(packet.messageLabel, 'SENDING_SMALL_STRUCT'))
       packet.messageLabel = 'SENDING_SMALL_S';
    end
        
    if (~strcmp(packet.messageLabel, expectedMessageLabel))
        messageToPrint = sprintf('Leading message label (''%s'') does not match expected message label (''%s'')', packet.messageLabel, expectedMessageLabel);
        packet = informSender_ReceivedMessageLabelNotMatchingExpected(udpHandle, packet, expectedMessageLabel, messageToPrint, obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED);
        return;
    end
    
    % Read the number of bytes
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseTimeSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting to receive number of bytes for message ''%s''', expectedMessageLabel), timeOutAction);
        return;
    end
    bytesString = matlabNUDP('receive', udpHandle);
    numBytes = str2double(bytesString);
    
    % Read all bytes
    pauseSecs = 0;
    theData = zeros(1,numBytes);
    for k = 1:numBytes
        packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseSecs);
        if (packet.timedOutFlag)
            obj.executeTimeOut(sprintf('while waiting to receive byte %d/%d of message ''%s''', k, numBytes, expectedMessageLabel), timeOutAction);
            return;
        end
        datum = matlabNUDP('receive', udpHandle);
        theData(k) = str2double(datum);
    end
    
    % Read the message label again
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting to verify the label of message ''%s''', expectedMessageLabel), timeOutAction);
        return;
    end
    
    trailingMessageLabel = matlabNUDP('receive', udpHandle);
    if (~strcmp(packet.messageLabel,trailingMessageLabel))
       % Now we definitely have a bad transmission so set this flag
       messageToPrint = sprintf('Trailing message label mismatch: expected ''%s'', received: ''%s''.\n', expectedMessageLabel, trailingMessageLabel);
       packet = informSender_BadTransmission(udpHandle, packet, expectedMessageLabel, messageToPrint, obj.BAD_TRANSMISSION);
       return;
    end

    % Reconstruct data object
    if (numBytes > 0)
        packet.messageData = getArrayFromByteStream(uint8(theData));
    else
        packet.messageData = [];
    end
  
    % Send acknowledgment if we reached this point
    matlabNUDP('send', udpHandle, obj.ACKNOWLEDGMENT);
end

function packet = informSender_ReceivedMessageLabelNotMatchingExpected(udpHandle, packet, expectedMessageLabel, errorMessageToSend)
    fprintf(2,'\n%s\n', messageToPrint);
    packet.mismatchedMessageLabel = expectedMessageLabel;
    matlabNUDP('send', udpHandle, errorMessageToSend);
end

function packet = informSender_BadTransmission(udpHandle, packet, expectedMessageLabel, messageToPrint, errorMessageToSend)
    fprintf(2,'\n%s\n', messageToPrint);
    packet.mismatchedMessageLabel = expectedMessageLabel;
    packet.badTransmissionFlag = true;
    matlabNUDP('send', udpHandle, errorMessageToSend);
end
