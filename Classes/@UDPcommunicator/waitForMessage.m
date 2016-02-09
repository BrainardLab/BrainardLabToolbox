function response = waitForMessage(obj, msgLabel, varargin)
    
    signature = obj.waitForMessageSignature;
    
    p = inputParser;
    % the msgLabel is required, but we can pass an empty string
    addRequired(p,'msgLabel');
    
    % the timeOutSecs is optional, with a default value: Inf
    defaultTimeOutSecs = Inf;
    addOptional(p,'timeOutSecs',defaultTimeOutSecs,@isnumeric);
   
    % parse the input
    parse(p,msgLabel,varargin{:});
    expectedMessageLabel = p.Results.msgLabel;
    if isempty(expectedMessageLabel)
        expectedMessageLabel = '';
    end
    if (~ischar(expectedMessageLabel))
        error('%s The expected message label must be a string, or an empty array, i.e.: []\n',signature);
    end
    timeOutSecs = p.Results.timeOutSecs;

    % initialize response struct
    response = struct(...
        'msgLabel', '', ...
        'msgValue', [], ...
        'timedOutFlag', false ...
    );

    if (~strcmp(obj.verbosity,'min'))
        % give some feedback
        if isinf(timeOutSecs)
            fprintf('%s Waiting for ever to receive a ''%s'' message .... ', signature, expectedMessageLabel);
        else
            fprintf('%s Waiting for %2.2f seconds to receive a ''%s'' message ... ', signature, timeOutSecs, expectedMessageLabel);
        end
    end
    
    tic;
    data = 0;
    while ((data==0) && (response.timedOutFlag == false))
        data = matlabUDP('check');
        elapsedTime = toc;
        if (elapsedTime > timeOutSecs)
            response.timedOutFlag = true;
        end
    end % while
    
    if (response.timedOutFlag == false)
        % get raw data
        rawMessage = receiveAndUpdateCounter();
        
        % parse the raw message received
        leftBracketPositions = strfind(rawMessage, sprintf('['));
        rightBracketPositions = strfind(rawMessage, sprintf(']'));
        if ((numel(leftBracketPositions) ~= 3) || (numel(rightBracketPositions) ~= 3))
            error('%s Raw message received (%s) does not contain correct format. Incorrect number of brackets\n', signature, rawMessage);
        end
        
        response.msgLabel = rawMessage(leftBracketPositions(1)+1:rightBracketPositions(1)-1);
        response.msgValueType = rawMessage(leftBracketPositions(2)+1:rightBracketPositions(2)-1);
        if (strcmp(lower(response.msgValueType), 'numeric'))
            response.msgValue = str2double(rawMessage(leftBracketPositions(3)+1:rightBracketPositions(3)-1));
        elseif (strcmp(lower(response.msgValueType), 'boolean'))
            response.msgValue = str2double(rawMessage(leftBracketPositions(3)+1:rightBracketPositions(3)-1));
            if (response.msgValue == 0)
                response.msgValue = false;
            else
                response.msgValue = true;
            end
        elseif (strcmp(lower(response.msgValueType), 'string'))
            response.msgValue = rawMessage(leftBracketPositions(3)+1:rightBracketPositions(3)-1);
        else
            if (strcmp(response.msgLabel, 'ACK'))
                % 'ACK' message has not value or value type
            else
                error('Do not know how to handle message value type: ''%s''\n', response.msgValueType);
            end
        end
        % check if the message label we received is the same as the one we are expecting, and inform the sender
        if (strcmp(response.msgLabel, expectedMessageLabel))
            if (~strcmp(obj.verbosity,'min'))
                fprintf('Expected message received withing %2.2f seconds, acknowledging the sender.', elapsedTime);
            end
            % Do not send back an ACK if we were expecting an ACK and we received it
            if (~strcmp(expectedMessageLabel, 'ACK'))
                obj.sendMessage('ACK', 'timeOutSecs', -1);
            end
        else
            fprintf('%s Received unexpected message: ''%s'' (instead of ''%s''). Informing the sender.', signature, response.msgLabel, expectedMessageLabel);
            obj.sendMessage(sprintf('RECEIVED_MESSAGE_(''%s'')_DID_NOT_MATCH_EXPECTED_MESSAGE_(''%s'')', response.msgLabel, expectedMessageLabel), 'timeOutSecs', -1);
        end
    end
    
    function rawMessage = receiveAndUpdateCounter()
        rawMessage = matlabUDP('receive');
        obj.receivedMessagesCount = obj.receivedMessagesCount + 1;
    end
end

