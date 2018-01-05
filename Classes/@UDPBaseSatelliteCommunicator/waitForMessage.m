function packet = waitForMessage(obj, msgLabel, varargin)

    p = inputParser;
    p.addRequired('msgLabel');
    p.addOptional('timeOutSecs', Inf,@isnumeric);
    p.addOptional('pauseTimeSecs', 0, @isnumeric);
    parse(p,msgLabel,varargin{:});

    pauseTimeSecs = p.Results.pauseTimeSecs;
    timeOutSecs = p.Results.timeOutSecs;
    expectedMessageLabel = p.Results.msgLabel;
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
        obj.executeTimeOut(sprintf('while waiting for message ''%s'' to arrive', expectedMessageLabel));
        return;
    end

    % Read the leading packet label
    packet.messageLabel = matlabNUDP('receive', udpHandle);

    if (~strcmp(packet.messageLabel, expectedMessageLabel))
        messageToPrint = sprintf('Leading message label (''%s'') does not match expected message label (''%s'')', packet.messageLabel, expectedMessageLabel);
        packet = informSender_ReceivedMessageLabelNotMatchingExpected(obj, udpHandle, packet, expectedMessageLabel, messageToPrint);
        return;
    end

    % Read the number of bytes
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseTimeSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting to receive number of bytes for message ''%s''', expectedMessageLabel));
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
            obj.executeTimeOut(sprintf('while waiting to receive byte %d/%d of message ''%s''', k, numBytes, expectedMessageLabel));
            return;
        end
        datum = matlabNUDP('receive', udpHandle);
        theData(k) = str2double(datum);
    end

    % Read the message label again
    packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseSecs);
    if (packet.timedOutFlag)
        obj.executeTimeOut(sprintf('while waiting to verify the label of message ''%s''', expectedMessageLabel));
        return;
    end

    trailingMessageLabel = matlabNUDP('receive', udpHandle);

    if (~strcmp(packet.messageLabel,trailingMessageLabel))
       % Now we definitely have a bad transmission so set this flag
       messageToPrint = sprintf('Trailing message label mismatch: expected ''%s'', received: ''%s''.\n', expectedMessageLabel, trailingMessageLabel);
       packet = informSender_BadTransmission(obj, udpHandle, packet, expectedMessageLabel, messageToPrint);
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

function packet = informSender_ReceivedMessageLabelNotMatchingExpected(obj, udpHandle, packet, expectedMessageLabel, messageToPrint)
    fprintf('\n<strong>%s</strong>\n', messageToPrint);
    flushedContents = obj.flushQueue();
    %fprintf('<strong>Flushed data:%s\n</strong>', flushedContents);
    packet.mismatchedMessageLabel = expectedMessageLabel;
    matlabNUDP('send', udpHandle, obj.UNEXPECTED_MESSAGE_LABEL_RECEIVED);
end

function packet = informSender_BadTransmission(obj, udpHandle, packet, expectedMessageLabel, messageToPrint)
    fprintf('\n<strong>%s</strong>\n', messageToPrint);
    flushedContents = obj.flushQueue();
    %fprintf('<strong>Flushed data:%s\n</strong>', flushedContents);
    packet.mismatchedMessageLabel = expectedMessageLabel;
    packet.badTransmissionFlag = true;
    matlabNUDP('send', udpHandle, obj.BAD_TRANSMISSION);
end
