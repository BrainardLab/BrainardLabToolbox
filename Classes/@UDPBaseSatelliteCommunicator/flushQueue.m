function flushedContents = flushQueue(obj)
    flushedContents = '';
    while (matlabNUDP('check', obj.udpHandle) == 1)
        flushedContents = matlabNUDP('receive', obj.udpHandle);
    end
end

