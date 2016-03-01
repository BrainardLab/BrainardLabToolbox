% Method to receive a parameter value.
% Example usage:
% Wait for ever to receive a message labeled 'Protocol Name', and if you do
% return the associated value into protocolNameStr
% protocolNameStr = VSGOL.receiveParamValue('Protocol Name');
%
% Wait for up to 2 seconds to receive a message labeled 'User Ready'
% and if you do return the associated value into userReady.
% Raise an exception if nothing is received within 2.0 seconds
% userReady = VSGOL.receiveParamValue('User Ready', timeOutSecs, 2.0);
%
function paramValue = receiveParamValue(obj, paramName, varargin)
            
    % parse input
    defaultTimeOutSecs = Inf;
    defaultConsoleMessage = '';
    p = inputParser;
    p.addRequired('obj');
    p.addRequired('paramName', @ischar);
    p.addParamValue('timeOutSecs', defaultTimeOutSecs,   @isnumeric);
    p.addParamValue('consoleMessage', defaultConsoleMessage,   @ischar);
    p.parse(obj, paramName, varargin{:});

    % print feedback message to console
    if (~isempty(p.Results.consoleMessage))
        fprintf('\n%s [waiting to receive value for ''%s''] ....', p.Results.consoleMessage, paramName);
    end
    % Wait for ever for a message to be received
    response = p.Results.obj.waitForMessage(p.Results.paramName, 'timeOutSecs', p.Results.timeOutSecs);

    % Get this backtrace of all functions leading to this point
    dbs = dbstack;
    backTrace = ''; depth = length(dbs);
    while (depth >= 1)
        backTrace = sprintf('%s-> %s ', backTrace, dbs(depth).name);
        depth = depth - 1;
    end

    % Check for communication error and abort if one occurred
    assert(strcmp(response.msgLabel, paramName), sprintf('%s: Exiting due to mismatch in message labels.\nExpected label: ''%s'', Received label: ''%s''.\n', backTrace, p.Results.paramName, response.msgLabel));

    % Get the message value received
    paramValue = response.msgValue;
    
    % validate paramValue before returning, if there is a valid range for
    % this paramName
    obj.validateValueForParam(paramName, paramValue, backTrace);
end