function CR250demo
% CR250Ademo- Demonstrates the usage of the CR250_device driver for
% controlling the CR250 colorimeter.
%
% Syntax:
% CR250demo
%
% Description:
% CR250demo demostrates the different commands that can be sent to the CR250_device 
%
% Controls:
% 'q'         - Terminates infinite stream and exits the demo
%
% History:
% 4/9/2025   npc    Wrote it.
%

% ----- COMPILE THE DRIVER (JUST IN CASE IT HAS NOT BEEN COMPILED) ----
    disp('Compiling CR250 device driver ...');
    currentDir = pwd;
    programName = 'CR250demo.m';
    d = which(programName);
    k = findstr(d, programName);
    d = d(1:k-1);
    cd(d);
    mex('CR250_device.c');
    cd(currentDir);
    disp('CR250 device driver compiled sucessfully!');


% ------ SET THE VERBOSITY LEVEL (1=minimum, 5=intermediate, 10=full)--
    status = CR250_device('setVerbosityLevel', 10);


% ------ OPEN THE CR250 device ----------------------------------------------
    status = CR250_device('close')
    status = CR250_device('open', '/dev/tty.usbmodemA009271');
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
        fprintf('Read data: %s (%d chars)\n', dataRead, length(dataRead));
    end 

    % Toggle the echo state
    %[status, deviceID] = CR250_device('sendCommand', 'E');

    % Get the device ID
    [status, response] = CR250_device('sendCommand', 'RC ID');
    if ((status == 0) && (length(response) > 0))
        fprintf('DEVICE_RESPONSE to RC ID command:%s (%d chars)\n', char(response), length(response));
        for k = 1:length(response)
            fprintf('%d %s\n', k, response(k));
        end
    end 
    
    % Conduct a measurement
    [status, response] = CR250_device('sendCommand', 'M');
    if ((status == 0) && (length(response) > 0))
        fprintf('DEVICE_RESPONSE to M command:%s (%d chars)\n', char(response), length(response));
        for k = 1:length(response)
            fprintf('%d %s\n', k, response(k));
        end
    end 
    


    status = CR250_device('close');
    if (status == 0)
       disp('Closed previously-opened CR250 port');
    elseif (status == -1)
       disp('Could not close previously-opened CR250 port');
    end
