function transmissionStatus = sendMessage(obj, msgLabel, msgData, varargin)
    p = inputParser;
    p.addRequired('msgLabel',@ischar);
    p.addRequired('msgData');
    p.addOptional('timeOutSecs', 5, @isnumeric);
    parse(p,  msgLabel, msgData, varargin{:});

    messageLabel = p.Results.msgLabel;
    messageData  = p.Results.msgData;
    timeOutSecs  = p.Results.timeOutSecs;
    udpHandle    = obj.udpHandle;

    % Send the leading message label
    matlabNUDP('send', udpHandle, messageLabel);

    % Serialize data
    byteStream = getByteStreamFromArray(messageData);

    % Send number of bytes to read
    matlabNUDP('send', udpHandle, sprintf('%d', numel(byteStream)));
    
    if (strcmp((obj.transmissionMode), 'SINGLE_BYTES'))
        % Send each byte separately
        for k = 1:numel(byteStream)
           matlabNUDP('send', udpHandle, sprintf('%03d', byteStream(k)));
        end
    else
        wordsNum = numel(byteStream)/obj.WORD_LENGTH;
        if (wordsNum > floor(wordsNum))
            wordsNum = 1+floor(wordsNum);
        end
        wordIndex = 0;
        allWords = char(ones(wordsNum, 3*obj.WORD_LENGTH, 'uint8'));
        for k = 1:numel(byteStream)
            if (mod(k-1, obj.WORD_LENGTH) == 0)
                wordIndex = wordIndex + 1;
                charIndex = 0;
            end
            allWords(wordIndex,charIndex*3+(1:3)) = sprintf('%03d', byteStream(k));
            charIndex = charIndex + 1;
        end
        % Send number of words
        matlabNUDP('send', udpHandle, sprintf('%d', wordsNum));
        % Send each word
        for wordIndex = 1:wordsNum
            datum = squeeze(allWords(wordIndex,:));
            size(datum)
            matlabNUDP('send', udpHandle, datum);
        end
    end
    
    % Send the trailing message label
    matlabNUDP('send', udpHandle, messageLabel);

    % Wait for acknowledgment that the message was received OK
    pauseTimeSecs = 0;
    timeOutMessage = sprintf('while waiting to receive acknowledgment for messageLabel: ''%s''', messageLabel);
    obj.waitForMessageOrTimeout(timeOutSecs, pauseTimeSecs, timeOutMessage);
    transmissionStatus = matlabNUDP('receive', udpHandle);
end
