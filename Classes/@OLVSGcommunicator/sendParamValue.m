% Method to send a parameter value
% ex.: OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something');
% or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something', params.protocolName, timeOutSecs, 2.0, 'maxAttemptsNum', 3);
% or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.go, []);

function sendParamValue(obj, paramName, paramValue, varargin)
    
    % parse input
    defaultTimeOutSecs = 2;
    defaultMaxAttemptsNum = 3;
    p = inputParser;
    p.addRequired('obj');
    p.addRequired('paramName', @ischar);
    p.addRequired('paramValue');
    p.addParamValue('timeOutSecs', defaultTimeOutSecs,   @isnumeric);
    p.addParamValue('maxAttemptsNum', defaultMaxAttemptsNum, @isnumeric);
    p.parse(obj, paramName, paramValue, varargin{:});
    
    
    % Send the message
    messageValue = p.Results.paramValue;
    messageLabel = p.Results.paramName;
    if (isempty(messageValue))
        status = p.Results.obj.sendMessage(messageLabel, p.Results.timeOutSecs, 'maxAttemptsNum', p.Results.maxAttemptsNum);
    else
        status = p.Results.obj.sendMessage(messageLabel, 'withValue', messageValue, 'timeOutSecs', p.Results.timeOutSecs, 'maxAttemptsNum', p.Results.maxAttemptsNum);
    end
    
    % Get this backtrace of all functions leading to this point
    dbs = dbstack;
    backTrace = ''; depth = length(dbs);
    while (depth >= 1)
        backTrace = sprintf('%s-> %s ', backTrace, dbs(depth).name);
        depth = depth - 1;
    end
    
    % Check status to ensure we received a 'TRANSMITTED_MESSAGE_MATCHES_EXPECTED' message
    assert(strcmp(status, p.Results.obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED), sprintf('%s: Exiting due to mismatch in message labels.\nExpected label: ''%s'', Received label: ''%s''.\n', backTrace, p.Results.obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED, status));
end
