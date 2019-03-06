function measureLuminanceModulation256Hz()
% measureLuminanceModulation256Hz - Demonstrates the usage of the 
% K10A_device driver for streaming 256Hz luminance measurements.
%
% Syntax:
% measureLuminanceModulation256Hz()
%
% Description:
% Stream and visualize luminance data at 256 Hz using the Klein K10 device
%
%
% History:
% 3/6/2019   npc    Wrote it.

    % Open the Klein
    openKlein();
    
    % Do some tests
    testKlein();
    disp('Hit enter to continue');
    pause()
    
    % Set the luminance range
    maxLuminance = setKleinLuminanceRange();
    
    % Stream for 2 seconds
    streamDurationSeconds = 2;
    
    %
    try
        for k = 1:10
            stream256HzDataFromKlein(streamDurationSeconds, maxLuminance);
        end
        
        closeKlein();
    catch e
        
        % ------ CLOSE THE DEVICE -----------------------------------------
        closeKlein()
        
        rethrow(e);
    end
end

function testKlein()

     % ------------- ENABLE AUTO-RANGE -------------------------------------
    [status, response] = K10A_device('sendCommand', 'EnableAutoRanging');
    
    
    % ------------- GET SOME CORRECTED xyY MEASUREMENTS -------------------
    for k = 1:10
        [status, response] = K10A_device('sendCommand', 'SingleShot XYZ');
        fprintf('response[%d]:%s\n', k, response);
    end
    
end

function stream256HzDataFromKlein(streamDurationSeconds, maxLuminance)

    [status, uncorrectedYdata256HzStream, ...
                     correctedXdata8HzStream, ...
                     correctedYdata8HzStream, ...
                     correctedZdata8HzStream] = K10A_device('sendCommand', 'Standard Stream', streamDurationSeconds);
                 
    % Correct luminance data
    minLum = min(correctedYdata8HzStream);
    maxLum = max(correctedYdata8HzStream);
    maxV = max(uncorrectedYdata256HzStream);
    minV = min(uncorrectedYdata256HzStream);
    normalizedLuminanceData = (uncorrectedYdata256HzStream-minV)/(maxV-minV);
    correctedLuminanceData = normalizedLuminanceData * (maxLum-minLum)+minLum;
    
    
    time = (1:length(correctedLuminanceData))/256.0 * 1000.0;
    figure(1); clf;
    plot(time, correctedLuminanceData, 'k.-');
    xlabel('time (msec)');
    ylabel('luminance (cd/m2)');
    set(gca, 'XTick', 0:200:time(end), 'XLim', [0 time(end)], 'YLim', [0 maxLuminance], 'YTick', 0:50:maxLuminance);
    grid on; box on
    drawnow;

end

function maxLuminance = setKleinLuminanceRange()

    disp('Select a luminance range');
    disp('Range 1: Can measure down to 0.001 cd/m^2, saturates at around  19 cd/m^2');
    disp('Range 2: Can measure down to 0.010 cd/m^2, saturates at around 120 cd/m^2');
    disp('Range 3: Can measure down to 0.400 cd/m^2, saturates at around 800 cd/m^2');
    disp('Range 4: Saturates above 2000 cd/m^2');
    disp('Range 5: Saturates above xxxx cd/m^2');
    disp('Range 6: Saturates above yyyy cd/m^2');
    luminanceRange = GetWithDefault('Range [1-6]: ',3);
    
    [status, response] = K10A_device('sendCommand', 'DisableAutoRanging');
    switch luminanceRange
        case 1
            [status, response] = K10A_device('sendCommand', 'LockInRange1');
            maxLuminance = 19;
        case 2
            [status, response] = K10A_device('sendCommand', 'LockInRange2');
            maxLuminance = 120;
        case 3
            [status, response] = K10A_device('sendCommand', 'LockInRange3');
            maxLuminance = 800;
        case 4
            [status, response] = K10A_device('sendCommand', 'LockInRange4');
            maxLuminance = 2000;
        case 5
            [status, response] = K10A_device('sendCommand', 'LockInRange5');
            maxLuminance = 4000;
        case 6
            [status, response] = K10A_device('sendCommand', 'LockInRange6');
            maxLuminance = 8000;
        otherwise
            [status, response] = K10A_device('sendCommand', 'LockInRange2');
            maxLuminance = 240;
    end
    
end

function closeKlein()
    status = K10A_device('close');
    fprintf('Closed the Klein K10A colorimeter\n');
end

function openKlein()
    % ------ SET THE VERBOSITY LEVEL (1=minimum, 5=intermediate, 10=full)--
    status = K10A_device('setVerbosityLevel', 1);
    
    % ------ OPEN THE DEVICE ----------------------------------------------
    status = K10A_device('open', '/dev/tty.usbserial-KU000000');
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
    
    
    fprintf('Opened and established communication with the Klein K10A colorimeter\n');
    
end
