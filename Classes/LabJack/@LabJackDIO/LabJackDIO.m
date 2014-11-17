%
% Class definition file for LabJackUE9.
% Provides an interface to communicate with LabJack UE9/U6 DIOdevices
% 
% July 22, 2013     npc    Wrote it . 
%                          Currently, only basic DIO functionality is implemented
%

classdef LabJackDIO < handle
    
    % Public properties
    properties
        
    end  % Public properties
    
    % Private properties
    properties (SetAccess = private)
        
        % pointer to open device
        devicePointer = nan;
        
        % product ID of open device
        deviceProductID = nan;
        
        % Boolean indicating whether we have a valid pointer to a UE9 device
        devicePointerIsValid = false;
        
        % Bollean indicating whether the device has been successfully
        % configured
        deviceIsConfigured = false;
        
        % Boolean indicating whether we have a valid DIO configuration
        DIOconfigurationIsGood = false;
        
    end % Private properties
    
    properties (Constant)
        UE9 = 9;
        U6  = 6;
        
        % DIO linelabel    channelID
        FIO_0            = 7;   
        FIO_1            = 6;
        FIO_2            = 5;
        FIO_3            = 4;
        FIO_4            = 3;   
        FIO_5            = 2;
        FIO_6            = 1;
        FIO_7            = 0;
        
        EIO_0            = 15;   
        EIO_1            = 14;
        EIO_2            = 13;
        EIO_3            = 12;
        EIO_4            = 11;   
        EIO_5            = 10;
        EIO_6            = 9;
        EIO_7            = 9;
    
        % DIO direction
        INPUT            = 0;
        OUTPUT           = 1;
    end  % Constant properties
    
    % Public methods
    methods
        % Constructor
        function self = LabJackDIO(varargin)
            if (~self.devicePointerIsValid)
                % We do not have a valid device pointer, so open LabJack
                self.openLabJackDevice();
            end
        end % Constructor
        
        % Method to set the state of any of the 16 DIO lines
        function status = setLines(self, channelIDs, channelStates)
            states = zeros(1,16);
            states(channelIDs+1) = channelStates;
    
            status = self.setDigitalLines([0:15], states);
            if (status ~= 0)
                disp('>>>> setAllChannelsToZero failed. Exiting now.');
                ljOBJ.closeDevice();
            end    
        end
 
        % Method to configure the channels to use and their direction (INPUT/OUTPUT)
        function configureDIOchannels(self, varargin)
            % unload input
            channelsToConfigure = length(varargin)/2;
            if (length(varargin) ~= 2*channelsToConfigure)
                disp('Incorrect number of arguments in configureDIOchannels. Each channel must be paired with a DIO direction spec');
                self.DIOconfigurationIsGood = false;
            else
                % configure command
                sendDataMessage = zeros(2*channelsToConfigure,1, 'uint8');
                disp('Will configure ...');
                for k = 1:channelsToConfigure
                    channelID  = varargin{(k-1)*2 + 1};
                    channelDIR = varargin{(k-1)*2 + 2};
                    if (channelDIR == LabJackDIO.INPUT)
                        fprintf('channel %d for INPUT\n', channelID);
                    else
                        fprintf('channel %d for OUTPUT\n', channelID);
                    end 
                    
                    sendDataMessage(1 + 2*(k-1))  = 13;                           % IOType if BitDirWrite
                    sendDataMessage(2 + 2*(k-1))  = channelID + 128*channelDIR;   % IONumber(bits 0-4) is channelID + Direction (bit 7): 1 write, 0: read
                end  % for k
                
                % send command
                status = self.sendLowLevelCommand(sendDataMessage);
                if (status == 0)
                    self.DIOconfigurationIsGood = true;
                else
                    self.DIOconfigurationIsGood = false;
                end
            end
            
        end
        
        % Method to close the LabJack device
        function closeDevice(self)
            if (self.devicePointerIsValid)
                calllib('liblabjackusb', 'LJUSB_CloseDevice', self.devicePointer);
                disp('Closed LabJack');
                self.devicePointerIsValid = false;
                self.devicePointer   = nan; 
                self.deviceProductID = nan;
            end
        end
        
    end  % Public methods
    
    % Private methods
    methods (Access = private)
        
        % Method to open LabJack device.
        % Note: must do the following chmod changes
        % sudo chmod 755 /usr/local/include
        % sudo chmod 755 /usr/local/lib
        % Read /usr/local/include/labjackusb.h for more info
        function openLabJackDevice(self)
            % Load labjackusb library
            if (libisloaded('liblabjackusb') == 0)
                disp('Loading LABJACK USB Library ...');
                header  = '/usr/local/include/labjackusb.h';
                loadlibrary('/usr/local/lib/liblabjackusb',header);
                disp('Loaded libjacklabusb library !');
                %libfunctionsview liblabjackusb
            else
               disp('Library libjacklabusb is already loaded'); 
            end
            
            % Check what device is connected (U6 or UE9)
            productID       = LabJackDIO.U6;
            deviceNumber    = 1;  % first device found
            reservedNumber  = 0;  % always 0
            disp('Checking whether a U6 device is connected ...'); 
            
            self.devicePointer = libpointer('voidPtr');
            self.devicePointer = calllib('liblabjackusb', 'LJUSB_OpenDevice', deviceNumber, reservedNumber, productID);
            [self.devicePointerIsValid, voidPointer] = calllib('liblabjackusb', 'LJUSB_IsHandleValid', self.devicePointer);
            
            if (~self.devicePointerIsValid)
                disp('Did not detect a U6 device, will check for a UE9 device ...');
                productID = LabJackDIO.UE9;
                self.devicePointer = calllib('liblabjackusb', 'LJUSB_OpenDevice', deviceNumber, reservedNumber, productID);
                [self.devicePointerIsValid, voidPointer] = calllib('liblabjackusb', 'LJUSB_IsHandleValid', self.devicePointer);
                if (~self.devicePointerIsValid)
                    disp('Did not detect any connected LabJack devices');
                    self.deviceIsConfigured = false;
                else
                    disp('Detected a UE9 device !'); 
                    self.deviceProductID = productID;
                    self.deviceIsConfigured = self.configDevice();
                end
            else
               disp('Detected a U6 device !'); 
               self.deviceProductID = productID;
               self.deviceIsConfigured = self.configDevice();
            end
        end % openLabJackDevice
        
        % Method to configure command for setting the digital lines
        function status = setDigitalLines(self,channelIDs, bitStates)
            % configure command
            sendDataMessage = zeros(2*length(channelIDs),1, 'uint8');
            indices = 1+2*[0:length(channelIDs)-1];
            sendDataMessage(indices)    = 11;              % IOType is BitStateWrite
            sendDataMessage(indices+1)  = channelIDs + 128*bitStates;
            
            % send command
            status = self.sendLowLevelCommand(sendDataMessage);
        end
        
        % Method to send a low-level command to the LabJack
        function status = sendLowLevelCommand(self, dataMessage)
            status = 0;
            
            if (self.deviceProductID == LabJackDIO.U6)
                % U6-specific commands
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
        
                % Generate sendMessage
                sendMessage    = zeros(sendMessageLength, 1, 'uint8');
                sendMessage(2) = uint8(hex2dec('F8'));   % Command byte
                sendMessage(3) = uint8(sendDWSize/2);    % Number of data words (.5 word for echo, 1.5 words for IOTypes)
                sendMessage(4) = uint8(hex2dec('00'));   % Extended command number
                sendMessage(7) = 0;                      % Echo
                indices = 1:length(dataMessage);
                sendMessage(indices+commandBytes+1) = dataMessage(indices);
                sendMessage(sendMessageLength) = 0;
        
                % Calculate and set the checksum16
                checksum16     = calculateChecksum16(sendMessage,sendMessageLength);
                sendMessage(5) = uint8(bitand(checksum16, hex2dec('FF')));
                sendMessage(6) = uint8(bitand(bitshift(checksum16,-8), hex2dec('FF')));
    
                % Calculate and set the checksum8
                sendMessage(1) = calculateChecksum8(sendMessage);
            else
                % UE9-specific commands
                sendMessageLength       = 34;
                receiveMessageLength    = 64;
        
                sendMessage    = zeros(1, sendMessageLength, 'uint8');
                sendMessage(2) = uint8(hex2dec('F8'));   % Command byte
                sendMessage(3) = uint8(hex2dec('0E'));   % Number of data words 
                sendMessage(4) = uint8(hex2dec('00'));   % Extended command number
                
                DIOchannelsNum  = length(dataMessage)/2;
                states          = zeros(1, DIOchannelsNum, 'uint8');
                channelIDs      = zeros(1, DIOchannelsNum, 'uint8');
        
                for channelIndex = 1:DIOchannelsNum
                    % ignore the odd number bytes sendDataMessage(1 + 2*(channelIndex-1))  = 13;
                    evenByteNumber = dataMessage(2 + 2*(channelIndex-1));
                    states(channelIndex)      = floor(evenByteNumber/128);  % 1 or 0
                    channelIDs(channelIndex)  = evenByteNumber - states(channelIndex)*128;
                end  % for channelIndex
        
                multiplier = uint8(2.^[7:-1:0]);
                sendMessage(7) = uint8(hex2dec('FF'));   % all FIOs
                sendMessage(8) = uint8(hex2dec('FF'));   % all FIOs are output channels
                sendMessage(9) = uint8(sum(states(1:8) .* multiplier));

                sendMessage(10) = uint8(hex2dec('FF'));   % all EIOs
                sendMessage(11) = uint8(hex2dec('FF'));   % all EIOs are output channels
                sendMessage(12) = uint8(sum(states(9:16) .* multiplier));
        
                % Calculate and set the checksum16
                checksum16          = calculateChecksum16(sendMessage,sendMessageLength);
                sendMessage(5)      = uint8(bitand(checksum16, hex2dec('FF')));
                sendMessage(6)      = uint8(bitand(bitshift(checksum16,-8), hex2dec('FF')));

                % Calculate and set the checksum8
                sendMessage(1)      = calculateChecksum8(sendMessage);
            end
            
            % Send the command
            sendBuffer   = libpointer('uint8Ptr', sendMessage);
            bytesWritten = calllib('liblabjackusb', 'LJUSB_Write', self.devicePointer , sendBuffer, sendMessageLength);
    
            if (bytesWritten ~= sendMessageLength)
                disp('An error occurred while trying to write to the Device.');
                status = -1;
                return;
            end
    
            % Read the result from the device.
            receiveMessage  = zeros(receiveMessageLength, 1, 'uint8');
            receiveBuffer   = libpointer('uint8Ptr', receiveMessage);
    
            bytesRead       = calllib('liblabjackusb', 'LJUSB_Read', self.devicePointer, receiveBuffer, receiveMessageLength);
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
    
            if (self.deviceProductID == LabJackDIO.U6)
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
        end % sendLowLevelCommand
        
        
        function statusIsGood = configDevice(self)
            if (~self.devicePointerIsValid)
                disp('LABJACK device pointer is not valid. ConfigDevice will not execute');
                statusIsGood  = false;
                return;
            end
            
            responseLength = 38;
            configMessage = [];
            commandLength = 0;
            if (self.deviceProductID == self.UE9)
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
    
            % Send config command
            sendBuffer          = libpointer('uint8Ptr', configMessage);
            bytesWritten        = calllib('liblabjackusb', 'LJUSB_Write', self.devicePointer , sendBuffer, commandLength);
    
            % Check for a successfull write
            if (bytesWritten ~= commandLength)
                disp('An error occurred while trying to write to the Device.');
                statusIsGood  = false;
                return;
            end
    
            % Read the result from the device.
            receiveMessage  = zeros(responseLength, 1, 'uint8');
            receiveBuffer   = libpointer('uint8Ptr', receiveMessage);
   
            % Check for a successful read
            bytesRead = calllib('liblabjackusb', 'LJUSB_Read', self.devicePointer, receiveBuffer, responseLength);
            if( bytesRead ~= responseLength) 
                disp('An error occurred while trying to read from the Device.');
                statusIsGood  = false;
                return;
            end
    
            receiveMessage = get(receiveBuffer, 'value');
            
            if (checkResponseForErrors(receiveMessage) == -1)
                disp('An error exists in the response from the Device.');
                statusIsGood  = false;
                return;
            else
                % Printe results of config command
                if (self.deviceProductID == LabJackDIO.U6)
                    fprintf('  FirmwareVersion = %d.%02d\n', receiveMessage(11), receiveMessage(10));
                    fprintf('  BootloaderVersion = %d.%02d\n', receiveMessage(13), receiveMessage(12));
                    fprintf('  HardwareVersion = %d.%02d\n', receiveMessage(15), receiveMessage(14)); 
                    fprintf('  SerialNumber = %d\n', makeInt(receiveMessage, 16));
                    fprintf('  ProductID = %d\n', makeShort(receiveMessage, 20));
                    fprintf('  LocalID = %d\n', receiveMessage(22));
                    fprintf('  VersionInfo = %d\n', receiveMessage(38));
                    if (receiveMessage(38) == 4)
                        fprintf('  DeviceName = U6\n');
                    elseif(receiveMessage(38) == 12) 
                        printf('  DeviceName = U6-Pro\n');
                    end
                else
                    serialBytes = zeros(1,4, 'uint8');
                    serialBytes(1) = receiveMessage(29);
                    serialBytes(2) = receiveMessage(30);
                    serialBytes(3) = receiveMessage(31);
                    serialBytes(4) = uint8(hex2dec('10'));
                    fprintf('  FirmwareVersion = %d.%02d\n', receiveMessage(38), receiveMessage(37));
                    fprintf('  HardwareVersion = %d.%02d\n', receiveMessage(36), receiveMessage(35));
                    fprintf('  SerialNumber = %d\n', makeInt(serialBytes, 1));
                    fprintf('  ProductID = %d\n', makeShort(receiveMessage, 28));
                    fprintf('  LocalID = %d\n', receiveMessage(9));
                    fprintf('  PowerLevel = %d\n', receiveMessage(10));
                    fprintf('  DeviceName = UE9\n');
                end
                statusIsGood  = true;
            end
        end  % configDevice
        
    end  % Private methods
end


% Helper functions
function status = checkResponseForErrors(receiveMessage)
    status = 0;
    if (receiveMessage(7) ~= 0 )
        % Check the error code in the packet. See section 5.3 of the U6
        % User's Guide for errorcode descriptions.
        disp(sprintf('Command returned with an errorcode = %d', receiveMessage(7)));
        status = -1;
        return;
    end
    
    if ((receiveMessage(1) == hex2dec('B8')) && (receiveMessage(2) == hex2dec('B8'))) 
       disp('Error in checksums');
       status = -1;
       return;
   %elseif ((receiveMessage(2) == hex2dec('F8')) && (receiveMessage(3) == hex2dec('10')) && (receiveMessage(4) == hex2dec('08'))) 
   % 
   %     disp('Got the wrong command bytes back from the Device');
   %     status = -1;
   %     return;    
    end
end

function integerNumber = makeInt(buffer, offset)
    integerNumber = bitshift(uint32(buffer(offset+3)), 24) + bitshift(uint32(buffer(offset+2)), 16) + bitshift(uint32(buffer(offset+1)), 8) + uint32(buffer(offset));    
end

function shortInteger = makeShort(buffer, offset)
    shortInteger = bitshift(uint32(buffer(offset+1)), 8) + uint32(buffer(offset));
end

function checksum16 = calculateChecksum16(buffer, n)
    uint16buffer = uint16(buffer);
    checksum16   = sum(uint16buffer(7:n));
end

function checksum8 = calculateChecksum8(buffer)
    uint16buffer = uint16(buffer);
    checksum8   = sum(uint16buffer(2:6));
    temp        = bitshift(checksum8,-8);
    checksum8   = (checksum8 - 256 * temp ) + temp;
    temp        = uint16(bitshift(checksum8,-8));
    checksum8   = uint8( (checksum8 - 256 * temp) + temp );
end

