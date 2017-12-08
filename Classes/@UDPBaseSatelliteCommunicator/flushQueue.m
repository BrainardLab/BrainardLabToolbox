function flushedContents = flushQueue(obj)
    while (matlabNUDP('check', obj.udpHandle) == 1)
        flushedContents = matlabNUDP('receive', obj.udpHandle);
    end
end

