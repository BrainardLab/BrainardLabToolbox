%
% Class definition file for LabJackU6.
% Provides an interface to communicate with LabJack U6 DAQ devices
% 
% July 22, 2013     npc    Wrote it . 
%                          Currently, only basic Analog functionality is implemented
%

classdef LabJackU6 < handle
    
    properties
        data
        
    end
    
    % Private properties
    properties (SetAccess = private)
       % What LabJackDevice to use, here only U6
       deviceID = 6; 
       
       % which device to open
       activeDeviceIndex = 1;
       
       className;
       
       % list of library functions
       libraryFunctionsList;
       
       % Library Version
	   libraryVersion;
		
       % attached devices
       devCount;
                    
       % flag indicating whether the object has been initialized
       isInitialized = false;
       
       % flag indicating whether the analog input streaming was configured
       % successfully
       analogInputStreamingConfiguredOK = false;
       
       % flag indicating whether we are currently streaming data
       isStreaming = false;
       
       % The IDs of the analog channels we are acquiring data from
       analogChannelIDs;
       
    end

    properties (Access = private)
        headerLocation  = '/usr/local/include/labjackusb.h'
        libraryLocation = '/usr/local/lib/liblabjackusb'
        
        % handle to the open LabJack device
        deviceHandle = [];
        
        calibrationStruct;
        inputRange;
        samplesPerPacket;
        % streaming buffer
        bytesIn=zeros(64,1);    
    end
    
    properties (Constant)
        % fixed commands
        startStreamingCommand = hex2dec(['A8';'A8']);
        stopStreamingCommand  = hex2dec(['B0';'B0']);
    end
    
    % Public methods
    methods
        % Constructor
        function self = LabJackU6(varagin)
            self.className = class(self);
            self.openDevice();
        end
        
        % Method to reset the LabJack
        % (manual 5.2.11)
        function reset(self, resetType)
            if nargin < 2, resetType=0; end
			cmd = zeros(4,1);
			cmd(2) = hex2dec('99');
            switch resetType
                case {0,'soft','SOFT'}
                    cmd(3) = bin2dec('01');
                case {1,'hard','HARD'}
                    cmd(3) = bin2dec('10');
            end
            
			% send command
			cmd = addChecksum(cmd);			
			self.usbWrite(cmd);
            
            % read response
			resp  = self.usbRead(4);
            if resp(4) > 0
                fprintf('LabJack reset returned error %d\n',resp(4));
            else
                self.analogChannelIDs = [];
                fprintf('LabJack device was successfully reset\n');
            end
        end
        
        % Method to read the streaming data
        function [data, errorCode] = getStreamData(self)
            if (self.analogInputStreamingConfiguredOK)
                
                count = length(self.bytesIn);
                [in3, ~, self.bytesIn] =  calllib('liblabjackusb', 'LJUSB_Stream', self.deviceHandle, self.bytesIn, count);
 
                % get key values from packet
                numSamples   = double(self.bytesIn(3))-4;  % number of samples (from samplesPerPacket)
                packetNumber = self.bytesIn(11);           % packet counter, 0-255 (8-bit)
                backlog      = self.bytesIn(end-1);        % 0-255 indicates bytes remaining in buffer
                errorCode    = self.bytesIn(12);
                dataBytes    = double(self.bytesIn(13:end-2));
                
                %fprintf('packet %d contains %d/%d samples\n', packetNumber, numSamples, length(self.bytesIn(13:end-2))/2);
                %fprintf('packet size: %d/%d bytes\n', length(self.bytesIn),in3);
                %fprintf('backlog: %.1f%% (%d) (error %d)\n',double(backlog)/255*100, backlog, errorCode); 
                
                if all(errorCode~=[0 59])
                    fprintf(1,'Device returns error %d on stream read (%d)\n',errorCode, packetNumber);
                end
                
                if errorCode==59
                    fprintf(1,'WARNING: In auto-recovery mode. Data has been lost.\n');
                end  
                
                % read additional packets if there is data remaining in buffer
                m = 1; % count number of packets read
                while backlog > 0
                    m = m+1; 
                    [in3, ~, self.bytesIn] =  calllib('liblabjackusb', 'LJUSB_Stream', self.deviceHandle, self.bytesIn, count);
                    numSamples   = double(self.bytesIn(3))-4;     % number of samples (from samplesPerPacket)
                    packetNumber = self.bytesIn(11);               % packet counter, 0-255 (8-bit)
                    backlog      = self.bytesIn(end-1);                 % 0-255 indicates bytes remaining in buffer
                    errorCode    = max(errorCode, self.bytesIn(12));
                    
                    %fprintf('Additional stream read %d\n\n',m);
                    %fprintf('Packet %d contains %d samples\n',packetNumber, numSamples);
                    %fprintf('Packet size: %d/%d bytes\n', length(self.bytesIn), in3);
                    %fprintf('(m %d) backlog: %.1f%% (%d) (error %d)\n',m,double(backlog)/255*100,backlog,errorCode);
                    
                    dataBytes((m-1)*self.samplesPerPacket*2+1:m*self.samplesPerPacket*2) = double(self.bytesIn(13:end-2));
                    
                    if all(errorCode~=[0 59])
                        fprintf(1,'Device returns error %d on stream read\n',errorCode);
                    end
                    
                    if m>=255
                        fprintf('WARNING: unable to keep up with data stream rate!\n');
                        break
                    end
                end  % while backlog
                    
                % interpret the 16-bit data values
                % (manual 5.4: "Binary readings are always unsigned integers")
                dataBytes16 = dataBytes(1:m*self.samplesPerPacket*2);
                dataBytes16(2:2:end) = dataBytes16(2:2:end)*256;
                data = dataBytes16(1:2:end)+dataBytes16(2:2:end);
                
                if length(data)~=numSamples*m
                    fprintf('WARNING: number of samples read (%d) does not agree with packet info (%d)\n',length(data),numSamples*m);
                end
                
                % data is returned in a column for each channel
                numChannelsScan = length(self.analogChannelIDs);
                data = reshape(data, numChannelsScan,[])';
                
                % Finally apply calibration
                % -- Precision cal
                for k=1:numChannelsScan
                    indices         = data(:,k) < self.calibrationStruct.AIN(4,self.inputRange(k)+1);
                    scaleFactor     = self.calibrationStruct.AIN(3,self.inputRange(k)+1);
                    data(indices,k) = (self.calibrationStruct.AIN(4, self.inputRange(k)+1) - data(indices,k)) .* scaleFactor;
                    
                    indices         = data(:,k) >= self.calibrationStruct.AIN(4,self.inputRange(k)+1);
                    scaleFactor     = self.calibrationStruct.AIN(1, self.inputRange(k)+1);
                    data(indices,k) =-(self.calibrationStruct.AIN(4, self.inputRange(k)+1) - data(indices,k)) .* scaleFactor;
                end  
                
            else
                fprintf('LabJack has not configured for streaming yet\n');
            end
        end
        
        
        % Method to start streaming analog input data
        function errorCode = startStreaming(self)
            if (self.analogInputStreamingConfiguredOK)
                
                if (self.isStreaming)
                    fprintf('LabJack is already streaming yet\n');
                else
                    % send streaming command
                    self.usbWrite(self.startStreamingCommand);

                    % read response
                    in = self.usbRead(4);

                    % validate response checksums
                    errorCode=in(3);
                    if errorCode == 0
                        fprintf('Streaming started\n');
                        self.isStreaming = true ;
                    else
                        fprintf('Error during startStream (%d)\n',errorCode);
                        self.isStreaming = false;
                    end     
                end
                
            else
                fprintf('LabJack has not configured for streaming yet\n');
            end
        end
        
        
        % Method to terminate data streaming
        function errorCode = stopStreaming(self)
            
            if (self.analogInputStreamingConfiguredOK && self.isStreaming)
                % send command
                self.usbWrite(self.stopStreamingCommand);
                
                % read response
                in = self.usbRead(4);
                
                % validate response checksums
                errorCode = in(3);
                if errorCode == 0
                    fprintf('Streaming stopped\n');
                    self.isStreaming = false;
                else
                    fprintf('Error during stopStream (%d)\n',errorCode);
                end                
            end
            
        end
        
        
        % Method to prepare LabJack for streaming analog data
        function errorCode = configureAnalogDataStream(self, analogChannelIDs, samplingRateInHz)
            
            disp('Analog channel IDs');
            
            numChannels = length(analogChannelIDs);
            self.analogChannelIDs = analogChannelIDs;
            
            self.samplesPerPacket = 24;
            self.bytesIn = zeros(14 + self.samplesPerPacket*2,1);
            
            % configure analog input type and voltage range
            inputBipolar    = zeros(1,numChannels); % 0= single ended, 1= differential
            self.inputRange = zeros(1,numChannels); % 0=+/- 10 V, 1=+/- 1 V, 2=+/- 0.1 V, 3=+/- 0.01 V
            
            % configure the stream clock. 4 MHz based rate, divided by Scan Interval. 
            if samplingRateInHz < 0.25
                fprintf(1,'LJU6/streamConfigure: ERROR Sample rate minimum is 0.25 Hz. (%g)\n',obj.SampleRateHz);
                return;
            elseif samplingRateInHz < 100
                scanInt = min(65535,round(4e6/256/samplingRateInHz));
                clockBit=2; % divide by 256 for very slow scan rates
            else
                scanInt = min(65535,round(4e6/samplingRateInHz));
                clockBit=0;
            end
            
            % resolution level (0-8 is 16-bit, 9-12 is 24-bit)
            resolutionADC = 1;
        
            commandBytes = zeros(14,1, 'uint8');
            commandBytes(2)  = 248;           % extended command code 0xF8
            commandBytes(3)  = numChannels+4; % NumChannels + 4
            commandBytes(4)  = 17;            % configure command code 0x11
            commandBytes(7)  = numChannels;  
            commandBytes(8)  = resolutionADC; % Resolution Index (1-8, + 9-12 for U6 Pro)
            commandBytes(9)  = self.samplesPerPacket; % SamplesPerPacket (1-25)
            commandBytes(10) = 0;               % reserved
            commandBytes(11) = 0;               % SettlingFactor (use 0 for auto set)
            commandBytes(12) = clockBit;        % ScanConfig (0 = 4MHz clock)
            commandBytes(13) = bitand(scanInt,255); % Scan Interval (low byte)
            commandBytes(14) = uint8(floor(scanInt/256)); % Scan Interval (high byte)
            
            for k=0:1:numChannels-1
                % channel number
                commandBytes(15+k*2) = analogChannelIDs(k+1);
                % set gain and differential (bit 7 and bits 4-5)
                commandBytes(15+k*2+1) = (inputBipolar(k+1)*64 + self.inputRange(k+1)*8);
            end
            
            disp('Stream config command BEFORE checksums');
            disp(commandBytes);
            
            % do checksums
            commandBytes = addChecksum(commandBytes);
            
            disp('Stream config command after checksums');
            disp(commandBytes);
            
            % send command
            self.usbWrite(commandBytes);
            
            % read response
            in = self.usbRead(8);
            
            % validate response checksums
            isValid = validateChecksum(in);
            
            if isValid
                errorCode = in(7);
                if errorCode == 0
                    self.analogInputStreamingConfiguredOK = true;
                else
                    fprintf(1,'configureAnalogDataStream returned error %d\n',errorCode);
                    self.analogInputStreamingConfiguredOK = false;
                end
            else
                fprintf(1,'configureAnalogDataStream: WARNING response checksum not valid. Try again.\n');
                self.analogInputStreamingConfiguredOK = false;
            end
            
        end
        
        
        % shutdown LabJack object 
        function shutdown(self)
           if (self.isInitialized)
               calllib('liblabjackusb','LJUSB_CloseDevice', self.deviceHandle);
               self.deviceHandle = [];
               self.isInitialized = false;
               fprintf('Ciao bambino ...\n');
           else
              fprintf('LabJack object has not yet been initialized\n'); 
           end
        end
        
        function displayAvailableFunctions(self)
            fprintf('Available functions\n');
            for index = 1:numel(self.libraryFunctionsList)
                fprintf('%2d : %s\n', index, self.libraryFunctionsList{index});
            end
        end
        
    end
    
    methods (Access = private)
        % Initialize the LabJack device and make sure we have a valid
        % handle
        function openDevice(self)
            if ~libisloaded('liblabjackusb')
                try 
                    % load the LabJack exodriver
                    loadlibrary(self.libraryLocation, self.headerLocation);
                    self.libraryVersion = calllib('liblabjackusb','LJUSB_GetLibraryVersion');
                    fprintf('Loaded the LabJack exodriver. Version %s\n', self.libraryVersion);
                catch error
                    fprintf('Failed to load the LabJack exodriver\n');
                    fprintf('Error message: %s\n', error.message);
                    return;
                end
            end
            
            % store the raw lib functions
            self.libraryFunctionsList = libfunctions('liblabjackusb', '-full');
			self.devCount       = calllib('liblabjackusb','LJUSB_GetDevCount', self.deviceID);
            fprintf('LabJack devices connected: %d\n', self.devCount);
            self.deviceHandle   = calllib('liblabjackusb','LJUSB_OpenDevice', self.activeDeviceIndex, 0, self.deviceID);
            if calllib('liblabjackusb','LJUSB_IsHandleValid',self.deviceHandle)
               self.calibrationStruct = self.getDeviceCalibration;
               self.isInitialized  = true;
            else
               beep();
               pause(0.1);
               fprintf('LabJack device handle is not valid.\n');
               beep();
               pause(0.1);
               fprintf('Is the actual device connected to the computer?\n');
               beep();
               pause(0.1);
               self.isInitialized  = false; 
               % close labjack
               calllib('liblabjackusb','LJUSB_CloseDevice', self.deviceHandle);
            end
        end
        
        % Method to read the device's calibration data
        function calibrationStruct = getDeviceCalibration(self)
            % read AIN values
            calValArray = zeros(4,4); 
            m = 0;
            for k = 0:3
                m = m+1;
                block = self.readCalMem(k);
                for n = 1:4
                    calValArray(n,m) = fp2double(block((n-1)*8+1:n*8));
                end
            end
            
            calValArray = reshape(calValArray,2,8);
            % each column will have the values for a gain setting
            calibrationStruct.AIN = [calValArray(:,1:4); calValArray(:,5:8)];
            
            % read MISC values ("Misc")
            calValArray = zeros(4,2); m=0;
            for k = 4:5
                m = m+1;
                block = self.readCalMem(k);
                for n=1:4
                    calValArray(n,m) = fp2double(block((n-1)*8+1:n*8));
                end
            end
            calValArray = reshape(calValArray,2,4);
            % each column will have the values for a output device            
            calibrationStruct.MISC = calValArray;

            % read HI-RES values (For U6 Pro)
            calValArray = zeros(4,4); m=0;
            for k = 6:9
                m = m+1;
                block = self.readCalMem(k);
                for n=1:4
                    calValArray(n,m) = fp2double(block((n-1)*8+1:n*8));
                end
            end
            calValArray = reshape(calValArray,2,8);
            % each column will have the values for a gain setting
            calibrationStruct.HIRES=[calValArray(:,1:4); calValArray(:,5:8)];
            
        end
        
        % Returns a block from the non-volatile memory (calibration).
        % Designed for reading calibration data (manual 5.2.6)
        function block = readCalMem(self,BlockNum)
            cmdReadMem=zeros(8,1);
            cmdReadMem(2)= 248; % extended command code 0xF8
            cmdReadMem(3)= 1;
            cmdReadMem(4)= 45; % 0x2D
            cmdReadMem(7)= 0;
            cmdReadMem(8)= BlockNum;
            cmdReadMem = addChecksum(cmdReadMem);
            % send command
            self.usbWrite(cmdReadMem);
            % read response
            in = self.usbRead(40);
            % VALIDATE RESPONSE
            if in(7)>0
                fprintf(1,'Block read error %d\n',in(7));
            end
            % return individual bytes
            block = uint8(in(9:40));
            %block = in(9:40);
        end
        
   
        
        % Method to write a command to the LabJack device
        function out = usbWrite(self, commandBytes)
            out = calllib('liblabjackusb', 'LJUSB_Write', self.deviceHandle, commandBytes, length(commandBytes));
            if isequal(out,0)
                fprintf(1,'labJackU6: Error on write to device! (zero bytes written)\n');
            elseif isequal(out,-1)
                fprintf(1,'labJackU6: Error on write to device! (error -1)\n');                
            else
                fprintf(1,'LJU6/usbWrite: %d bytes written to device.\n',out);
            end      
        end
        
        % Method to read a response from the LabJack device
        function responseBytes = usbRead(self, count)
            responseBytes = zeros(count,1);
            [in3, ~, responseBytes] = calllib('liblabjackusb', 'LJUSB_Read', self.deviceHandle, responseBytes, count);
            % detect bad count value
            if in3 == 0
                fprintf(1,'LJU6/usbRead: WARNING bad count value (num bytes in==0) detected\n');
            end
            % detect bad checksum response
            if all(responseBytes(1:2) == 184)
                fprintf(1,'LJU6/usbRead: WARNING bad command checksum detected\n');
                responseBytes=-1;
            else
                fprintf(1,'LJU6/usbRead: %d bytes read from device\n',in3);
                disp(responseBytes');
            end
        end
        
    end
    
end


% calculate the checksums for an outgoing packet
% calculates the appropriate addChecksum based on byte #2
% COMMANDBYTES is an array of byte values
function commandBytes = addChecksum(commandBytes)
    if commandBytes(2) >= 248 % extended command
       [commandBytes(5),commandBytes(6)] = checksum16(commandBytes(7:end));
       commandBytes(1) = checksum8(commandBytes(2:6));
    else %"normal" command
       commandBytes(1) = checksum8(commandBytes(2:end));
    end
end
        
function isChecked = validateChecksum(responseBytes)
    if responseBytes(2) >= 248 % extended command
        [chk16(1),chk16(2)] = checksum16(responseBytes(7:end));
        chk8(1) = checksum8(responseBytes(2:6));
        if responseBytes(5)== chk16(1) && responseBytes(6)==chk16(2) && responseBytes(1)==chk8(1)
           isChecked=1;
        else
           isChecked=0;
        end
    else %"normal" command
        chk8(1) = checksum8(responseBytes(2:end));
        if responseBytes(1) == chk8(1)
           isChecked=1;
        else
           isChecked=0;
        end               
    end                
        
end
        
% Calculate single-byte addChecksum for LJ data packet
function chk = checksum8(in)
    in   = sum(uint16(in));
    quo  = floor(in/2^8);
    remd = rem(in,2^8);
    in   = quo+remd;
    quo  = floor(in/2^8);
    remd = rem(in,2^8);
    chk  = quo + remd;
end
		


% Calculate double-byte addChecksum for LJ data packet
function [lsb,msb] = checksum16(in)
    in  = sum(uint16(in));
    lsb = bitand(in,255);
    msb = bitshift(in,-8);
end
        
        
% Fixed-point conversion
% convert fixed-point calibration values
% (see manual 5.4 and FPuint8ArrayToFPDouble in u6.c)
function out = fp2double(in)
    in = uint32(in);
            
    % assemble the whole number from high order bytes
    wholeNum = bitor(in(5),bitshift(in(6),8));
    wholeNum = bitor(wholeNum,bitshift(in(7),16));
    wholeNum = bitor(wholeNum,bitshift(in(8),24));
    wholeNum = typecast(uint32(wholeNum),'int32'); % to handle negative values
            
    % assemble the fractional value from low order bytes
    fractNum = bitor(in(1),bitshift(in(2),8));
    fractNum = bitor(fractNum,bitshift(in(3),16));
    fractNum = bitor(fractNum,bitshift(in(4),24));
            
    % assemble the complete value
    out = double(wholeNum)+double(fractNum)/4294967296;
end
        
