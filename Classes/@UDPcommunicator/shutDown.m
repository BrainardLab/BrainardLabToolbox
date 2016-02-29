function shutDown(obj)
    if (obj.useNativeUDP)
        matlabUDP('close');
    end
end

