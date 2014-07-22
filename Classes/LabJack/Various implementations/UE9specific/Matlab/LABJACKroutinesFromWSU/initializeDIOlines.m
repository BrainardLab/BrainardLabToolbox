function status = initializeDIOlines

    global LABJACKstruct

    
    status = 0;
    
    if (~LABJACKstruct.devicePointerIsValid)
        disp('LABJACK device pointer is not valid. ConfigDevice will not execute');
        status = -1;
        return;
    end
    
    
    
    fprintf('Setting first 16 DIO lines to OUTPUT mode\n\n');
    
    
    % chanelID     LABEL            16-bit port arrangment 
    %
    %   0         'FIO_0';          D0 ( least significant bit)
    %   1         'FIO_1';          D1  
    %   2         'FIO_2';          D2  
    %   3         'FIO_3';          D3  
    %   4         'FIO_4';          D4  
    %   5         'FIO_5';          D5  
    %   6         'FIO_6';          D6  
    %   7         'FIO_7';          D7 
    %
    %
    %   8         'EIO_0';          D8 
    %   9         'EIO_1';          D9  
    %   10        'EIO_2';          D10  
    %   11        'EIO_3';          D11  
    %   12        'EIO_4';          D12 
    %   13        'EIO_5';          D13  
    %   14        'EIO_6';          D14  
    %   15        'EIO_7';          D15 ( most significant bit) 
    
    
    
    LABJACKstruct.DIO16bitChannelArrangement = uint8([15:-1:0]);        % most signigicant to least significant bit
    
    channelIDs  = LABJACKstruct.DIO16bitChannelArrangement;             % Valid options are [0 .. 19] (20 DIO channels total)
    directions  = uint8(ones(size(channelIDs)));                        % Valid options are [0 .. 1]  (0 = INPUT, 1 = OUTPUT)
    
    status      = configDigitalLines(channelIDs, directions);
    
    
        
end



function status = configDigitalLines(channelIDs, directions)

    
    
    % Feedback command to set (A) digital Channel to output and (B) the State
    
    sendDataMessage     = zeros(2*length(channelIDs),1, 'uint8');
    
    for channelIndex = 1:length(channelIDs)
        sendDataMessage(1 + 2*(channelIndex-1))  = 13;                                                             % IOType if BitDirWrite
        sendDataMessage(2 + 2*(channelIndex-1))  = channelIDs(channelIndex) + 128*directions(channelIndex);        % IONumber(bits 0-4) is channelID + Direction (bit 7): 1 write, 0: read
    end
    
    
    status = sendLowLevelCommand(sendDataMessage);
     
    
end


 
