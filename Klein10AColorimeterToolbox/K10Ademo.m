function K10Ademo
% K10Ademo- Demonstrates the usage of the K10A_device driver for
% controlling the Klein K10A luminance meter.
%
% Syntax:
% K10Ademo
%
% Description:
% K10demo demostrates the different commands that can be sent to the K10A_device 
% driver which enables the user to conduct high temporal frequency measurements
% across a very large range of luminance levels (0.001 to 4000+ cd/m^2)
%
% Controls:
% 'q'         - Terminates infinite stream and exits the demo
%
% History:
% 1/30/2014   npc    Wrote it.
% 1/31/2013   npc    Updated 'SingleShot XYZ' command to return both XYZ and xyY.
%                    Updated 'Standard Stream' command to return an 8Hz stream of the raw corrected XYZ instead of the xyY values.
%

    % ----- COMPILE THE DRIVER (JUST IN CASE IT HAS NOT BEEN COMPILED) ----
    disp('Compiling KleinK10A device driver ...');
    currentDir = pwd;
    programName = 'K10Ademo.m';
    d = which(programName);
    k = findstr(d, programName);
    d = d(1:k-1);
    cd(d);
    mex('K10A_device.c');
    cd(currentDir);
    disp('KleinK10A device driver compiled sucessfully!')
    % ------ SET THE VERBOSITY LEVEL (1=minimum, 5=intermediate, 10=full)--
    status = K10A_device('setVerbosityLevel', 1);
    
    
    % ------ OPEN THE DEVICE ----------------------------------------------

     if (ismac)
        portName = '/dev/tty.usbserial-KU000000';
    else
        portName = '/dev/ttyUSB0';
     end

    status = K10A_device('open', portName);


    if (status == 0)
        disp('Opened Klein port');
    elseif (status == -1)
        disp('Could not open Klein port');
    elseif (status == 1)
        disp('Klein port was already opened');
    elseif (status == -99)
        disp('Invalided serial port');
    end
    
    
    % ----- SETUP DEFAULT COMMUNICATION PARAMS ----------------------------
    speed     = 9600;
    wordSize  = 8;
    parity    = 'n';
    timeOut   = 50000;
    
    status = K10A_device('updateSettings', speed, wordSize, parity,timeOut); 
    if (status == 0)
        disp('Update communication settings in Klein port');
    elseif (status == -1)
        disp('Could not update settings in Klein port');
    elseif (status == 1)
        disp('Klein port is not open');
    end
    
    
    % ----- READ ANY DATA AVAILABLE AT THE PORT ---------------------------
    [status, dataRead] = K10A_device('readPort');
    if ((status == 0) && (length(dataRead) > 0))
        fprintf('Read data: %s (%d chars)\n', dataRead, length(dataRead));
    end 
        
    
    % ----- WRITE SOME DUMMY DATA TO THE PORT -----------------------------
    status = K10A_device('writePort', 'Do you feel lucky, punk?');
    

    % ----- READ ANY DATA AVAILABLE ATTHE PORT ----------------------------
    [status, dataRead] = K10A_device('readPort');
    if ((status == 0) && (length(dataRead) > 0))
        fprintf('Read data: %s (%d chars)\n', dataRead, length(dataRead));
    end 
    
    
    % ------------- GET THE SERIAL NO OF THE KLEIN METER ------------------
    [status, modelAndSerialNo] = ...
        K10A_device('sendCommand', 'Model and SerialNo');
    fprintf('Serial no and model: %s\n', modelAndSerialNo);
    
    
    % ------------ GET THE FIRMWARE REVISION OF THE KLEIN METER -----------
    [status, response] = K10A_device('sendCommand', 'FlickerCal & Firmware');
    fprintf('>>> Firmware version: %s\n', response(20:20+7-1));
        
         
    % ------------ TURN AIMING LIGHTS ON ----------------------------------
    [status] = K10A_device('sendCommand', 'Lights ON');
    
    % ------------ TURN AIMING LIGHTS OFF ---------------------------------
    disp('Hit enter to turn lights off'); pause;
    [status] = K10A_device('sendCommand', 'Lights OFF');
        
    
    % ------------- ENABLE AUTO-RANGE -------------------------------------
    [status, response] = K10A_device('sendCommand', 'EnableAutoRanging');
    
    
    % ------------- GET SOME CORRECTED xyY MEASUREMENTS -------------------
    for k = 1:10
        [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
        fprintf('response[%d]:%s\n', k, response);
    end
        
    % ----------- LOCK THE RANGE FOR STREAMING -----------------------
    disp('Select a luminance range');
    disp('Range 1: Can measure down to 0.001 cd/m^2, saturates at around  20 cd/m^2');
    disp('Range 2: Can measure down to 0.010 cd/m^2, saturates at around 240 cd/m^2');
    disp('Range 3: Can measure down to 0.400 cd/m^2, saturates at around 800 cd/m^2');
    disp('Range 4: Saturates above 2000 cd/m^2');
    disp('Range 5: Saturates above xxxx cd/m^2');
    disp('Range 6: Saturates above yyyy cd/m^2');
    luminanceRange = input('Range [1-6] : ');

    [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
    switch luminanceRange
        case 1
            [status, response] = K10A_device('sendCommand', 'LockInRange1');
        case 2
            [status, response] = K10A_device('sendCommand', 'LockInRange2');
        case 3
            [status, response] = K10A_device('sendCommand', 'LockInRange3');
        case 4
            [status, response] = K10A_device('sendCommand', 'LockInRange4');
        case 5
            [status, response] = K10A_device('sendCommand', 'LockInRange5');
        case 6
            [status, response] = K10A_device('sendCommand', 'LockInRange6');
        otherwise
            [status, response] = K10A_device('sendCommand', 'LockInRange2');
    end
    
    
    % -------- STREAM 256 MEASUREMENTS/SECOND AND DISPLAY THE RESULTS -----
    h = figure(1);
    clf;
    set(h, 'Position', [10 10 2000 1000]);
    plotHandle1 = plot(1:1000, (1:1000)*0, 'ks-', 'MarkerSize', 6, 'MarkerFaceColor', [0.9 0.7 0.8], 'MarkerEdgeColor', [1.0 0.0 0.0]);
    set(gca, 'YLim', [0 65500]);
    set(gca, 'Position', [0.035 0.06 0.95 0.9]);
    set(gca, 'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'Bold');
    xlabel('Time (mseconds)');
    ylabel(sprintf('Luminance A/D value (arbitrary units)       LUMINANCE RANGE: %d ', luminanceRange));
    
    try
        % INITIALIZE KEYBOARD QUEUE
        ListenChar(2);
        mglGetKeyEvent;

        % STREAM DATA AND UPDATE PLOT EVERY streamDurationInSeconds 
        streamDurationInSeconds = 1.5;
        keepLooping = true;
       
        while (keepLooping)
            % ---- STREAM FOR SPECIFIED DURATION --------------------------
            [status, uncorrectedYdata256HzStream, ...
                     correctedXdata8HzStream, ...
                     correctedYdata8HzStream, ...
                     correctedZdata8HzStream] = ...
                K10A_device('sendCommand', 'Standard Stream', streamDurationInSeconds);
            % -------------------------------------------------------------
            
            % ----- COMPUTE xy CIE COORDINATES ----------------------------
            meanX = mean(correctedXdata8HzStream);
            meanY = mean(correctedYdata8HzStream);
            meanZ = mean(correctedZdata8HzStream);
            meanCIExChroma = meanX / (meanX + meanY + meanZ);
            meanCIEyChroma = meanY / (meanX + meanY + meanZ);
            
            % ---- PLOT RESPONSE ------------------------------------------
            figure(h);
            time = [1:length(uncorrectedYdata256HzStream)]/256.0 * 1000.0;
            set(plotHandle1,'XData',time, 'YData',uncorrectedYdata256HzStream);
            title(sprintf('Ylum: %4.4f Cd/m^2,  CIE (x,y): (%4.2f, %4.2f)        (Luminance A/D: mean=%4.4f, sigma=%4.4f)', ...
                meanY, meanCIExChroma, meanCIEyChroma, ...
                mean(uncorrectedYdata256HzStream), std(uncorrectedYdata256HzStream)), ...
                'FontName', 'Helvetica', 'FontSize', 20, 'FontWeight', 'Bold');
            drawnow;
            
            % ---- CHECK FOR 'q' KEY PRESS TO TERMINATE LOOP --------------
            key = mglGetKeyEvent;
            if (~isempty(key))    
               if (key.keyCode == 13)
                   keepLooping = false;
               end
            end             
        end    

        % -------- DISABLE KEYBOARD CAPTURE -------------------------------
        ListenChar(0);

        % -------- ENABLE AUTO-RANGE --------------------------------------
        [status, response] = K10A_device('sendCommand', 'EnableAutoRanging');
        
        
        % -------- GET SOME CORRECTED xyY MEASUREMENTS --------------------
        for k=1:5
            [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
            fprintf('response[%d]:%s\n', k, response);
        end

        
        % ------- CLOSE THE DEVICE ----------------------------------------
        status = K10A_device('close');
        if (status == 0)
           disp('Closed previously-opened Klein port');
        elseif (status == -1)
           disp('Could not close previously-opened Klein port');
        end
    
    catch e
        % -------- DISABLE KEYBOARD CAPTURE -------------------------------
        ListenChar(0);
        
        % ------ CLOSE THE DEVICE -----------------------------------------
        status = K10A_device('close');
        if (status == 0)
           disp('Closed previously-opened Klein port');
        elseif (status == -1)
           disp('Could not close previously-opened Klein port');
        end
        
        rethrow(e);
    end
    
end

