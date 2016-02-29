function shuDown(obj)
    if (obj.useNativeUDP)
        matlabUDP('close');
    end
end

