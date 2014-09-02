function status = sendLowLevelCommand(dataMessage)
    
    global LABJACKstruct

    status      = 0;
    
    
    
    if (LABJACKstruct.openDeviceProductID == LABJACKstruct.U6_PRODUCT_ID)
    
   
        sendDWSize = length(dataMessage) + 1;
        if (mod(sendDWSize,2) ~= 0)
            sendDWSize = sendDWSize + 1;
        end
    
        recDWSize = 3;
        if (mod(recDWSize,2) ~= 0)
            recDWSize = recDWSize + 1;
        end
    
    
    
    
        commandBytes = 6;
    
        sendMessageLength       = commandBytes + sendDWSize;
        receiveMessageLength    = commandBytes + recDWSize;
    
    
    
    
        % Generate sendMessage here
    
        sendMessage    = zeros(sendMessageLength, 1, 'uint8');
    
        sendMessage(2) = uint8(hex2dec('F8'));   % Command byte
        sendMessage(3) = uint8(sendDWSize/2);    % Number of data words (.5 word for echo, 1.5 words for IOTypes)
        sendMessage(4) = uint8(hex2dec('00'));   % Extended command number

        sendMessage(7) = 0;                      % Echo
    
        indices = 1:length(dataMessage);
        sendMessage(indices+commandBytes+1) = dataMessage(indices);
    
    
        sendMessage(sendMessageLength) = 0;
    

    
        % Calculate and set the checksum16
        checksum16          = calculateChecksum16(sendMessage,sendMessageLength);
        sendMessage(5)      = uint8(bitand(checksum16, hex2dec('FF')));
        sendMessage(6)      = uint8(bitand(bitshift(checksum16,-8), hex2dec('FF')));
    
        % Calculate and set the checksum8
        sendMessage(1)      = calculateChecksum8(sendMessage);
    
        
    
    else
        
        sendMessageLength       = 34;
        receiveMessageLength    = 64;
        
        
        sendMessage    = zeros(1, sendMessageLength, 'uint8');
    
        sendMessage(2) = uint8(hex2dec('F8'));   % Command byte
        sendMessage(3) = uint8(hex2dec('0E'));   % Number of data words 
        sendMessage(4) = uint8(hex2dec('00'));   % Extended command number
        
        
        
        
        DIOchannelsNum  = length(dataMessage)/2;
        states          = zeros(1, DIOchannelsNum, 'uint8');
        channelIDs      = zeros(1, DIOchannelsNum, 'uint8');
        
        %fprintf('\n State: ');
        for channelIndex = 1:DIOchannelsNum
            % ignore the odd number bytes sendDataMessage(1 + 2*(channelIndex-1))  = 13;
            evenByteNumber = dataMessage(2 + 2*(channelIndex-1));
            
            states(channelIndex)      = floor(evenByteNumber/128);  % 1 or 0
            channelIDs(channelIndex)  = evenByteNumber - states(channelIndex)*128;
            
            %fprintf(' %d ', states(channelIndex));
            
        end  % for channelIndex
        
        
        
        multiplier = uint8(2.^[7:-1:0]);
        sendMessage(7) = uint8(hex2dec('FF'));   % all FIOs
        sendMessage(8) = uint8(hex2dec('FF'));   % all FIOs are output channels
        sendMessage(9) = uint8(sum(states(9:16) .* multiplier));
       
        
        sendMessage(10) = uint8(hex2dec('FF'));   % all EIOs
        sendMessage(11) = uint8(hex2dec('FF'));   % all EIOs are output channels
        sendMessage(12) = uint8(sum(states(1:8) .* multiplier));
        
    
        
        %fprintf('\n');
        
        % Calculate and set the checksum16
        checksum16          = calculateChecksum16(sendMessage,sendMessageLength);
        sendMessage(5)      = uint8(bitand(checksum16, hex2dec('FF')));
        sendMessage(6)      = uint8(bitand(bitshift(checksum16,-8), hex2dec('FF')));
    
        % Calculate and set the checksum8
        sendMessage(1)      = calculateChecksum8(sendMessage);
        
        
        
    end
    
    
    
    
    
    
    
    
    sendBuffer   = libpointer('uint8Ptr', sendMessage);
    bytesWritten = calllib('liblabjackusb', 'LJUSB_Write', LABJACKstruct.devicePointer , sendBuffer, sendMessageLength);
    
    
    if (bytesWritten ~= sendMessageLength)
        disp('An error occurred while trying to write to the Device.');
        status = -1;
        return;
    end
    
    
    % Read the result from the device.
   
    
    receiveMessage  = zeros(receiveMessageLength, 1, 'uint8');
    receiveBuffer   = libpointer('uint8Ptr', receiveMessage);
    
    bytesRead       = calllib('liblabjackusb', 'LJUSB_Read', LABJACKstruct.devicePointer, receiveBuffer, receiveMessageLength);
    
    receiveMessage = get(receiveBuffer, 'value');
    
    if (bytesRead == -1)
        disp('Read Failed');
        status = -1;
        return;
        
    elseif (bytesRead < 8)
        fprintf('ehFeedback error : response buffer is too small; expected %d, received %d\n', receiveMessageLength, bytesRead);
        status = -1;
        return;
        
    elseif (bytesRead < receiveMessageLength) 
        fprintf('An error occurred while trying to read from the Device. Bytes expected: %d; Received: %d', receiveMessageLength, bytesRead);
        
    end
    
    
    
    checksumTotal = calculateChecksum16(receiveMessage, receiveMessageLength);
    
    
    
    if (uint8( bitand( bitshift(checksumTotal,-8), hex2dec('FF')) ) ~= receiveMessage(6) )

        printf('ehFeedback error : received buffer has bad checksum16(MSB)\n');
        status = -1;
        return;
    end


    if ( uint8(bitand(checksumTotal, hex2dec('FF'))) ~= receiveMessage(5) )
        printf('ehFeedback error : received buffer has bad checksum16(LSB)\n');
        status = -1;
        return;
    end


    if ( calculateChecksum8(receiveMessage) ~= receiveMessage(1) )
        printf('ehFeedback error : read buffer has bad checksum8\n');
        status = -1;
        return;
    end
        
        
    
    
    
    
    if (LABJACKstruct.openDeviceProductID == LABJACKstruct.U6_PRODUCT_ID)

        if ( (receiveMessage(2) ~= uint8(hex2dec('F8')) ) || (receiveMessage(4) ~= uint8(hex2dec('00')) ) ) 
            printf('ehFeedback error :  read buffer has wrong command bytes\n');
            status = -1;
            return;
        end
        
    else
        
        if ( (receiveMessage(2) ~= uint8(hex2dec('F8')) ) || (receiveMessage(3) ~= uint8(hex2dec('1D')) ) || (receiveMessage(4) ~= uint8(hex2dec('00')) ) ) 
            printf('ehFeedback error :  read buffer has wrong command bytes\n');
            status = -1;
            return;
        end
    
        
    end
    
    
    
    
    
    
    
end