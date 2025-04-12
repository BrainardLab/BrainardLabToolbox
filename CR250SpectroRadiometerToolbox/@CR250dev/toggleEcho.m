function toggleEcho(obj)
    % Toggle the echo state
    [status, deviceID] = CR250_device('sendCommand', 'E');
end