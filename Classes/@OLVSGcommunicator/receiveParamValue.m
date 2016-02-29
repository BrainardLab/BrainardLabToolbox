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
            
    if (~ischar(paramName))
        error('Input to receiveParamValue must be a string corresponding to the parameter name.');
    else
        defaultTimeOutSecs = Inf;
        p = inputParser;
        p.addParamValue('timeOutSecs', defaultTimeOutSecs,   @isnumeric);
        p.parse(varargin{:});

        % Wait for ever for a message to be received
        response = obj.waitForMessage(paramName, 'timeOutSecs', p.Results.timeOutSecs);

        % Get this backtrace of all functions leading to this point
        dbs = dbstack;
        backTrace = ''; depth = length(dbs);
        while (depth >= 1)
            backTrace = sprintf('%s-> %s ', backTrace, dbs(depth).name);
            depth = depth - 1;
        end

        % Check for communication error and abort if one occurred
        assert(strcmp(response.msgLabel, paramName), sprintf('%s: Exiting due to mismatch in message labels.\nExpected label: ''%s'', Received label: ''%s''.\n', backTrace, paramName, response.msgLabel));

        % Get the message value received
        paramValue = response.msgValue;
    end
end