function status = sendMessage(obj, msgLabel, varargin)

    p = inputParser;
    % the msgLabel is required
    addRequired(p,'msgLabel',@ischar);
    
    % the withValue optional parameter, with a default being the empty
    addOptional(p, 'withValue', []);
    
    % the timeOutSecs is optional, with a default value: Inf
    defaultTimeOutSecs = Inf;
    addOptional(p,'timeOutSecs',defaultTimeOutSecs,@isnumeric);
    
    % the maxAttemptsNum is optional, with a default value: 1
    defaultMaxAttemptsNum = 1;
    addOptional(p,'maxAttemptsNum',defaultMaxAttemptsNum,@isnumeric);
    
    % parse the input
    parse(p,msgLabel,varargin{:});
    messageLabel    = p.Results.msgLabel;
    messageArgument = p.Results.withValue;
    timeOutSecs     = p.Results.timeOutSecs;
    maxAttemptsNum  = p.Results.maxAttemptsNum;
    
    % form compound command
    if (isempty(messageArgument))
        commandString = sprintf('[%s][][]', messageLabel);
        
    elseif (ischar(messageArgument))
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'STRING', messageArgument);
        
    elseif (isnumeric(messageArgument))
        if (numel(messageArgument) > 1)
            fprintf('%s message argument contains more than 1 element. Will only send the 1st element.', obj.sendMessageSignature);
        end
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'NUMERIC', sprintf('%f', messageArgument(1)));
        
    elseif (islogical(messageArgument))
        if (numel(messageArgument) > 1)
            fprintf('%s message argument contains more than 1 element. Will only send the 1st element.', obj.sendMessageSignature);
        end
        commandString = sprintf('[%s][%s][%s]', messageLabel, 'BOOLEAN', sprintf('%d', messageArgument(1)));
    else
        class(messageArgument)
        error('%s Do not know how to process this type or argument.', obj.sendMessageSignature);
    end
    
    if (~strcmp(obj.verbosity,'min'))
        % give some feedback
        if isinf(timeOutSecs)
            fprintf('%s Will send ''%s'' and wait for ever to receive an acknowledgment', obj.sendMessageSignature, commandString);
        elseif (timeOutSecs <= 0)
            fprintf('%s Will send ''%s'' and return', obj.sendMessageSignature, commandString);
        else
            fprintf('%s Will send ''%s'' and wait for %2.2f seconds to receive an acknowledgment', obj.sendMessageSignature, commandString, timeOutSecs);
        end
    end
    
    % send the message
    matlabUDP('send', commandString);
    
    attemptNo = 0;
    status = 'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT';
    
    while ((attemptNo < maxAttemptsNum) && (strcmp(status,'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT')))
        attemptNo = attemptNo + 1;
        
        if (timeOutSecs > 0)
            % wait for timeOutSecs to receive an acknowledgment that the sent
            % message has the same label as the expected (on the remote computer) message
            response = obj.waitForMessage('ACK', timeOutSecs);

            if (response.timedOutFlag)
                status = 'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT';
                if (attemptNo == maxAttemptsNum)
                    fprintf(2,'%s Timed out after %d seconds waiting to receive receipt acknowledgment for transmitted message: ''%s''. Attempt: %d/%d\n', obj.sendMessageSignature, timeOutSecs, commandString, attemptNo, maxAttemptsNum); 
                else
                    fprintf(2,'%s Timed out after %d seconds waiting to receive receipt acknowledgment for transmitted message: ''%s''. Attempt: %d/%d. Resending the same message now.\n', obj.sendMessageSignature, timeOutSecs, commandString, attemptNo, maxAttemptsNum); 
                    % send the message
                    matlabUDP('send', commandString);
                end
            else
                if strcmp(response.msgLabel, 'ACK')
                    status = 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE';
                else
                    status = response.msgLabel;
                end
            end
        end
        
        
    end % while attemptNo < maxAttemptsNum
    
end
