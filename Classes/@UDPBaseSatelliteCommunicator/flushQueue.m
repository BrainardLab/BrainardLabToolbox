% Method that flushes the UDP channel when something goes bad during a
% transmission.
function flushedContents = flushQueue(obj)
    
    if (obj.flushDelay > 0)
        % Wait to make sure the sender has sent all the data
        pause(obj.flushDelay);
    end
    
    % flush it
    flushedContents = '';
    fprintf('Will flush\n');
    while (matlabNUDP('check', obj.udpHandle) == 1)
        flushedContents = matlabNUDP('receive', obj.udpHandle)
    end
end