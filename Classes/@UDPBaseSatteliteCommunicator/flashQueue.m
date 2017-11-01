function flashedContents = flashQueue(obj)
    while (matlabNUDP('check', obj.udpHandle) == 1)
        flashedContents = matlabNUDP('receive', obj.udpHandle);
    end
end

