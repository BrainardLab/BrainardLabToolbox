% Method that flushes the UDP channel when something goes bad during a
% transmission.
function flushedContents = flushQueue(obj)
    % Wait to make sure the sender has sent all the data, then flush it
    %pause(obj.flushDelay);
    flushedContents = '';
    while (matlabNUDP('check', obj.udpHandle) == 1)
        flushedContents = matlabNUDP('receive', obj.udpHandle);
    end
end

