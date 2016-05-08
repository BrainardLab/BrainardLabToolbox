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
       
    obj.currentMessageNo = obj.currentMessageNo + 1;
    
    % parse input
    defaultTimeOutSecs = Inf;
    defaultConsoleMessage = '';
    defaultExpectedParamValue = [];
    p = inputParser;
    p.addRequired('paramName', @ischar);
    p.addParamValue('expectedParamValue', defaultExpectedParamValue);
    p.addParamValue('timeOutSecs', defaultTimeOutSecs,   @isnumeric);
    p.addParamValue('consoleMessage', defaultConsoleMessage,   @ischar);
    p.parse(paramName, varargin{:});

    % print feedback message to console
    if (~isempty(p.Results.consoleMessage)) && (~strcmp(obj.verbosity,'none'))
        if (isinf(p.Results.timeOutSecs))
            fprintf('\n[%3d] <strong>%s</strong> [waiting for ever to receive value for ''%s''] ....', obj.currentMessageNo, p.Results.consoleMessage, paramName);
        else
            fprintf('\n[%3d] <strong>%s</strong> [waiting for %2.1f secs to receive value for ''%s''] ....', obj.currentMessageNo, p.Results.consoleMessage, p.Results.timeOutSecs, paramName);
        end
    end
    % Wait for ever for a message to be received
    response = obj.waitForMessage(p.Results.paramName, 'timeOutSecs', p.Results.timeOutSecs);

    if (~strcmp(obj.verbosity,'none'))
        % Get this backtrace of all functions leading to this point
        dbs = dbstack;
        backTrace = ''; depth = length(dbs);
        while (depth >= 1)
            backTrace = sprintf('%s-> %s ', backTrace, dbs(depth).name);
            depth = depth - 1;
        end
    else
         backTrace = 'no backtrace';
    end
    
    % Check for communication error and abort if one occurred
    if (~strcmp(p.Results.paramName, response.msgLabel))
        if (strcmp(response.msgLabel, obj.ABORT_MAC_DUE_TO_WINDOWS_FAILURE))
            Speak('Windows computer experienced a fatal error. Mac computer aborting now.');
            error('Windows computer experienced a fatal error. Mac computer aborting now.\n');
        else
            error(sprintf('%s: Exiting due to mismatch in message labels.\nExpected label: ''%s'', Received label: ''%s''.\n', backTrace, p.Results.paramName, response.msgLabel));
        end
    end
    
    % Get the message value received
    paramValue = response.msgValue;
    
    % validate paramValue before returning, if there is a valid range for this paramName
    obj.validateValueForParam(paramName, paramValue, backTrace);
    
    % check the param value before returning, if we got an expectedParamValue
    if (~isempty(p.Results.expectedParamValue)) && (~strcmp(obj.verbosity,'none'))
        if (ischar(paramValue))
            assert(strcmp(paramValue, p.Results.expectedParamValue), sprintf('%s: Exiting due to mismatch param values.\nExpected value: ''%s'', Received value: ''%s''.\n', backTrace, p.Results.expectedParamValue, paramValue));
        elseif (isnumeric(paramValue)) 
            assert(abs(paramValue - p.Results.expectedParamValue) < 500*eps, sprintf('%s: Exiting due to mismatch param values.\nExpected value: ''%f'', Received value: ''%f''.\n', backTrace, p.Results.expectedParamValue, paramValue));
        elseif (islogical(paramValue))
            assert(paramValue ~= p.Results.expectedParamValue, sprintf('%s: Exiting due to mismatch param values.\nExpected value: ''%d'', Received value: ''%d''.\n', backTrace, p.Results.expectedParamValue, paramValue));
        else
            fprintf(2,'Do not know how to compare param values that are not strings, logical or numerics\n');
        end
    end
    
    if (~isempty(p.Results.consoleMessage)) && (~strcmp(obj.verbosity,'none'))
        fprintf('<strong>DONE</strong>\n');
    end
end