% Method to send a parameter value
% ex.: OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something');
% or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.protocolName, 'something', params.protocolName, timeOutSecs, 2.0, 'maxAttemptsNum', 3);
% or   OLVSG.sendParamValue(OLVSG.protocolName, OLVSG.go, []);

function sendParamValue(obj, paramNameAndValue,  varargin)
    
    obj.currentMessageNo = obj.currentMessageNo + 1;
    
    % parse input
    defaultTimeOutSecs = 2;
    defaultMaxAttemptsNum = 3;
    defaultConsoleMessage = '';
    p = inputParser;
    p.addRequired('paramNameAndValue', @iscell);
    p.addParamValue('timeOutSecs', defaultTimeOutSecs,   @isnumeric);
    p.addParamValue('maxAttemptsNum', defaultMaxAttemptsNum, @isnumeric);
    p.addParamValue('consoleMessage', defaultConsoleMessage,   @ischar);
    p.parse(paramNameAndValue, varargin{:});
    
    % Get this backtrace of all functions leading to this point
    dbs = dbstack;
    backTrace = ''; depth = length(dbs);
    while (depth >= 1)
        backTrace = sprintf('%s-> %s ', backTrace, dbs(depth).name);
        depth = depth - 1;
    end
    
    % Get the param name and value
    paramName = p.Results.paramNameAndValue{1};
    if (numel(p.Results.paramNameAndValue) == 2)
    	paramValue = p.Results.paramNameAndValue{2};
    else
        paramValue = nan;
    end
    
    % print feedback message to console
    if (~isempty(p.Results.consoleMessage))
        if (isinf(p.Results.timeOutSecs))
            fprintf('\n[%3d] <strong>%s</strong> [waiting for ever to receive value for ''%s''] ....', obj.currentMessageNo, p.Results.consoleMessage, paramName);
        else
            fprintf('\n[%3d] <strong>%s</strong> [waiting for %2.1f secs to receive value for ''%s''] ....', obj.currentMessageNo, p.Results.consoleMessage, p.Results.timeOutSecs, paramName);
        end
    end
    
    % validate paramValue before sending it, if there is a valid range for
    % this paramName
    obj.validateValueForParam(paramName, paramValue, backTrace);
    
    % send it
    status = obj.sendMessage(paramName, paramValue, p.Results.timeOutSecs, 'maxAttemptsNum', p.Results.maxAttemptsNum);

    % Check status to ensure we received a 'TRANSMITTED_MESSAGE_MATCHES_EXPECTED' message
    assert(strcmp(status, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED), sprintf('%s: Exiting due to mismatch in message labels.\nExpected label: ''%s'', Received label: ''%s''.\n', backTrace, obj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED, status));

    if (~isempty(p.Results.consoleMessage))
        fprintf('<strong>DONE</strong>\n');
    end
end
