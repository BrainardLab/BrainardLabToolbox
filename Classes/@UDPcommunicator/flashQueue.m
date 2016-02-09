function flashedContents = flashQueue(obj)
    while (matlabUDP('check') == 1)
        flashedContents = matlabUDP('receive');
    end
end

