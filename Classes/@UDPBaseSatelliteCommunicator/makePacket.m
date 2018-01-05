function packet = makePacket(obj, satelliteName, direction, message, varargin)
    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('withData', []);
    p.addParameter('timeOutSecs',  5, @isnumeric);
    p.addParameter('attemptsNo', 1, @isnumeric);
    p.parse(varargin{:});
    data = p.Results.withData;

    % validate direction
    assert((contains(direction, '->')) || (contains(direction, '<-')), sprintf('direction field does not contain correct direction information: ''%s''.\n', direction));

    % validate satellite name
    satelliteNames = keys(obj.satelliteInfo);
    assert(ismember(satelliteName, satelliteNames), sprintf('passed satellite name: ''%s'', is not valid\n', satelliteName));

    packet = struct(...
        'udpChannel', obj.satelliteInfo(satelliteName).satelliteChannelID, ...
        'direction', direction, ...
        'messageLabel', message, ...
        'messageData', data, ...
        'attemptsNo', p.Results.attemptsNo, ...                         % How many times to re-transmit if we did not get an ACK within the receiveTimeOut
        'timeOutSecs', p.Results.timeOutSecs ...                       % Timeout for receiving an ACK in response to transmission or for waiting for a message to be received
    );
end
