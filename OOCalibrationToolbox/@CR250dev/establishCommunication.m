% Method to establish communication with the CR250
function obj = establishCommunication(obj)
    if (obj.verbosity > 9)
        fprintf('In CR250obj.establishCommunication() method\n');
    end

    openDevice(obj.portString, obj.commandTriggerDelay);

end


function openDevice(devicePortString, commandTriggerDelay)

    % ------ OPEN THE CR250 device ----------------------------------------------
    status = CR250_device('close');

    % Pause
    pause(commandTriggerDelay);

    status = CR250_device('open', devicePortString);
    if (status == 0)
        disp('Opened CR250 port');
    elseif (status == -1)
        disp('Could not open CR250 port');
    elseif (status == 1)
        disp('CR250 port was already opened');
    elseif (status == -99)
        disp('Invalided serial port');
    end

    % ----- SETUP DEFAULT COMMUNICATION PARAMS ----------------------------
    speed     = 115200;
    wordSize  = 8;
    parity    = 0;
    timeOut   = 0;
    
    status = CR250_device('updateSettings', speed, wordSize, parity,timeOut); 
    if (status == 0)
        disp('Updated communication settings in CR250 port');
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

