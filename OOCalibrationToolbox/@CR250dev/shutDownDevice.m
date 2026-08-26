function obj = shutDownDevice(obj)

    % Pause
    pause(obj.commandTriggerDelay);

    status = CR250_device('close');
    if (status == 0)
        if (~strcmp(obj.verbosity, 'min'))
            disp('Closed previously-opened CR250 port');
        end
    elseif (status == -1)
        disp('Could not close previously-opened CR250 port');
    end

end