function response = waitForMessage(obj, msgLabel, varargin)

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
        error('UDPcommunicator: waitForMessage. The expected message label must be a string, or an empty array, i.e.: []\n');
    end
    timeOutSecs = p.Results.timeOutSecs;

    % initialize response struct
    response = struct(...
        'msgLabel', '', ...
        'msgValue', [], ...
        'timedOutFlag', false ...
    );

    % give some feedback
    if isinf(timeOutSecs)
        fprintf('\nWaiting for ever to receive a ''%s'' message.', expectedMessageLabel);
    else
        fprintf('\nWaiting for %2.2f seconds to receive a ''%s'' message.', timeOutSecs, expectedMessageLabel);
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
        % see what we received
        rawMessage = matlabUDP('receive');
        fprintf('Raw message received: ''%s'' after %2.2f seconds. Expected message label: ''%s''\n', rawMessage, elapsedTime, expectedMessageLabel);
        % parse the raw message received
        response.msgLabel = 'lala';
        response.msgValue = 123;
        
        % check if the message label we received is the same as the one we
        % are expecting, and inform the sender
        if (strcmp(response.msgLabel, 'expectedMessageLabel'))
            obj.sendMessage('ACK', '', 'timeOutSecs', -1);
        else
            obj.sendMessage(sprintf('RECEIVED_MESSAGE_(''%s'')_DID_NOT_MATCH_EXPECTED_MESSAGE_(''%s'')', response.msgLabel, expectedMessageLabel), 'timeOutSecs', -1);
        end
    end
    
    
end

