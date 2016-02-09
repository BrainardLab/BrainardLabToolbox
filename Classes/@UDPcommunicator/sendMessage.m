function status = sendMessage(obj, msgLabel, varargin)

    p = inputParser;
    % the msgLabel is required
    addRequired(p,'msgLabel',@ischar);
    
    % the withValue optional parameter, with a default being the empty string
    addOptional(p, 'withValue', ' ');
    
    % the timeOutSecs is optional, with a default value: 5
    defaultTimeOutSecs = 5;
    addOptional(p,'timeOutSecs',defaultTimeOutSecs,@isnumeric);
    
    % the maxAttemptsNum is optional, with a default value: 1
    defaultMaxAttemptsNum = 1;
    addOptional(p,'maxAttemptsNum',defaultMaxAttemptsNum,@isnumeric);
    
    % the doNotReplyToThisMessage is optional, with a default value false
    defaultDoNotReplyToThisMessage = false;
    addOptional(p,'doNotReplyToThisMessage',defaultDoNotReplyToThisMessage,@islogical);
    
    % parse the input
    parse(p,msgLabel,varargin{:});
    messageLabel    = p.Results.msgLabel;
    messageArgument = p.Results.withValue;
    timeOutSecs     = p.Results.timeOutSecs;
    maxAttemptsNum  = p.Results.maxAttemptsNum;
    doNotReplyToThisMessage = p.Results.doNotReplyToThisMessage;
    
    % ensure timeOutSecs is greater than 0
    if (timeOutSecs <= 0)
        timeOutSecs = 0.01;
        if (~strcmp(obj.verbosity,'min'))
            fprintf('%$ forcing negative or zero timeOutSecs to %2.4f seconds\n', obj.sendMessageSignature, timeOutSecs);
        end
    end
    
    % form compound command
    if (isempty(messageArgument))
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'STRING', '');
        
    elseif (ischar(messageArgument))
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'STRING', messageArgument);
        
    elseif (isnumeric(messageArgument))
        if (numel(messageArgument) > 1)
            fprintf('%s >>>> message argument contains more than 1 element. Will only send the 1st element.', obj.sendMessageSignature);
        end
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'NUMERIC', sprintf('%f', messageArgument(1)));
        
    elseif (islogical(messageArgument))
        if (numel(messageArgument) > 1)
            fprintf('%s >>>>> message argument contains more than 1 element. Will only send the 1st element.', obj.sendMessageSignature);
        end
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'BOOLEAN', sprintf('%d', messageArgument(1)));
    else
        class(messageArgument)
        error('%s Do not know how to process this type or argument.', obj.sendMessageSignature);
    end
    
    if (~strcmp(obj.verbosity,'min'))
        if (doNotReplyToThisMessage)
            fprintf('%s Will send ''%s'' and return.', obj.sendMessageSignature, commandString);
        else
            % give some feedback
            if isinf(timeOutSecs)
                fprintf('%s Will send ''%s'' and wait for ever to receive an acknowledgment', obj.sendMessageSignature, commandString);
            else
                fprintf('%s Will send ''%s'' and wait for %2.2f seconds to receive an acknowledgment', obj.sendMessageSignature, commandString, timeOutSecs);
            end
        end
    end
    
    % send the message and increment sentMessagesCount
    transmitAndUpdateCounter(commandString);
    
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
        response = obj.waitForMessage(obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED, timeOutSecs);

        if (response.timedOutFlag)
            % update timeouts counter
            obj.timeOutsCount = obj.timeOutsCount + 1;

            status = 'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT';
            if (attemptNo == maxAttemptsNum)
                fprintf(2,'%s Timed out after %d seconds waiting to receive receipt acknowledgment for transmitted message: ''%s''. Attempt: %d/%d\n', obj.sendMessageSignature, timeOutSecs, commandString, attemptNo, maxAttemptsNum); 
            else
                fprintf(2,'%s Timed out after %d seconds waiting to receive receipt acknowledgment for transmitted message: ''%s''. Attempt: %d/%d. Resending the same message now.\n', obj.sendMessageSignature, timeOutSecs, commandString, attemptNo, maxAttemptsNum); 
                % resend the message
                transmitAndUpdateCounter(commandString);
            end
        else
            if strcmp(response.msgLabel, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED)
                status = obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED;
            else
                status = response.msgLabel;
            end
        end
    end % while attemptNo < maxAttemptsNum
    
    function transmitAndUpdateCounter(commandString)
        matlabUDP('send', commandString);
        obj.sentMessagesCount = obj.sentMessagesCount + 1;
    end

end
