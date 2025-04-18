% Method to close the CR250

%  History:
%    April 2025  NPC  Wrote it

function close(obj)
    status = CR250_device('close');
    if (status == 0)
        if (~strcmp(obj.verbosity, 'min'))
            disp('Closed previously-opened CR250 port');
        end
    elseif (status == -1)
        disp('Could not close previously-opened CR250 port');
    end
end