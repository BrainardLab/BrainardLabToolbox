function status = openLabJack

    disp('in openLabJack')
    
    % must do the following chmod changes
    % sudo chmod 755 /usr/local/include
    % sudo chmod 755 /usr/local/lib
    
    
    % Read /usr/local/include/labjackusb.h for more info
    %
    %
    
    if (libisloaded('liblabjackusb') == 0)
        disp('Loading LABJACK USB Library');
        header  = '/usr/local/include/labjackusb.h';
        loadlibrary('/usr/local/lib/liblabjackusb',header);
    end
    
    
    %libfunctionsview liblabjackusb
    
    
    
    global LABJACKstruct
    
    
    
    
    % Check to see if a device is already open
        
    if (isfield(LABJACKstruct, 'devicePointerIsValid'))
            
            
       if (LABJACKstruct.devicePointerIsValid)
                
            % Ok, close the device before we open it again
            calllib('liblabjackusb', 'LJUSB_CloseDevice', LABJACKstruct.devicePointer);
            disp('Closed an open device');
        end
    end
        

    LABJACKstruct = struct;
    
    LABJACKstruct.UE9_PRODUCT_ID = 9;
    LABJACKstruct.U6_PRODUCT_ID  = 6;
    
    
 
    
    out = calllib('liblabjackusb', 'LJUSB_GetLibraryVersion');
    

    
    % FIrst let's check if a U6 device is connected
    productID           = LABJACKstruct.UE9_PRODUCT_ID;
    
    
    deviceNumber        = 1;  % first device found
    reservedNumber      = 0;  % always 0
    
    
    
    LABJACKstruct.devicePointer = libpointer('voidPtr');
    LABJACKstruct.devicePointer = calllib('liblabjackusb', 'LJUSB_OpenDevice', deviceNumber, reservedNumber, productID);
                      
    
    [LABJACKstruct.devicePointerIsValid, voidPointer] = calllib('liblabjackusb', 'LJUSB_IsHandleValid', LABJACKstruct.devicePointer);
    
    if (~LABJACKstruct.devicePointerIsValid)
        
        disp('Did not detect a UE9, checking for a U6 !!');
        
        
        productID = LABJACKstruct.U6_PRODUCT_ID;
        
        LABJACKstruct.devicePointer         = calllib('liblabjackusb', 'LJUSB_OpenDevice', deviceNumber, reservedNumber, productID);
        LABJACKstruct.devicePointerIsValid  = calllib('liblabjackusb', 'LJUSB_IsHandleValid', LABJACKstruct.devicePointer);
    

        if (~LABJACKstruct.devicePointerIsValid)
            
            disp('** Could not detect a LABJACK Device **');
            status = -1;
            return;
          
        else
             disp('Detected a U6 device !!');
        end
    
    else  % valid pointer 
    
        
        disp('Detected a UE9 device !!');
        
    end
    

    LABJACKstruct.openDeviceProductID = productID;
    
    
    status = configDevice;
    
    if (status ~= 0)
        LABJACKstruct.devicePointerIsValid = false;
    end
    
    
    % Finally set all digital lines to output
    status = initializeDIOlines;
    if (status ~= 0)
        LABJACKstruct.devicePointerIsValid = false;
    end
    
end



function status = configDevice
    
    global LABJACKstruct

    
    status = 0;
    
    if (~LABJACKstruct.devicePointerIsValid)
        disp('LABJACK device pointer is not valid. ConfigDevice will not execute');
        status = -1;
        return;
    end
    
    
    responseLength = 38;
     
     
    if (LABJACKstruct.openDeviceProductID == LABJACKstruct.UE9_PRODUCT_ID)
        commandLength = 38;
        configMessage       = zeros(commandLength, 1, 'uint8');
        configMessage(2)    = uint8(hex2dec('78'));
        configMessage(3)    = uint8(hex2dec('10'));
        configMessage(4)    = uint8(hex2dec('01'));
        
    else
        commandLength  = 26;
        configMessage       = zeros(commandLength, 1, 'uint8');
        configMessage(2)    = uint8(hex2dec('F8'));
        configMessage(3)    = uint8(hex2dec('0A'));
        configMessage(4)    = uint8(hex2dec('08'));
    
    end
    
   
    
    
    
    
    % Calculate and set the checksum16
    checksum16          = calculateChecksum16(configMessage, commandLength);
    configMessage(5)    = uint8(bitand(checksum16, hex2dec('FF')));
    configMessage(6)    = uint8(bitand((checksum16 / 256), hex2dec('FF')));
    
    % Calculate and set the checksum8
    configMessage(1)    = calculateChecksum8(configMessage);
    
    
    sendBuffer          = libpointer('uint8Ptr', configMessage);

    bytesWritten        = calllib('liblabjackusb', 'LJUSB_Write', LABJACKstruct.devicePointer , sendBuffer, commandLength);
        
    if (bytesWritten ~= commandLength)
        disp('An error occurred while trying to write to the Device.');
        status = -1;
        return;
    end
    
      
   
    % Read the result from the device.
    
    
    receiveMessage  = zeros(responseLength, 1, 'uint8');
    receiveBuffer   = libpointer('uint8Ptr', receiveMessage);
   
    
    
    bytesRead = calllib('liblabjackusb', 'LJUSB_Read', LABJACKstruct.devicePointer, receiveBuffer, responseLength);
    
    if( bytesRead ~= responseLength) 
        disp('An error occurred while trying to read from the Device.');
        status = -1;
        return;
    end
    
    
    receiveMessage = get(receiveBuffer, 'value');
    
    if (checkResponseForErrors(receiveMessage) == -1)
        disp('An error exists in the response from the Device.');
        status = -1;
        return;
        
    else
        
        parseConfigBytes(receiveMessage);
    end
    
    
    
end




function parseConfigBytes(receiveBuffer)

    global LABJACKstruct
       
    fprintf('Results of Config\n');
    
    if (LABJACKstruct.openDeviceProductID == LABJACKstruct.U6_PRODUCT_ID)
        
        fprintf('  FirmwareVersion = %d.%02d\n', receiveBuffer(11), receiveBuffer(10));
        fprintf('  BootloaderVersion = %d.%02d\n', receiveBuffer(13), receiveBuffer(12)); 
    
        fprintf('  HardwareVersion = %d.%02d\n', receiveBuffer(15), receiveBuffer(14)); 
        fprintf('  SerialNumber = %d\n', makeInt(receiveBuffer, 16));
        fprintf('  ProductID = %d\n', makeShort(receiveBuffer, 20));
    
        fprintf('  LocalID = %d\n', receiveBuffer(22));
        fprintf('  VersionInfo = %d\n', receiveBuffer(38));
    
        if (receiveBuffer(38) == 4)
            fprintf('  DeviceName = U6\n');
        elseif(receiveBuffer(38) == 12) 
            printf('  DeviceName = U6-Pro\n');
        end
        
    
    else
        serialBytes = zeros(1,4, 'uint8');
        serialBytes(1) = receiveBuffer(29);
        serialBytes(2) = receiveBuffer(30);
        serialBytes(3) = receiveBuffer(31);
        serialBytes(4) = uint8(hex2dec('10'));
    
        fprintf('  FirmwareVersion = %d.%02d\n', receiveBuffer(38), receiveBuffer(37));
        fprintf('  HardwareVersion = %d.%02d\n', receiveBuffer(36), receiveBuffer(35));
        fprintf('  SerialNumber = %d\n', makeInt(serialBytes, 1));
        fprintf('  ProductID = %d\n', makeShort(receiveBuffer, 28));
         
        fprintf('  LocalID = %d\n', receiveBuffer(9));
        fprintf('  PowerLevel = %d\n', receiveBuffer(10));
       
        
        fprintf('  DeviceName = UE9\n');
    
    
    end
    
end
        
        
function shortInteger = makeShort(buffer, offset)

    shortInteger = bitshift(uint32(buffer(offset+1)), 8) + uint32(buffer(offset));
    
end



function integerNumber = makeInt(buffer, offset)

    integerNumber = bitshift(uint32(buffer(offset+3)), 24) + bitshift(uint32(buffer(offset+2)), 16) + bitshift(uint32(buffer(offset+1)), 8) + uint32(buffer(offset));
    
end


function status = checkResponseForErrors(receiveBuffer)

    status = 0;


    if (receiveBuffer(7) ~= 0 )
        % Check the error code in the packet. See section 5.3 of the U6
        % User's Guide for errorcode descriptions.
        disp(sprintf('Command returned with an errorcode = %d', receiveBuffer(7)));
        status = -1;
        return;
    end
    
    
    if ((receiveBuffer(1) == hex2dec('B8')) && (receiveBuffer(2) == hex2dec('B8'))) 
    
       disp('Error in checksums');
       status = -1;
       return;
       
    %elseif ((receiveBuffer(2) == hex2dec('F8')) && (receiveBuffer(3) == hex2dec('10')) && (receiveBuffer(4) == hex2dec('08'))) 
   % 
   %     disp('Got the wrong command bytes back from the Device');
   %     status = -1;
   %     return;
           
    end
        
        
    
end





