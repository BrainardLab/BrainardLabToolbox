function status = sendMessage(obj, msgLabel, msgArgument, varargin)

    p = inputParser;
    % the msgLabel is required
    addRequired(p,'msgLabel',@ischar);
    % the msgArgument is required
    addRequired(p,'msgArgument');
    
    % the timeOutSecs is optional, with a default value: Inf
    defaultTimeOutSecs = Inf;
    addOptional(p,'timeOutSecs',defaultTimeOutSecs,@isnumeric);
    
    % the maxAttemptsNum is optional, with a default value: 1
    defaultMaxAttemptsNum = 1;
    addOptional(p,'maxAttemptsNum',defaultMaxAttemptsNum,@isnumeric);
    
    % parse the input
    parse(p,msgLabel,msgArgument,varargin{:});
    messageLabel    = p.Results.msgLabel;
    messageArgument = p.Results.msgArgument;
    timeOutSecs     = p.Results.timeOutSecs;
    attemptsNum     = p.Results.maxAttemptsNum;
    
    % form compound command
    if (ischar(messageArgument))
        commandString = sprintf('[%s][%s]', messageLabel, messageArgument);
    elseif (isnumeric(messageArgument))
        if (numel(messageArgument) > 1)
            fprintf('%s message argument contains more than 1 element. Will only send the 1st element.', obj.sendrMessageSignature);
        end
        commandString = sprintf('[%s][%f]', messageLabel, messageArgument(1));
    elseif (islogical(messageArgument))
        if (numel(messageArgument) > 1)
            fprintf('%s message argument contains more than 1 element. Will only send the 1st element.', obj.sendrMessageSignature);
        end
        commandString = sprintf('[%s][%d]', messageLabel, messageArgument(1));
    else
        class(messageArgument)
        error('%s Do not know how to process this type or argument.', obj.sendrMessageSignature);
    end
    
    % give some feedback
    if isinf(timeOutSecs)
        fprintf('%s Will send ''%s'' and wait for ever to receive an acknowledgment', obj.sendrMessageSignature, commandString);
    else
        fprintf('%sWill send''%s'' and wait for %2.2f seconds to receive an acknowledgment', obj.sendrMessageSignature, commandString, timeOutSecs);
    end
    
    % send the message
    matlabUDP('send', commandString);
    
    if (timeOutSecs > 0)
        % wait for timeOutSecs to receive an acknowledgment that the sent
        % message has the same label as the expected (on the remote computer) message
        response = obj.waitForMessage('', timeOutSecs);
        if (response.timedOutFlag)
             fprintf('%s Timed out waiting for an acknowledgment after sending message: ''%s''\n', obj.sendrMessageSignature, commandString); 
             status = 'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT';
        else
            if strcmp(response.msgLabel, 'ACK')
                status = 'MESSAGE_SENT_MATCHED_EXPECTED_MESSAGE';
            else
                status = response.msgLabel;
            end
        end
    end
    
    
end
