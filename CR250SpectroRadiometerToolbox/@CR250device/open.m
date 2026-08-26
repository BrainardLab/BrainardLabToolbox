% Method to open the CR250

%  History:
%    April 2025  NPC  Wrote it


function open(obj)

    % ------ SET THE VERBOSITY LEVEL (1=minimum, 5=intermediate, 10=full)--
    %status = CR250_device('setVerbosityLevel', 10);

    % ------ OPEN THE CR250 device ----------------------------------------------
    status = CR250_device('close');

    % Pause
    pause(obj.commandTriggerDelay);
    
    status = CR250_device('open', obj.devicePortString);
    if (status == 0)
        disp('Opened CR250 port');
    elseif (status == -1)
        disp('Could not open CR250 port');
    elseif (status == 1)
        disp('CR250 port was already opened');
    elseif (status == -99)
        disp('Invalided serial port');
    end

    % Pause
    pause(obj.commandTriggerDelay);

    % ----- SETUP DEFAULT COMMUNICATION PARAMS ----------------------------
    speed     = 115200;
    wordSize  = 8;
    parity    = 0;
    timeOut   = 0;
    
    status = CR250_device('updateSettings', speed, wordSize, parity,timeOut); 
    if (status == 0)
        if (~strcmp(obj.verbosity, 'min'))
            disp('Updated communication settings in CR250 port');
        end
    elseif (status == -1)
        disp('Could not update settings in CR250 port');
    elseif (status == 1)
        disp('CR250 port is not open');
    end

    % ----- READ ANY DATA AVAILABLE AT THE PORT ---------------------------
    [status, dataRead] = CR250_device('readPort');
    if ((status == 0) && (length(dataRead) > 0))
        fprintf('Read data: %s\n', dataRead);
    elseif (status ~= 0)
        fprintf(2, 'Failed reading from the port!!!. Status = %d!!!', status);
    end
end

