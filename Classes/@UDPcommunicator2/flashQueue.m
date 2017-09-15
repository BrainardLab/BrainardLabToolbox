function flashedContents = flashQueue(obj)
    if (obj.useNativeUDP)
        flashedContents = 'a';
        while (~isempty(flashedContents))
            flashedContents = fread(obj.udpClient);
        end
    else
        while (matlabUDP('check') == 1)
            flashedContents = matlabUDP('receive');
        end
    end
end

