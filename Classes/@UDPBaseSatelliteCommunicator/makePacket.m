% Method to compose a transmission packet based on the desired direction
% (base-to-sattelite or sattelite-to-base) with a given message label,
% message data, and a timeout delay. The attemptsNo param is currently not
% used - the attempts number is controlled by communicate() method.
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
        'attemptsNo', p.Results.attemptsNo, ... 
        'timeOutSecs', p.Results.timeOutSecs ... 
    );
end
