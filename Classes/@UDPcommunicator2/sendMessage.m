function transmissionStatus = sendMessage(obj, msgLabel, msgData, varargin)
    p = inputParser;
    
    % the msgLabel is required
    addRequired(p,'msgLabel',@ischar);
    
    % the msgData is required
    addRequired(p, 'msgData');
    
    % the timeOutSecs is optional, with a default value: 5
    addOptional(p,'timeOutSecs', 5, @isnumeric);
    addOptional(p,'maxAttemptsNum',1, @isnumeric);
    
    % parse the input
    parse(p, msgLabel, msgData, varargin{:});

    messageLabel = p.Results.msgLabel;
    messageData  = p.Results.msgData;
    acknowledgmentTimeOutSecs  = p.Results.timeOutSecs;
    
    fprintf('Sending %s\n', messageLabel);
    % Send the leading message label
    matlabUDP('send', messageLabel);
    
    % Serialize data
    messageData
    byteStream = getByteStreamFromArray(messageData);
     
    % Send number of bytes to read
    fprintf('Sending %d bytes\n', numel(byteStream));
    matlabUDP('send', sprintf('05d%', numel(byteStream)));
        
    % Send each byte separately
    for k = 1:numel(byteStream)
       matlabUDP('send',sprintf('%03d', byteStream(k)))
    end
    
    % Send the trailing message label
    matlabUDP('send', messageLabel);
       
    % Wait for acknowledgment that the message was received OK
    timedOutFlag = false;
    tic;
    while (~matlabUDP('check')) && (~timedOutFlag)
        elapsedTime = toc;
        if (elapsedTime > acknowledgmentTimeOutSecs)
            timedOutFlag = true;
        end
    end
    if (timedOutFlag == false)
        acknowledgmentReceived = matlabUDP('receive');
        if (strcmp(acknowledgmentReceived, obj.ACKNOWLEDGMENT))
            transmissionStatus = obj.GOOD_TRANSMISSION;
        else
            transmissionStatus = obj.BAD_ACKNOWLDGMENT;
        end
    else
        transmissionStatus = obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD;
    end
    
end

function status = sendMessageOriginal(obj, msgLabel, msgValue, varargin)

    p = inputParser;
    
    % the msgLabel is required
    addRequired(p,'msgLabel',@ischar);
    
    % the withValue is required
    addRequired(p, 'msgValue');
    
    % the timeOutSecs is optional, with a default value: 5
    defaultTimeOutSecs = 5;
    addOptional(p,'timeOutSecs',defaultTimeOutSecs,@isnumeric);
    
    % The calling function name is optional
    defaultCallingFunctionName = ' ';
    addOptional(p,'callingFunctionName',defaultCallingFunctionName,@ischar);
    
    
    % the maxAttemptsNum is optional, with a default value: 1
    defaultMaxAttemptsNum = 1;
    addOptional(p,'maxAttemptsNum',defaultMaxAttemptsNum,@isnumeric);
    
    % the doNotReplyToThisMessage is optional, with a default value false
    defaultDoNotReplyToThisMessage = false;
    addOptional(p,'doNotReplyToThisMessage',defaultDoNotReplyToThisMessage,@islogical);
    
    % Whether to deal with errors here or propagate the error message to the caller
    addOptional(p,'dealWithErrors', true, @islogical);
    
    % parse the input
    parse(p, msgLabel, msgValue, varargin{:});

    messageLabel    = p.Results.msgLabel;
    messageArgument = p.Results.msgValue;
    timeOutSecs     = p.Results.timeOutSecs;
    maxAttemptsNum  = p.Results.maxAttemptsNum;
    doNotReplyToThisMessage = p.Results.doNotReplyToThisMessage;
    callingFunctionName = p.Results.callingFunctionName;
    dealWithErrors  = p.Results.dealWithErrors;
    
    if (strcmp(callingFunctionName, ' '))
        callingFunctionSignature = '';
    else
        callingFunctionSignature = sprintf('[called from <strong>%s</strong>]:', callingFunctionName);
    end
    
    % ensure timeOutSecs is greater than 0
    if (timeOutSecs < 0)
        timeOutSecs = 0/1000.0;
        if (~strcmp(obj.verbosity,'min'))  && (~strcmp(obj.verbosity,'none'))
            fprintf('%s %s forcing negative or zero timeOutSecs to %2.4f milli-seconds\n', obj.sendMessageSignature, callingFunctionSignature, timeOutSecs*1000);
        end
    end
    
    % form compound command
    if (isempty(messageArgument))
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'STRING', '');
        
    elseif (ischar(messageArgument))
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'STRING', messageArgument);
        
    elseif (isnumeric(messageArgument))
        if (numel(messageArgument) > 1)
            fprintf('%s %s >>>> message argument contains more than 1 element. Will only send the 1st element.', obj.sendMessageSignature, callingFunctionSignature);
        end
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'NUMERIC', sprintf('%f', messageArgument(1)));
        
    elseif (islogical(messageArgument))
        if (numel(messageArgument) > 1)
            fprintf('%s %s >>>>> message argument contains more than 1 element. Will only send the 1st element.', obj.sendMessageSignature, callingFunctionSignature);
        end
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'BOOLEAN', sprintf('%d', messageArgument(1)));
    else
        class(messageArgument)
        error('%s %s Do not know how to process this type or argument.', obj.sendMessageSignature, callingFunctionSignature);
    end
    
    if (strcmp(obj.verbosity,'max'))
        if (doNotReplyToThisMessage)
            fprintf('%s %s Will send ''%s'' and return.', obj.sendMessageSignature, callingFunctionSignature, commandString);
        else
            % give some feedback
            if isinf(timeOutSecs)
                fprintf('%s %s Will send ''%s'' and wait for ever to receive an acknowledgment', obj.sendMessageSignature, callingFunctionSignature, commandString);
            else
                fprintf('%s %s Will send ''%s'' and wait for %2.2f seconds to receive an acknowledgment', obj.sendMessageSignature, callingFunctionSignature, commandString, timeOutSecs);
            end
        end
    end
    
    % send the message and increment sentMessagesCount
    transmitAndUpdateCounter(obj, commandString);
    
    % If the doToNotreplyToThisMessage is set, return at this point
    if (doNotReplyToThisMessage)
        status = '';
        return;
    end
    
    
    attemptNo = 0;
    status = 'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT';
    
    while ((attemptNo < maxAttemptsNum) && (strcmp(status,'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT')))
        attemptNo = attemptNo + 1;
        
        % wait for timeOutSecs to receive an acknowledgment that the sent
        % message has the same label as the expected (on the remote computer) message
        if (isempty(callingFunctionName))
            response = obj.waitForMessage(obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED, 'timeOutSecs', timeOutSecs);
        else
            response = obj.waitForMessage(obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED, 'timeOutSecs', timeOutSecs, 'callingFunctionName', callingFunctionName);
        end
        
        if (response.timedOutFlag)
            % update timeouts counter
            obj.timeOutsCount = obj.timeOutsCount + 1;

            status = 'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT';
            if (attemptNo == maxAttemptsNum)
                fprintf(2,'%s %s Timed out after %d seconds waiting to receive receipt acknowledgment for transmitted message: ''%s''. Attempt: %d/%d\n', obj.sendMessageSignature, callingFunctionSignature, timeOutSecs, commandString, attemptNo, maxAttemptsNum); 
            else
                fprintf(2,'%s %s Timed out after %d seconds waiting to receive receipt acknowledgment for transmitted message: ''%s''. Attempt: %d/%d. Resending the same message now.\n', obj.sendMessageSignature, callingFunctionSignature, timeOutSecs, commandString, attemptNo, maxAttemptsNum); 
                % resend the message
                transmitAndUpdateCounter(obj, commandString);
            end
        else
            if strcmp(response.msgLabel, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED)
                status = obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED;
            else
                status = response.msgLabel;
            end
        end
    end % while attemptNo < maxAttemptsNum
    
    if (dealWithErrors)
        % Make sure the remote host received the expected label
        assert(strcmp(status,'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE'), sprintf('\nRemote host reports a communication failure: %s', status));
        % Make sure we did not hit the ACK timeOut limit, otherwise throw an error
        assert(~strcmp(status,'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT'), '\nRemote host did not send an acknowledgment within the timeout period.');
    end
    
    function transmitAndUpdateCounter(obj, commandString)
        if (obj.useNativeUDP)
            fwrite(obj.udpClient, commandString);
        else
            matlabUDP('send', commandString);
        end
        obj.sentMessagesCount = obj.sentMessagesCount + 1;
    end

end
