% Method that waits for an expected message until the timeOut runs out.
% If the message label does not match the expected message label, of if there is
% something wrong with the transmitted data, or if we timeout we inform the sender and we return.
% If all is OK, we send an acknowldegment to the sender.
function packet = waitForMessage(obj, msgLabel, varargin)

    p = inputParser;
    p.addRequired('msgLabel');
    p.addOptional('timeOutSecs', Inf, @isnumeric);
    p.addOptional('waitSecsToReceivePacket', Inf, @isnumeric);
    p.addOptional('pauseTimeSecsInLazyWaitForMessage', 0, @isnumeric);
    parse(p,msgLabel,varargin{:});

    timeOutSecs = p.Results.timeOutSecs;
    pauseTimeSecsInLazyWaitForMessage = p.Results.pauseTimeSecsInLazyWaitForMessage;
    waitSecsToReceivePacket = p.Results.waitSecsToReceivePacket;
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

    % Read the leading packet label
    timeOutMessage = sprintf('while lazy waiting for message ''%s'' to arrive', expectedMessageLabel);
    packet.timedOutFlag = obj.waitForMessageOrTimeout(waitSecsToReceivePacket, pauseTimeSecsInLazyWaitForMessage,  timeOutMessage);
    if (packet.timedOutFlag); return; end
    
    packet.messageLabel = matlabNUDP('receive', udpHandle);
    if (~strcmp(packet.messageLabel, expectedMessageLabel))
        messageToPrint = sprintf('Leading message label (''%s'') does not match expected message label (''%s'')', packet.messageLabel, expectedMessageLabel);
        packet = informSender_ReceivedMessageLabelNotMatchingExpected(obj, udpHandle, packet, expectedMessageLabel, messageToPrint);
        return;
    end

    subsequentPauseTimeSecsInLazyWaitForMessage = 0;
    subsequentTimeouts = false;
    %subsequentPauseTimeSecsInLazyWaitForMessage = pauseTimeSecsInLazyWaitForMessage;
    
    
    % Read the number of bytes
    if (subsequentTimeouts)
        timeOutMessage = sprintf('while waiting to receive number of bytes for message ''%s''', expectedMessageLabel);
        packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, subsequentPauseTimeSecsInLazyWaitForMessage, timeOutMessage);
        if (packet.timedOutFlag); return; end
    end
    
    bytesString = matlabNUDP('receive', udpHandle);
    numBytes = str2double(bytesString);

    if (isnan(numBytes) || isinf(numBytes))
       % Bad # of bytes - return
       messageToPrint = sprintf('Bad number of bytes received for message ''%s''.\n', expectedMessageLabel);
       packet = informSender_BadTransmission(obj, udpHandle, packet, expectedMessageLabel, messageToPrint);
       return;
    end
    
    if (strcmp((obj.transmissionMode), 'SINGLE_BYTES'))
        % Read  bytes
        pauseSecs = 0;
        theData = zeros(1,numBytes);
        for k = 1:numBytes
            if (subsequentTimeouts)
                timeOutMessage = sprintf('while waiting to receive byte %d/%d of message ''%s''', k, numBytes, expectedMessageLabel);
                packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, subsequentPauseTimeSecsInLazyWaitForMessage, timeOutMessage);
                if (packet.timedOutFlag); return; end
            end
            datum = matlabNUDP('receive', udpHandle);
            theData(k) = str2double(datum);
        end
    else
        % Read number of words
        if (subsequentTimeouts)
            timeOutMessage = sprintf('while waiting to receive number of words for message ''%s''', expectedMessageLabel);
            packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, subsequentPauseTimeSecsInLazyWaitForMessage, timeOutMessage);
            if (packet.timedOutFlag); return; end
        end
        wordsNum = str2double(matlabNUDP('receive', udpHandle));
        
        if (isnan(wordsNum) || isinf(wordsNum))
            % Bad # of words - return
            messageToPrint = sprintf('Bad number of words received for message ''%s''.\n', expectedMessageLabel);
            packet = informSender_BadTransmission(obj, udpHandle, packet, expectedMessageLabel, messageToPrint);
            return;
        end
        
        allWords = char(ones(wordsNum, 3*obj.WORD_LENGTH, 'uint8'));
        % Read each word
        for wordIndex = 1:wordsNum
            if (subsequentTimeouts)
                timeOutMessage = sprintf('while waiting to receive word %d/%d of message ''%s''', wordIndex, wordsNum, expectedMessageLabel);
                packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, subsequentPauseTimeSecsInLazyWaitForMessage, timeOutMessage);
                if (packet.timedOutFlag); return; end
            end
            
            datum = matlabNUDP('receive', udpHandle);
            allWords(wordIndex,1:numel(datum)) = datum;
        end
    end

    % Read the message label again
    if (subsequentTimeouts)
        timeOutMessage = sprintf('while waiting to verify the label of message ''%s''', expectedMessageLabel);
        packet.timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, subsequentPauseTimeSecsInLazyWaitForMessage, timeOutMessage);
        if (packet.timedOutFlag); return; end
    end
    
    trailingMessageLabel = matlabNUDP('receive', udpHandle);
    if (~strcmp(packet.messageLabel,trailingMessageLabel))
       % Now we definitely have a bad transmission so set this flag
       messageToPrint = sprintf('Trailing message label mismatch: expected ''%s'', received: ''%s''.\n', expectedMessageLabel, trailingMessageLabel);
       packet = informSender_BadTransmission(obj, udpHandle, packet, expectedMessageLabel, messageToPrint);
       return;
    end

    % Concatenate all words into a single byte stream
    if (strcmp((obj.transmissionMode), 'WORDS'))
        theData = zeros(1,numBytes);
        wordIndex = 0;
        for k = 1:numBytes
            if (mod(k-1, obj.WORD_LENGTH) == 0)
                wordIndex = wordIndex + 1;
                charIndex = 0;
            end
            theData(k) = str2double(allWords(wordIndex,charIndex*3+(1:3)));
            charIndex = charIndex + 1;
        end
    end
    
    % Reconstruct data object
    if (numBytes > 0)
        try
            packet.messageData = getArrayFromByteStream(uint8(theData));
        catch err
            % Inform sender
            messageToPrint = sprintf('Could not decode a matlab data type from the transmitted byte stream (error: %s) for message with label: ''%s''.\n', err.message,expectedMessageLabel);
            packet = informSender_BadTransmission(obj, udpHandle, packet, expectedMessageLabel, messageToPrint);
            return;
        end
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
