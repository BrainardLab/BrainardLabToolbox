%LABJACKU6 A class for using the LabJack U6
%
% LBJ = LABJACKU6 constructs an object associated with a LabJack U6.
%
% This class supports the use of the LabJack Exodriver with MATLAB. The
%  Exodriver is designed for OS X and Linux, although in theory it could be
%  used on Windows. For MATLAB on Windows, LabJack recommends using their
%  LabJackUD driver.
%
% Only the Analog IO functions (ADC streaming, ADC read, and DAC set) are 
%  supported in this version.
%
% In order to communicate with the U6, the object must be connected
%  to a LabJack with OPEN. After a connection is opened, the calibration
%  data will be read from the device and stored as the property "CalVals".
%  These calibrations are applied to data that is read from the device, so
%  that the values returned are in calibrated units (Volts / degC). Be sure
%  to destroy the object (use CLEAR) when finished, in order to avoid USB
%  issues. See the Examples section below.
%
% The LabJack U6 Specifications are here:
%   http://labjack.com/u6/specs
% And the User's Guide is here:
%   http://labjack.com/support/u6/users-guide
%
%
%
% Methods:
%  OPEN
%       open(obj,deviceNum)
%   Opens a connection to a LabJack. 
%     DEVICENUM is the localID for the LabJack, beginning with 1.
%       Defaults to 1 (the first device found).
%
%  CLOSE
%       close(obj)
%   Closes a connection to a LabJack.
%
%  GETINFO
%       devInfo = getInfo(obj)
%   Returns device information.
%
%  RESET
%       reset(obj,resetType)
%   Resets the device. RESETTYPE can be 'hard' or 'soft'. Default 'soft'.
%
%  ADDCHANNEL
%       addChannel(obj,channels,gains,polar)
%   Adds analog channels to the channel list for data streaming.
%     CHANNELS is a vector of LJ channel numbers. Example:  [0 1 2]
%     GAINS is a matching vector of channel gains. You can use gain level
%       (0|1|2|3) or +/- input range in Volts (10|1|0.1|0.01)
%     POLAR is a matching vector of settings for single-ended or differential
%       settings for each channel. Use (0|1) or ('s'|'d').
%   Note: For differential sensing, you must add the pair of channels.
%
%  REMOVECHANNEL
%       removeChannel(obj,channel)
%   Removes a single channel from the list of channels. To remove
%    differental channel pairs, use the first channel number only. To
%    remove all channels, use CHANNEL=-1.
%
%  STREAMCONFIGURE
%       errorCode = streamConfigure(obj)
%   Configures the LabJack for analog output streaming with the current
%    channel list. If any errors occur, the LJ will not be ready to stream
%    data.
%
%  STARTSTREAM
%       errorCode = startStream(obj)
%   Start analog input streaming. Must use streamConfigure first.
%
%  STOPSTREAM
%       errorCode = stopStream(obj)
%   Stop analog input streaming.
%
%  GETSTREAMDATA
%       [data errorCode] = getStreamData(obj)
%   Returns analog input streaming data. DATA has one column
%    per analog channel, for a total of obj.numChannels columns
%    (differential channels are combined into a single column). Data is
%    read until the LJ data buffer is empty. If a buffer overflow occurs,
%    the missing data will be replaced by "-9999" values, so that the
%    timing of the data stream will be preserved.
%
%  ANALOGOUT
%       analogOut(obj,channel,voltageSet)
%   Sets the output of a DAC (channel 0 or 1) to VOLTAGESET. DAC outputs
%    are in the range 0 to 5 V.
%
%  ANALOGIN
%       data = analogIn(obj,channel,gain,polarity,resolution)
%   Reads a single value from a ADC channel. Note channel 14 is the
%    internal temperature sensor, and the output will be in deg C.
%
%  ANALOGSCAN
%       data = analogScan(obj,numScans)
%   Performs a "scan" of all the channels in the current channel list.
%    Returns an array of data, one row per scan, one column per channel.
%    Intended for "manual" streaming, e.g. with U6-Pro high resolution ADC.
%
%
% Properties:
%   ResolutionADC - The number of bits of effective resolution. Use 1-8 for
%                   16-bit streaming, and 9-12 for 24-bit resolution single
%                   AIN readings, 0=default. (see LabJAck manual section 3)                
%   SampleRateHz - The sample rate for analog input streaming.
%   CalVals - The calibration values loaded from the device.
%   ExodriverHeader - The path to the Exodriver header file
%   ExodriverLibrary - The path to the Exodriver library file
%   numChannels - the number of channels configured for streaming.
%       Differential paired channels count as 1. The GETSTREAMDATA method
%       returns numChannels columns of data.
%   verbose - The level of messages displayed:
%                   0 (silent) - 3 (debug). Default 1.
%
%
% Example:
%
%  >> lbj=labJackU6; open(lbj);
%  labJackU6: version 1.0
%  LJU6/open: Device successfully opened.
%  >> lbj.SampleRateHz=200;
%  >> addChannel(lbj,[0 1],[10 10],['s' 's']); % add channels 0 & 1, range +/- 10V, single-ended
%  >> streamConfigure(lbj);
%  >> startStream(lbj);
%  LJU6/startStream: Stream started
%
%   [use some sort of loop or timer with:
%        data=getStreamData(lbj);
%    to process data]
% 
%  >> stopStream(lbj);
%  LJU6/stopStream: stream stopped.
%  >> clear lbj
%  LJU6/delete: Closing object
%  LJU6/close: Device successfully closed.
% 
%
% M.A. Hopcroft
% mhopeng@gmail.com
% 

% Aug2012
% v1.1 analogScan for "manual streaming"
% Jul2012
% v1.0 basic functionality for streaming analog in, DAC output set
%

classdef labJackU6 < handle
	
    % Use capital letters for set-able properties, per MATLAB convention
	properties
		% header for LabJack Exodriver
		ExodriverHeader = '/usr/local/include/labjackusb.h';
		% LabJack Exodriver installed library
		ExodriverLibrary = '/usr/local/lib/liblabjackusb';
		% level of messages 
		verbose = 1; % can't bring myself to use capital V here
        % resolution level (0-8 is 16-bit, 9-12 is 24-bit)
        ResolutionADC = 0;
        % desired sample rate for Analog Input
        SampleRateHz = 100
        % Tag
        Tag='LabJackU6';
        % UserData
        UserData
	end
	
	properties (SetAccess = private, GetAccess = public)
        % version of this classdef file
        versionStr = 'version 1.1'
        % The handle for the device
        handle = []
		% The identifier for the model number of the LabJack (6 = U6)
        deviceID = 6;
        % Exodriver version number
		driverVersion
        % number of devices connected to USB
		deviceCount
        % device status
		isOpen = 0;
        isStreamConfig = 0;
        isStreaming = 0;
        samplesPerPacket = 25;
		%command = []
        % Calibration Data
        CalVals
        % The number of channels of analong streaming data
        numChannels
        % analog channels to be used for streaming
        analogChannels
        % input gain for ADC (i.e., input Range) (0,1,2,3 = 1,10,100,1000)
        inputRange
        % bipolar setting (0|1) (default single-ended)
        inputBipolar        
	end
	
	properties (SetAccess = private, GetAccess = private)
		% fixed commands
        cmdStartStream = hex2dec(['A8';'A8']);
        cmdStopStream = hex2dec(['B0';'B0']);
        % command templates
        cmdDACSet = hex2dec(['00'; 'F8'; '02'; '00'; '00'; '00'; '00'; '00'; '00'; '00']); % (5.2.5.16 - DAC# (16-bit): IOType=38,39)
% 		cmdAINsingle = hex2dec(['00'; 'f8'; '02'; '00'; '00'; '00'; '00'; '00'; '00'; '00']);
        % streaming buffer
        bytesIn=zeros(64,1);
        % handle status flag
        isValidHandle = 0
    end
	

    % % % % % % %
    % Public Methods
	methods
                
        %% Constructor
        % return instance of labJackU6 class.
		function obj = labJackU6(varargin)
            if obj.verbose >= 1, fprintf(1,'labJackU6: %s\n',obj.versionStr); end
            if nargin>0
                fprintf(1,'labJackU6: Initial property setting is not supported. (n=%d)\n',nargin);
            end
		end
		

        %% Open
        % Open connection to the LabJack device
		function open(obj,deviceNum)
            if nargin < 2, deviceNum=1; end
            if ~libisloaded('liblabjackusb')
                try
                    loadlibrary(obj.ExodriverLibrary,obj.ExodriverHeader);
                catch loadEX
                    fprintf(1,'LJU6/open: ERROR: unable to load Exodriver.\n');
                    fprintf(1,'  library: %s\n  header: %s\n  "%s"\n\n',obj.ExodriverLibrary,obj.ExodriverHeader,loadEX.message);
                    obj.verbose = 1;
                    return
                end
            end
            obj.driverVersion =  calllib('liblabjackusb','LJUSB_GetLibraryVersion');
            obj.deviceCount = calllib('liblabjackusb','LJUSB_GetDevCount',obj.deviceID);
            if obj.verbose >= 2, fprintf(1,'LJU6/open: %d LabJack U6 devices found.\n',obj.deviceCount); end
            % open the connection
            obj.handle = calllib('liblabjackusb','LJUSB_OpenDevice',deviceNum,0,obj.deviceID);
            obj.validHandle;
            if obj.isValidHandle
                obj.isOpen = 1;
                if obj.verbose >= 1, fprintf(1,'LJU6/open: Device successfully opened.\n'); end
                obj.CalVals = getCal(obj);                
                if obj.verbose >= 2, fprintf(1,'LJU6/open: Calibration data loaded.\n'); end
            else
                fprintf(1,'LJU6/open: WARNING: Failed to open device.\n');
                obj.isOpen = 0;
                obj.handle = [];
            end
		end
		

        %% Close
        % Closes the connection to a LabJack USB device.
		function close(obj)
			if ~isempty(obj.handle)
				obj.validHandle;
				if obj.isValidHandle && ~isempty(obj.handle)
					calllib('liblabjackusb','LJUSB_CloseDevice',obj.handle);
				end
				obj.isOpen = 0;
				obj.handle=[];
				obj.isValidHandle = 0;
                if obj.verbose >= 1, fprintf(1,'LJU6/close: Device successfully closed.\n'); end
            else
                fprintf(1,'LJU6/close: no handle to close.\n');
			end
        end
		

        %% validHandle
        % Verify that a object represents a valid connection to a device.
		function validHandle(obj)
            if ~isempty(obj.handle)
                obj.isValidHandle = calllib('liblabjackusb','LJUSB_IsHandleValid',obj.handle);
                if obj.isValidHandle
                    if obj.verbose >= 3, fprintf(1,'LJU6/validHandle: device handle is valid.\n'); end
                else
                    if obj.verbose >= 3, fprintf(1,'LJU6/validHandle: device handle is NOT valid.\n'); end
                end
            else
                obj.isValidHandle = 0;
                obj.isOpen = 0;
                obj.handle = [];
                if obj.verbose >= 2, fprintf(1,'LJU6/validHandle: device handle is NOT a handle.\n'); end
            end
		end
		

        %% usbWrite
        % OUT = USBWRITE(OBJ,BYTES)
        % Writes to the LabJack
        % OBJ    Device object
        % BYTES  Bytes string to send to device        
		function out = usbWrite(obj,bytes)
            %disp('usbWrite')
			out = calllib('liblabjackusb', 'LJUSB_Write', obj.handle, bytes, length(bytes));
            if isequal(out,0)
                fprintf(1,'labJackU6: Error on write to device! (zero bytes written)\n');
            elseif isequal(out,-1)
                fprintf(1,'labJackU6: Error on write to device! (error -1)\n');                
            else
                fprintf(1,'LJU6/usbWrite: %d bytes written to device.\n',out);
            end            
		end
		

        %% usbRead
        % BYTESREAD = USBREAD(OBJ,COUNT)
        % Reads a response from the LabJack
        % OBJ    Device object
        % COUNT  Number of bytes expected in the response
		function bytesRead = usbRead(obj,count)
            %disp('usbRead')
            bytesRead=zeros(count,1);
			[in3 in2 bytesRead] =  calllib('liblabjackusb', 'LJUSB_Read', obj.handle, bytesRead, count);
            % detect bad count value
            if in3==0
                fprintf(1,'LJU6/usbRead: WARNING bad count value (num bytes in==0) detected\n');
            end
            % detect bad checksum response
            if all(bytesRead(1:2)==184)
                fprintf(1,'LJU6/usbRead: WARNING bad command checksum detected\n');
                bytesRead=-1;
            else
                fprintf(1,'LJU6/usbRead: %d bytes read from device\n',in3);
                disp(bytesRead');
            end
        end
        
        
        %% readCalMem
        % Returns a block from the non-volatile memory (calibration).
        % Designed for reading calibration data (manual 5.2.6)
        function block = readCalMem(obj,BlockNum)
            cmdReadMem=zeros(8,1);
            cmdReadMem(2)= 248; % extended command code 0xF8
            cmdReadMem(3)= 1;
            cmdReadMem(4)= 45; % 0x2D
            cmdReadMem(7)= 0;
            cmdReadMem(8)= BlockNum;
            cmdReadMem=obj.addChecksum(cmdReadMem);
            % send command
            usbWrite(obj,cmdReadMem);
            % read response
            in = usbRead(obj,40);
            % VALIDATE RESPONSE
            if in(7)>0
                fprintf(1,'Block read error %d\n',in(7));
            end
            % return individual bytes
            block = uint8(in(9:40));
            %block = in(9:40);
        
        end
        
        
        %% getCal
        % Get the calibration constants stored on the device
        % Returns structure CALVALS, with fields: AIN MISC HIRES
        % Each field has a column with the relevant values
        % (manual 5.4)      
        function CalVals = getCal(obj)
                        
            % read AIN values
            calValArray=zeros(4,4); m=0;
            for k=0:3
                m=m+1;
                block=obj.readCalMem(k);
                for n=1:4
                    calValArray(n,m)=obj.fp2double(block((n-1)*8+1:n*8));
                end
            end
            %disp(calValArray)
            calValArray=reshape(calValArray,2,8);
            % each column will have the values for a gain setting
            CalVals.AIN=[calValArray(:,1:4); calValArray(:,5:8)];
            
            % read MISC values ("Misc")
            calValArray=zeros(4,2); m=0;
            for k=4:5
                m=m+1;
                block=obj.readCalMem(k);
                for n=1:4
                    calValArray(n,m)=obj.fp2double(block((n-1)*8+1:n*8));
                end
            end
            calValArray=reshape(calValArray,2,4);
            % each column will have the values for a output device            
            CalVals.MISC=calValArray;

            % read HI-RES values (For U6 Pro)
            calValArray=zeros(4,4); m=0;
            for k=6:9
                m=m+1;
                block=obj.readCalMem(k);
                for n=1:4
                    calValArray(n,m)=obj.fp2double(block((n-1)*8+1:n*8));
                end
            end
            calValArray=reshape(calValArray,2,8);
            % each column will have the values for a gain setting
            CalVals.HIRES=[calValArray(:,1:4); calValArray(:,5:8)];
            
        end
        
        
        %% addChannel
        % adds a channel to the list of active channels
        function addChannel(obj,channels,gains,polar)
            channels=channels(:)'; % make sure channels is a row vector
            if nargin < 4, polar=zeros(1,length(channels)); end
            polar=polar(:)'; % make sure channels is a row vector
            if nargin < 3, gains=zeros(1,length(channels)); end
            gains=gains(:)'; % make sure channels is a row vector
            
            if obj.verbose >= 1, fprintf(1,'LJU6:/addChannel: add channels: %s\n',num2str(channels)); end
            
            % does this channel already exist?
            rv=[];
            for k=1:length(channels)
                if any(channels(k)==obj.analogChannels)
                    fprintf(1,'LJU6:/addChannel: WARNING channel %d on channel list will be overwritten.\n',channels(k));
                    rv=[rv k];                                              %#ok<AGROW>
                end
            end
            obj.analogChannels(rv)=[];
            obj.inputRange(rv)=[];
            obj.inputBipolar(rv)=[];       
            
            % add a channel and sort
            [obj.analogChannels, ind]=sort([obj.analogChannels channels]);
            if obj.verbose >= 2, fprintf(1,'LJU6:/addChannel: analogChannels: %s\n',num2str(obj.analogChannels)); end

            % format gain vector
            if length(gains)<2
                gains(1:length(channels))=gains;
            end
            gains(gains==10)=0;
            gains(gains==1)=1;
            gains(gains==0.1)=2;
            gains(gains==0.01)=3;
            % add the gain value in the same place
            obj.inputRange=[obj.inputRange gains];
            obj.inputRange=obj.inputRange(ind);
            if obj.verbose >= 3, fprintf(1,'LJU6:/addChannel: inputRange:     %s\n',num2str(obj.inputRange)); end
            
            % format polarity vector
            if length(polar)<2
                polar(1:length(channels))=polar;
            end
            bipolar=zeros(length(polar),1);
            for k=1:length(polar)
                switch polar(k)
                    case {0,'single','S','s','single-ended'}
                        bipolar(k)=0;
                    case {1,'diff','D','d','differential'}
                        bipolar(k)=1;
                    otherwise
                        bipolar(k)=0;
                        fprintf(1,'LJU6/addchannel: WARNING: polarity value not understood ("%s")\n',num2str(polar(k)));
                end
            end
            % add the polarity value in the same place
            obj.inputBipolar=[obj.inputBipolar bipolar(:)'];
            obj.inputBipolar=obj.inputBipolar(ind);
            if obj.verbose >= 3, fprintf(1,'LJU6:/addChannel: inputBipolar:   %s\n',num2str(obj.inputBipolar)); end
            
            obj.numChannels=length(obj.analogChannels)-sum(obj.inputBipolar==1)/2;
            obj.isStreamConfig=0;
                        
        end
        

        %% removeChannel
        % removes a channel from the list of active channels
        function removeChannel(obj,channel)
            channel=channel(1); % only one channel at a time
            if channel < 0 % remove all channels
                for k=1:obj.numChannels
                    removeChannel(obj,obj.analogChannels(1))
                end
                return
            end
            dInd=find(obj.analogChannels==channel);
            % handle removing differential channels
            if obj.inputBipolar(dInd)==1 && ~mod(channel,2)
                channel=[channel channel+1];
                dInd=[dInd dInd+1];
            end
            if ~isempty(dInd)
                obj.analogChannels(dInd)=[];
                obj.inputRange(dInd)=[];
                obj.inputBipolar(dInd)=[];
                if obj.verbose >= 1
                    fprintf(1,'LJU6/removeChannel: Channel "%d" removed from channel list\n',channel);
                end
            else
                fprintf(1,'LJU6/removeChannel: Channel "%d" not in the list of channels\n',channel);
            end
            
            obj.numChannels=obj.numChannels-1;
            obj.isStreamConfig=0;
        end        
        
        
        %% streamConfigure
        % send the streamConfigure command, which prepares LJ for streaming
        %  analog data
        function errorCode = streamConfigure(obj)
            %disp('StreamConfigure')
            % Stream Configure ("5.2.12 - StreamConfig")
            % channels are numbered from 0 ("2.6.1 - Channel Numbers")
            % each channel can be paired with adjacent for differential sensing
            cmdStreamConfig=zeros(14,1,'uint8');
            %channels=[0 2];
            numChannelsScan=length(obj.analogChannels);
            obj.samplesPerPacket=25-rem(25,numChannelsScan);
            obj.samplesPerPacket=24;
            obj.bytesIn=zeros(14 + obj.samplesPerPacket*2,1);
            %inputBipolar=[0 0]; % 0= single ended, 1= differential
            %inputRange=[0 0]; % 0=+/- 10 V, 1=+/- 1 V, 2=+/- 0.1 V, 3=+/- 0.01 V
            %scanRate = 100; % Hertz
            % configure the stream clock. 4 MHz based rate, divided by Scan Interval. 
            if obj.SampleRateHz < 0.25
                fprintf(1,'LJU6/streamConfigure: ERROR Sample rate minimum is 0.25 Hz. (%g)\n',obj.SampleRateHz);
                obj.isStreamConfig = 0;
                return
            elseif obj.SampleRateHz < 100
                scanInt = min(65535,round(4e6/256/obj.SampleRateHz));
                clockBit=2; % divide by 256 for very slow scan rates
            else
                scanInt = min(65535,round(4e6/obj.SampleRateHz));
                clockBit=0;
            end
            if obj.verbose >= 2
                fprintf(1,'LJU6/streamConfigure:\n');
                fprintf(1,'  Sample Rate: %.2f Hz (ScanInt %d/%d) at ADC resolution level %d\n',4e6/scanInt/max(1,(clockBit*128)),scanInt,clockBit,obj.ResolutionADC);
                fprintf(1,'  Analog Input Channels: %s (%d)\n',num2str(obj.analogChannels),numChannelsScan);
                fprintf(1,'  Input Polarity (0|1):  %s\n',num2str(obj.inputBipolar));
                fprintf(1,'  ADC Input Range(gain): %s\n',num2str(obj.inputRange));
                fprintf(1,'  Samples per packet:  %d\n',obj.samplesPerPacket);
            end

            cmdStreamConfig(2)= 248; % extended command code 0xF8
            cmdStreamConfig(3)= numChannelsScan+4; % NumChannels + 4
            cmdStreamConfig(4)= 17; % configure command code 0x11
            cmdStreamConfig(7)= numChannelsScan; % NumChannels
            cmdStreamConfig(8)= obj.ResolutionADC; % Resolution Index (1-8, + 9-12 for U6 Pro)
            cmdStreamConfig(9)= obj.samplesPerPacket; % SamplesPerPacket (1-25)
            cmdStreamConfig(10)=0; % reserved
            cmdStreamConfig(11)=0; % SettlingFactor (use 0 for auto set)
            cmdStreamConfig(12)=clockBit; % ScanConfig (0 = 4MHz clock)
            cmdStreamConfig(13)=bitand(scanInt,255); % Scan Interval (low byte)
            cmdStreamConfig(14)=uint8(floor(scanInt/256)); % Scan Interval (high byte)
            for k=0:1:numChannelsScan-1
                % channel number
                cmdStreamConfig(15+k*2)=obj.analogChannels(k+1);
                % set gain and differential (bit 7 and bits 4-5)
                cmdStreamConfig(15+k*2+1)=(obj.inputBipolar(k+1)*64+obj.inputRange(k+1)*8);
            end

            disp('Stream config command before checksunm');
            disp(cmdStreamConfig);
            
            % do checksums
            cmdStreamConfig=obj.addChecksum(cmdStreamConfig);
            if obj.verbose >= 4, disp(cmdStreamConfig'); end
            
            disp('Stream config command after checksunm');
            disp(cmdStreamConfig);
            
            % send command
            usbWrite(obj,cmdStreamConfig);
            % read response
            in = usbRead(obj,8);
            % validate response checksums
            isValid = validateChecksum(obj,in);
            if isValid
                errorCode=in(7);
                if errorCode==0
                    obj.isStreamConfig = 1;
                else
                    fprintf(1,'LJU6/streamConfigure: LJ returned error %d\n',errorCode);
                    obj.isStreamConfig = 0;
                end
            else
                fprintf(1,'LJU6/streamConfigure: WARNING response checksum not valid. Try again.\n');
                obj.isStreamConfig = 0;
            end
            
        end
        
		
        %% startStream
        % send the command to initiate data streaming
        function errorCode = startStream(obj)
            %disp('startStream')
            if obj.isStreamConfig
                % send command
                obj.usbWrite(obj.cmdStartStream);
                % read response
                in = obj.usbRead(4);
                % VALIDATE RESPONSE CHECKSUMS
                errorCode=in(3);
                if errorCode==0
                    if obj.verbose >=1, fprintf(1,'LJU6/startStream: Stream started\n'); end
                    obj.isStreaming=1;
                else
                    fprintf(1,'labJackU6: Error during startStream (%d)\n',errorCode);
                    obj.isStreaming=0;
                end     
            else
                fprintf(1,'labJackU6: Error: device not configured for streaming. Use streamConfig.\n');
            end
            
        end
        

        %% stopStream
        % send the command to terminate data streaming
        function errorCode = stopStream(obj)
            %disp('stopStream')
            if obj.isStreamConfig
                % send command
                obj.usbWrite(obj.cmdStopStream);
                % read response
                in = obj.usbRead(4);
                % VALIDATE RESPONSE CHECKSUMS
                errorCode=in(3);
                if errorCode==0
                    if obj.verbose>=1, fprintf('LJU6/stopStream: stream stopped\n'); end
                    obj.isStreaming=0;
                else
                    fprintf(1,'labJackU6: Error during stopStream (%d)\n',errorCode);
                end                
            end
            
        end
        
        
        %% getStreamData
        % get streaming data
        function [data, errorCode] = getStreamData(obj)
            %disp('getStreamData')
            if obj.isStreamConfig
                
                % number of bytes to read ("5.2.14 - StreamData"):
                %  14 bytes of packet header info (12 + 2)
                %  2 bytes per sample
                
                if obj.verbose>=3, tic; end
                %dataBytes=zeros(obj.samplesPerPacket*2*256,'double'); %
                %NOTE : big performance hit for using "zeros" here

                %bytesIn=zeros(14 + obj.samplesPerPacket*2,1);
                count=length(obj.bytesIn);
                if obj.verbose>=3, fprintf('LJU6/getStreamData: Preparing to read %d bytes from stream\n',count); end
                

                a = obj.bytesIn;
                a
                [in3 in2 obj.bytesIn] =  calllib('liblabjackusb', 'LJUSB_Stream', obj.handle, obj.bytesIn, count);
                b = obj.bytesIn;
                b
%                 197
%   249
%    28
%   192
%   238
%     0
%     0
%     0
%     0
%     0
%     0
%     0
%     2
%     0
%   180
%     4
%     3
%     0
%     3
%     0
%     3
%     0
%     1
%     0
%     3
%     0
%     3
%     0
%     2
%     0
%     2
%     0
%     3
%     0
%     2
%     0
%     2
%     0
%     2
%     0
%     3
%     0
%     2
%     0
%     1
%     0
%     3
%     0
%     3
%     0
%     2
%     0
%     2
%     0
%     3
%     0
%     2
%     0
%     2
%     0
%     0
%     0


                % get key values from packet
                numSamples=double(obj.bytesIn(3))-4;  % number of samples (from samplesPerPacket)
                packetNumber=obj.bytesIn(11); % packet counter, 0-255 (8-bit)
                backlog=obj.bytesIn(end-1);   % 0-255 indicates bytes remaining in buffer
                errorCode=obj.bytesIn(12);
                dataBytes=double(obj.bytesIn(13:end-2));
                
                % debug display
                if obj.verbose>=2
                    fprintf('LJU6/getStreamData:\n');
                end
                if obj.verbose>=3
                    fprintf(1,'  packet %d contains %d/%d samples\n',packetNumber,numSamples,length(obj.bytesIn(13:end-2))/2);
                    fprintf(1,'  packet size: %d/%d bytes\n',length(obj.bytesIn),in3);
                end
                if obj.verbose>=2
                    fprintf(1,'  backlog: %.1f%% (%d) (error %d)\n',double(backlog)/255*100,backlog,errorCode);
                end
                
                if all(errorCode~=[0 59]) && obj.verbose >= 1
                    fprintf(1,'LJU6/getStreamData: device returns error %d on stream read (%d)\n',errorCode,packetNumber);
                end
                
                if errorCode==59
                    if obj.verbose>=1, fprintf(1,'LJU6/getStreamData: WARNING: In auto-recovery mode. Data has been lost.\n'); end
                end                

                % read additional packets if there is data remaining in buffer
                m=1; % count number of packets read
                while backlog > 0
                    m=m+1;               
                    [in3 in2 obj.bytesIn] =  calllib('liblabjackusb', 'LJUSB_Stream', obj.handle, obj.bytesIn, count);
                    numSamples=double(obj.bytesIn(3))-4;  % number of samples (from samplesPerPacket)
                    packetNumber=obj.bytesIn(11); % packet counter, 0-255 (8-bit)
                    backlog=obj.bytesIn(end-1);   % 0-255 indicates bytes remaining in buffer
                    errorCode=max(errorCode,obj.bytesIn(12));
                    % debug display
                    if obj.verbose>=3
                        fprintf(1,'\nlabJackU6: additional stream read %d\n\n',m);
                        fprintf(1,'  packet %d contains %d samples\n',packetNumber,numSamples);
                        fprintf(1,'  packet size: %d/%d bytes\n',length(obj.bytesIn),in3);
                        %fprintf(1,'  backlog: %.1f%% (%d)\n',double(backlog)/255*100,backlog);
                    end
                    if obj.verbose>=2
                        fprintf(1,'  (m %d) backlog: %.1f%% (%d) (error %d)\n',m,double(backlog)/255*100,backlog,errorCode);
                    end                    
                    dataBytes((m-1)*obj.samplesPerPacket*2+1:m*obj.samplesPerPacket*2)=double(obj.bytesIn(13:end-2));
                    
                    if all(errorCode~=[0 59]) && obj.verbose >= 1
                        fprintf(1,'LJU6/getStreamData: device returns error %d on stream read\n',errorCode);
                    end
                    
                    if m>=255
                        fprintf(1,'LJU6: WARNING: unable to keep up with data stream rate!\n');
                        break
                    end
                end
                
                % interpret the 16-bit data values
                %  (manual 5.4: "Binary readings are always unsigned integers")
                dataBytes16=dataBytes(1:m*obj.samplesPerPacket*2);
                dataBytes16(2:2:end)=dataBytes16(2:2:end)*256;
                data=dataBytes16(1:2:end)+dataBytes16(2:2:end);
                
                if length(data)~=numSamples*m
                    fprintf(1,'labJackU6: WARNING: number of samples read (%d) does not agree with packet info (%d)\n',length(data),numSamples*m);
                end
                
                % data is returned in a column for each channel
                numChannelsScan=length(obj.analogChannels);
                data=reshape(data,numChannelsScan,[])';

                % Apply Calibration (ANALOG IN ONLY)
                % Choose Regular or Precision
                % -- Regular cal
%                 for k=1:numChannelsScan
%                     data(:,k) = ( data(:,k) .* obj.CalVals.AIN(1,obj.inputRange(k)+1) ) + obj.CalVals.AIN(2,obj.inputRange(k)+1);
%                 end
                % -- Precision cal
                for k=1:numChannelsScan
                    data(data(:,k)< obj.CalVals.AIN(4,obj.inputRange(k)+1),k) = ( obj.CalVals.AIN(4,obj.inputRange(k)+1) - data(data(:,k)< obj.CalVals.AIN(4,obj.inputRange(k)+1),k) ) .* obj.CalVals.AIN(3,obj.inputRange(k)+1);
                    data(data(:,k)>=obj.CalVals.AIN(4,obj.inputRange(k)+1),k) = ( data(data(:,k)>=obj.CalVals.AIN(4,obj.inputRange(k)+1),k) - obj.CalVals.AIN(4,obj.inputRange(k)+1) ) .* obj.CalVals.AIN(1,obj.inputRange(k)+1);
                end            

                if obj.verbose>=4, disp(data); end
                
                % handle differential measurements
                % combine the paired channels
                if any(obj.inputBipolar)
                    bp=find(obj.inputBipolar);
                    bp=bp(1:2:end);
                    data(:,bp)=data(:,bp)-data(:,bp+1);
                    data(:,bp+1)=[];
                end
                
                % handle auto-recovery mode
                % insert dummy data to indicate time of lost data
                % (see manual 5.2.14 - StreamData)
                if errorCode==60
                    scansMissed=double(typecast(uint8(obj.bytesIn(7:10)),'uint32'));
                    if obj.verbose>=1, fprintf(1,'LJU6/getStreamData: Auto-recovery: backlog now %d. %d scans were lost\n',backlog,scansMissed); end
                
                    dummyData=(ones(scansMissed-1,obj.numChannels)) .* (-9999);
                    data=[data; dummyData];
                end                    
                
            else
                fprintf(1,'labJackU6: Error: device not configured. Use streamConfig.\n');
                data=[];
            end
            if obj.verbose>=3, fprintf(1,'getStreamData: '); disp(toc); end
        end


        %% DAC analogOut
        % set an output voltage for one of the two DAC channels
        function analogOut(obj,channel,voltageSet)
            % error check inputs
            if channel > 1 || channel < 0
                fprintf(1,'LJU6/analogOut: "channel" must be 0 or 1\n');
                return
            end
            if voltageSet < 0 || voltageSet > 5
                fprintf(1,'LJU6/analogOut: "voltageSet" must be 0-5 V\n');
                return
            end
            
            % calculate DAC output setting
            if obj.verbose >= 1, fprintf(1,'LJU6/analogOut: Set DAC%d to %g V\n',channel,voltageSet); end
            counts=uint16((voltageSet * obj.CalVals.MISC(1,channel+1) ) + obj.CalVals.MISC(2,channel+1));
            if obj.verbose >= 2, fprintf(1,'LJU6/analogOut: %g V = %d counts\n',voltageSet,counts); end
            counts=typecast(counts,'uint8');
            
            % create command
            cmd=obj.cmdDACSet;
            cmd(9:10)=counts;
            % 5.2.5.16 - DAC# (16-bit): IOType=38,39
            if channel == 0
                cmd(8)=uint8(38);
            elseif channel == 1
                cmd(8)=uint8(39);
            end
            % echo
            cmd(7)=uint8(77);
            
            % send command
            cmd=addChecksum(obj,cmd);
            if obj.verbose >= 4, fprintf(1,'  command:\n'); disp(cmd'); end
            usbWrite(obj,cmd);
            
            % read response - response is always even number of bytes
            %  (a zero is added if necessary)
            resp = usbRead(obj,10);
            if resp==-1
                fprintf(1,'LJU6/analogOut: WARNING Bad command checksum. DAC not set!\n');
                return
            end
            if resp(7) > 0
                fprintf(1,'LJU6/analogOut: Command returned error %d\n',resp(7));
            end
            
        end
        
        
        %% AIN analogIn
        % reads a single AIN value
        % (manual 5.2.5)
        function data = analogIn(obj,channel,gain,polarity,resLevel)
            %disp(nargin)
            if nargin < 5, resLevel=obj.ResolutionADC; end
            if nargin < 4, polarity=0; end
            if nargin < 3, gain=10; end
            
            % error check inputs
            if channel > 143 || channel < 0
                fprintf(1,'LJU6/analogIn: "channel" must be 0-143\n');
                return
            end
            switch polarity
                case {0,'single','S','s','single-ended'}
                    bipolar=0;
                case {1,'diff','D','d','differential'}
                    bipolar=1;
                otherwise
                    bipolar=0;
                    fprintf(1,'LJU6/analogIn: WARNING: polarity value not understood ("%s")\n',num2str(polar(k)));
            end
            % format gain vector
            gain(gain==10)=0;
            gain(gain==1)=1;
            gain(gain==0.1)=2;
            gain(gain==0.01)=3;
            
            if channel==14 && gain~=0
                fprintf(1,'LJU6/analogIn: WARNING: gain should be +/- 10 V for accurate temperature (ch 14)\n');
            end
            
            if obj.isStreaming==0
                if obj.verbose >= 2, fprintf(1,'LJU6/analogIn: Reading AIN%d\n',channel); end
            
                % create command
                cmd=zeros(12,1);
                cmd(2)= 248; % extended command code 0xF8
                cmd(3)= 2; % 0.5 + Number of Data Words (IOTypes and Data)
                cmd(4)= 0; % 0x2D
                cmd(7)= 7; % Echo
                
                cmd(8)=uint8(2); % 5.2.5.2 - AIN24: IOType = 2
                cmd(9)=uint8(channel);
                % Bits 0-3: ResolutionIndex, Bits 4-7: GainIndex
                cmd(10)=bitor(uint8(resLevel),bitshift(uint8(gain),4));
                % Bits 0-2: SettlingFactor (0=Auto), Bit 7: Differential
                cmd(11)=uint8(0+bipolar*128);

                % send command
                cmd=obj.addChecksum(cmd);
                obj.usbWrite(cmd);

                % read response
                resp = obj.usbRead(12);
                if resp(7) > 0
                    fprintf(1,'LJU6/analogIn: Command returned error %d\n',resp(7));
                end
                if ~any(resp)
                    fprintf(1,'LJU6/analogIn: Command error (zero response). Recommend close/reopen LJ.\n');
                end
                %disp(uint8([resp(10:end); 0]))
                data = typecast(uint8([resp(10:end); 0]),'uint32');
                data = double(data)/256; %fprintf(1,'24-bit data: %f\n',data);
                % convert to Volts
                if resLevel > 8
                    if data < obj.CalVals.HIRES(4,gain+1)
                        data = ( obj.CalVals.HIRES(4,gain+1) - data ) * obj.CalVals.HIRES(3,gain+1);
                    else
                        data = ( data - obj.CalVals.HIRES(4,gain+1) ) * obj.CalVals.HIRES(1,gain+1);
                    end
                else
                    if data < obj.CalVals.AIN(4,gain+1)
                        data = ( obj.CalVals.AIN(4,gain+1) - data ) * obj.CalVals.AIN(3,gain+1);
                    else
                        data = ( data - obj.CalVals.AIN(4,gain+1) ) * obj.CalVals.AIN(1,gain+1);
                    end
                end
                % Temperature?
                if channel==14
                    data = (data * obj.CalVals.MISC(1,4)) + obj.CalVals.MISC(2,4) - 273; % raw data in is K, return deg C
                    if obj.verbose >= 2, fprintf(1,'LJU6/analogIn: Read %g C on channel %d (internal temperature)\n',data,channel); end
                else
                    if obj.verbose >= 2, fprintf(1,'LJU6/analogIn: Read %g V on channel %d\n',data,channel); end
                end
                
            else
                fprintf(1,'LJU6/analogIn: Cannot perform AIN readings while streaming is active!\n');
                data=[];
            end
            
        end
        
        %% AIN analogScan
        % returns readings from all the channels in the Channel List
        %  data returned as a row vector (one column per channel, one row per scan)
        function data = analogScan(obj,numScans)
            if nargin < 2, numScans=1; end
            if isempty(obj.analogChannels)
                fprintf(1,'LJU6/analogScan: ERROR no channels in channel list\n');
                return
            else
                % create a channel list for scan
                channelList = obj.analogChannels;
                gainList = obj.inputRange;
                diffList = obj.inputBipolar;
                % remove negative channels for differential inputs
                bInd=find(obj.inputBipolar==1);
                channelList(bInd(2:2:end))=[];
                gainList(bInd(2:2:end))=[];
                diffList(bInd(2:2:end))=[];
            end
            if obj.verbose >= 1, fprintf(1,'LJU6/analogScan: scanning %d channels\n',length(channelList)); end
            
            % do the scans
            data=zeros(numScans,length(channelList));
            for k=1:numScans
                for ch=1:length(channelList)
                    data(k,ch)=analogIn(obj,channelList(ch),gainList(ch),diffList(ch));
                end
            end
            
        end
        
        
       
        %% getInfo
        % displays device configuration from ConfigU6 (manual 5.2.2)
        function devInfo = getInfo(obj)
            % create get info command
            cmdGetConfig=cell(26,1);
            cmdGetConfig(:)={'00'};
            cmdGetConfig(1)={'0B'};
            cmdGetConfig(2)={'F8'};
            cmdGetConfig(3)={'0A'};
            cmdGetConfig(4)={'08'};
            % send to device
            cmdGetConfig=hex2dec(cmdGetConfig);
            usbWrite(obj,cmdGetConfig);
            resp = usbRead(obj,38);
            if resp(7)>0
                fprintf(1,'LJU6/getInfo: Command returned error %d\n',resp(7));
            end

            % display the results
            resp=double(resp);
            fprintf('LJU6: U6 Configuration Settings:\n');
            devInfo.FirmwareVersion=resp(11) + resp(10)/100.0;
            fprintf(' FirmwareVersion: %.3f\n', devInfo.FirmwareVersion);
            devInfo.BootloaderVersion=resp(13) + resp(12)/100.0;
            fprintf(' BootloaderVersion: %.3f\n', devInfo.BootloaderVersion);
            devInfo.HardwareVersion=resp(15) + resp(14)/100.0;
            fprintf(' HardwareVersion: %.3f\n', devInfo.HardwareVersion);
            devInfo.SerialNumber=resp(16) + resp(17)*256 + resp(18)*65536 + resp(19)*16777216;
            fprintf(' SerialNumber: %u\n', devInfo.SerialNumber);
            devInfo.ProductID=resp(20) + resp(21)*256;
            fprintf(' ProductID: %d\n', devInfo.ProductID);
            devInfo.LocalID=resp(22);
            fprintf(' LocalID (deviceNum): %d\n', devInfo.LocalID);
            devInfo.isU6=((resp(38)/4)&1);
            devInfo.isU6pro=((resp(38)/8)&1);
            fprintf(' Version Info: %d\n', resp(38));
            fprintf('   U6 (bit 2): %d\n', devInfo.isU6);
            fprintf('   U6-Pro (bit 3): %d\n', devInfo.isU6pro);
        end
		
		
		%% reset
        % send "reset" command to LabJack (manual 5.2.11)
        function reset(obj,resetType)
            if nargin < 2, resetType=0; end
			cmd=zeros(4,1);
			cmd(2) = hex2dec('99');
            switch resetType
                case {0,'soft','SOFT'}
                    cmd(3) = bin2dec('01');
                case {1,'hard','HARD'}
                    cmd(3) = bin2dec('10');
            end
            
			% send command
			cmd = obj.addChecksum(cmd);			
			obj.usbWrite(cmd);
            
            % read response
			resp  = obj.usbRead(4);
            if resp(4) > 0
                fprintf(1,'LJU6/reset: LJ returned error %d\n',resp(4));
            else
                obj.analogChannels=[];
                if obj.verbose >= 1, fprintf(1,'LJU6/reset: Device reset\n'); end
            end
        end
        
        
        %% addChecksum
        % calculate the checksums for an outgoing packet
        % calculates the appropriate addChecksum based on byte #2
        % COMMANDBYTES is an array of byte values
        function commandBytes = addChecksum(obj,commandBytes)
           if commandBytes(2) >= 248 % extended command
               [commandBytes(5),commandBytes(6)] = obj.checksum16(commandBytes(7:end));
               commandBytes(1) = obj.checksum8(commandBytes(2:6));
           else %"normal" command
               commandBytes(1) = obj.checksum8(commandBytes(2:end));
           end
        end
        
        
        %% validateChecksum
        % checks the checsums on a response
        function isChecked = validateChecksum(obj,responseBytes)
            if responseBytes(2) >= 248 % extended command
               [chk16(1),chk16(2)] = obj.checksum16(responseBytes(7:end));
               chk8(1) = obj.checksum8(responseBytes(2:6));
               if responseBytes(5)==chk16(1) && responseBytes(6)==chk16(2) && responseBytes(1)==chk8(1)
                   isChecked=1;
               else
                   isChecked=0;
               end
           else %"normal" command
               chk8(1) = obj.checksum8(responseBytes(2:end));
               if responseBytes(1)==chk8(1)
                   isChecked=1;
               else
                   isChecked=0;
               end               
           end                
        
        end
        
        
    end
	

    % % % % % % %
    % Static Methods
	methods ( Static )
        %% checksum8
        % Calculate single-byte addChecksum for LJ data packet
		function chk = checksum8(in)
			in = sum(uint16(in));
			quo = floor(in/2^8);
			remd = rem(in,2^8);
			in = quo+remd;
			quo = floor(in/2^8);
			remd = rem(in,2^8);
			chk = quo + remd;
		end
		

        %% checksum16
        % Calculate double-byte addChecksum for LJ data packet
		function [lsb,msb] = checksum16(in)
			in = sum(uint16(in));
			lsb=bitand(in,255);
			msb=bitshift(in,-8);
        end
        
        %% Fixed-point conversion
        % convert fixed-point calibration values
        % (see manual 5.4 and FPuint8ArrayToFPDouble in u6.c)
        function out=fp2double(in)
            in=uint32(in);
            
            % assemble the whole number from high order bytes
            wholeNum = bitor(in(5),bitshift(in(6),8));
            wholeNum = bitor(wholeNum,bitshift(in(7),16));
            wholeNum = bitor(wholeNum,bitshift(in(8),24));
            wholeNum=typecast(uint32(wholeNum),'int32'); % to handle negative values
            
            % assemble the fractional value from low order bytes
            fractNum = bitor(in(1),bitshift(in(2),8));
            fractNum = bitor(fractNum,bitshift(in(3),16));
            fractNum = bitor(fractNum,bitshift(in(4),24));
            
            % assemble the complete value
            out=double(wholeNum)+double(fractNum)/4294967296;
        end
		
	end
	
	
    % % % % % % %
    % Private Methods
	methods ( Access = private ) 
	
        %% delete
		% Destructor
		function delete(obj)
            if obj.verbose >= 1, fprintf(1,'LJU6/delete: Closing object\n'); end
			close(obj);
		end
    end
    
    
end