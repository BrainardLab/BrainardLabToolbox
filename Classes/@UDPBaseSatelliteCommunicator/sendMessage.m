% Method that sends a message either as single bytes or as words. At the end of the transmission
% we wait up to timeOutSecs to receive an acknowledgment. If we do not, the
% waitForMessageOrTimeout() method throws an exception.

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
    
    % Serialize data
    byteStream = getByteStreamFromArray(messageData);

    if (strcmp((obj.transmissionMode), 'WORDS'))
        [allWords, wordsNum, lastWordLength] = wordStreamFromByteStream(byteStream, obj.WORD_LENGTH);
    end
    
    % Send the leading message label
    matlabNUDP('send', udpHandle, messageLabel);
    
    % Send number of bytes to read
    matlabNUDP('send', udpHandle, sprintf('%d', numel(byteStream)));
    
    if (strcmp((obj.transmissionMode), 'SINGLE_BYTES'))
        % Send each byte separately
        for k = 1:numel(byteStream)
           matlabNUDP('send', udpHandle, sprintf('%03d', byteStream(k)));
        end
    else
        % Send number of words
        matlabNUDP('send', udpHandle, sprintf('%d', wordsNum));
        % Send each word
        for wordIndex = 1:wordsNum
            if (wordIndex == wordsNum)
                datum = squeeze(allWords(wordIndex,1:lastWordLength));
            else
                datum = squeeze(allWords(wordIndex,:));
            end
            matlabNUDP('send', udpHandle, datum);
        end
    end
    
    % Send the trailing message label
    matlabNUDP('send', udpHandle, messageLabel);

    
    % Wait for acknowledgment that the message was received OK
    timedOutFlag = true;
    attemptNo = 0;
    pauseTimeSecs = 0;
    maxAttemptsToReadACK = 10;
    while (timedOutFlag) && (attemptNo < maxAttemptsToReadACK)
        attemptNo = attemptNo + 1;
        timeOutMessage = sprintf('while waiting to receive acknowledgment for messageLabel: ''%s'' (attempt no: %d/%d)', messageLabel, attemptNo, maxAttemptsToReadACK);
        timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs, pauseTimeSecs, timeOutMessage);
        if (~timedOutFlag)
            transmissionStatus = matlabNUDP('receive', udpHandle);
        else 
            transmissionStatus = obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD;
        end
    end
end


function [allWords, wordsNum, lastWordLength] = wordStreamFromByteStream(byteStream, wordLength)
    wordsNum = numel(byteStream)/wordLength;
    if (wordsNum > floor(wordsNum))
        wordsNum = 1+floor(wordsNum);
    end
    wordIndex = 0;
    allWords = char(ones(wordsNum, 3*wordLength, 'uint8'));
    lastWordLength = 0;
    for k = 1:numel(byteStream)
        if (mod(k-1, wordLength) == 0)
            wordIndex = wordIndex + 1;
            charIndex = 0;
        end
        allWords(wordIndex,charIndex*3+(1:3)) = sprintf('%03d', byteStream(k));
        if (k == numel(byteStream))
            lastWordLength = charIndex*3+3;
        end
        charIndex = charIndex + 1;
    end
end
