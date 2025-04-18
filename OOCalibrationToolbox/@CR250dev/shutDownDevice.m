function obj = shutDownDevice(obj)
    status = CR250_device('close');
    if (status == 0)
        if (obj.verbosity > 1)
            disp('Closed previously-opened CR250 port');
        end
    elseif (status == -1)
        disp('Could not close previously-opened CR250 port');
    end
end