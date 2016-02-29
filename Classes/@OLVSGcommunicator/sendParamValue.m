% Method to send a parameter value
% ex.: OLVSG.sendParamValue(OLVSG.protocolName, {OLVSG.protocolName, 'something'});
% or   OLVSG.sendParamValue(OLVSG.protocolName, {OLVSG.protocolName, 'something'}, params.protocolName, timeOutSecs, 2.0, 'maxAttemptsNum', 3);
% or   OLVSG.sendParamValue(OLVSG.protocolName, {OLVSG.go});

function sendParamValue(obj, paramNameAndValue, varargin)
    
    if (~ischar(paramName))
        error('Input to receiveParamValue must be a string corresponding to the parameter name.');
    end
    
    % unwrap message
    if (numel(paramNameAndValue) == 1)
        messageLabel = paramNameAndValue{1};
        messageValue = [];
    else
        messageLabel = paramNameAndValue{1};
        messageValue = paramNameAndValue{2};
    end
    
    % parse input
    defaultTimeOutSecs = 2;
    defaultMaxAttemptsNum = 3;
    p = inputParser;
    p.addParamValue('timeOutSecs', defaultTimeOutSecs,   @isnumeric);
    p.addParamValue('maxAttemptsNum', defaultMaxAttemptsNum, @isnumeric);
    p.parse(varargin{:});
    
    % Send the message
    if (isempty(messageValue))
        status = obj.sendMessage(messageLabel, p.Results.timeOutSecs, 'maxAttemptsNum', p.Results.maxAttemptsNum);
    else
        status = obj.sendMessage(messageLabel, 'withValue', messageValue, 'timeOutSecs', p.Results.timeOutSecs, 'maxAttemptsNum', p.Results.maxAttemptsNum);
    end
    
    % Get this backtrace of all functions leading to this point
    dbs = dbstack;
    backTrace = ''; depth = length(dbs);
    while (depth >= 1)
        backTrace = sprintf('%s-> %s ', backTrace, dbs(depth).name);
        depth = depth - 1;
    end
    
    % Check status to ensure we received a 'TRANSMITTED_MESSAGE_MATCHES_EXPECTED' message
    assert(strcmp(status, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED), sprintf('%s: Exiting due to mismatch in message labels.\nExpected label: ''%s'', Received label: ''%s''.\n', backTrace, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED, status));
end
