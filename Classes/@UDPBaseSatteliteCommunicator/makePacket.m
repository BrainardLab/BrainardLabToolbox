function packet = makePacket(obj, satteliteName, direction, message, varargin) 
    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('withData', []);
    p.addParameter('timeOutSecs',  5, @isnumeric);
    p.addParameter('attemptsNo', 1, @isnumeric);
    p.addParameter('timeOutAction', UDPcommunicator2.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {UDPcommunicator2.NOTIFY_CALLER, UDPcommunicator2.THROW_ERROR})));
    p.addParameter('badTransmissionAction', UDPcommunicator2.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {UDPcommunicator2.NOTIFY_CALLER, UDPcommunicator2.THROW_ERROR})));
    p.parse(varargin{:});
    data = p.Results.withData;
    
    % validate direction
    assert((contains(direction, '->')) || (contains(direction, '<-')), sprintf('direction field does not contain correct direction information: ''%s''.\n', direction));
    
    % validate sattelite name
    satteliteNames = keys(obj.satteliteInfo);
    assert(ismember(satteliteName, satteliteNames), sprintf('passed sattelite name: ''%s'', is not valid\n', satteliteName));
    
    packet = struct(...
        'udpChannel', obj.satteliteInfo(satteliteName).satteliteChannel, ...
        'direction', direction, ...
        'messageLabel', message, ...
        'messageData', data, ...
        'attemptsNo', p.Results.attemptsNo, ...                         % How many times to re-transmit if we did not get an ACK within the receiveTimeOut
        'timeOutSecs', p.Results.timeOutSecs, ...                       % Timeout for receiving an ACK in response to transmission or for waiting for a message to be received
        'timeOutAction', p.Results.timeOutAction, ...                   % What to do in case of a timeout
        'badTransmissionAction', p.Results.badTransmissionAction ...    % What to do in case of a bad transmission (only used when waiting for a message)
    );
end
