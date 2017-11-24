% Subclass of @Radiometer, specific to the PR670
%
% 3/27/2014  npc   Wrote it.
%

classdef SpectroCALdev < Radiometer
    
    % Public properties (specific to the SpectroCALdev)
    properties
        % Sync-Mode
        syncMode;
    end
    
    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private)
        % Handle to communication port
        portHandle = [];
        
        % device files that are known to be for other devices than the SpectroCAL
        invalidPortStrings = { 'cu.usbserial-KU000000', 'unspecified' };
        
        % valid ranges for user-settable properties
        validSyncModes  = {'OFF', 'ON'};
    end
    % --- END OF PRIVATE PROPERTIES ---------------------------------------
    
    
    
    
    
    % Public methods
    methods
        
        % Constructor
        function obj = SpectroCALdev(varargin)
            
            parser = inputParser;
            parser.addParamValue('verbosity',   1);
            parser.addParamValue('devicePortString',  '/dev/tty.usbserial-AL1G0I9F');
            
            % Execute the parser
            parser.parse(varargin{:});
            % Create a standard Matlab structure from the parser results.
            p = parser.Results;
            verbosity       = p.verbosity;
            devPortString   = p.devicePortString;
            
            % Call the super-class constructor.
            obj = obj@Radiometer(verbosity, devPortString);
            
            if (obj.verbosity > 9)
                fprintf('In SpectralCALdev.constructor() method\n');
            end
            
            % Initialize communication
            obj = obj.establishCommunication();
            
            % Initialize properties
            obj.deviceModelName     = 'SpectroCAL';
            obj.deviceProvidesSpectralMeasurements = true;
            obj.deviceSerialNum     = obj.getDeviceSerialNumber();
            obj.nativeS             = [380 1 401];
            obj.nativeT             = eye(obj.nativeS(3));
            obj.nativeMeasurement   = struct('energy', [], 'spectralAxis', []);
            obj.userS               = obj.nativeS;
            obj.userT               = obj.nativeT;
            obj.measurement         = [];
            obj.syncMode            = 'OFF';
            
            % Initialize protected properties
            obj.availableConfigurationOptionNames  = {'syncMode'};
            obj.availableConfigurationOptionValidValues = {obj.validSyncModes};
        end
        
    end % Public methods
    
    
    % Implementations of required -- Public -- Abstract methods defined in the Radiometer interface
    methods
        
        % SpectroCAL-specific configuration options
        function obj = setOptions(obj, varargin);
        end
        
        % Method to conduct a single native measurent. For the PR-650 this is an SPD measurement.
        function result = measure(obj)
            % initialize to empty result
            result = obj.measureSpd();
            obj.measurement.spectralAxis = result.wls;
            obj.measurement.energy = result.spd;
        end
        
        function obj = shutDown(obj)
        end
        
        function obj = getMeasuredData()
        end
        
        function obj = triggerMeasure()
        end
        
        function result = measureSpd(obj)
            result.wls = obj.nativeS(1):obj.nativeS(2):(obj.nativeS(1)+obj.nativeS(2)*obj.nativeS(3)-1);
            [result.ciexy, result.cieuv, result.luminance, result.wls, result.spd] = SpectroCALMakeSPDMeasurement(obj.portString, ...
                result.wls(1), result.wls(end), obj.nativeS(2));
            result.spd = result.spd';
        end
        
    end % Implementations of required -- Public -- Abstract methods defined in the Radiometer interface
    
    methods
        % Method to turn on and off the laser
        function obj = switchLaserState(obj, laserState)
            % Check whether to turn laser on or off
            if laserState == 0
                obj.sendCommand('*CONTR:LASER 0');CP,1);
            elseif laserState == 1
                obj.sendCommand('*CONTR:LASER 1');
            end
        end
        
        function errMesg = parseErrorCode(obj, errorCode)
            % The following list of error codes is from the JETI
            % Spectroradiometer Firmware handbook, document rev 2.70
            
            switch errorCode
                case 0
                    errMesg = "no error";
                case 4
                    errMesg = "command error";
                case 7
                    errMesg = "error password";
                case 8
                    errMesg = "digit error";
                case 10
                    errMesg = "error argument 1";
                case 11
                    errMesg = "error argument 2";
                case 12
                    errMesg = "error argument 3";
                case 13
                    errMesg = "error argument 4";
                case 20
                    errMesg = "error parameter argument";
                case 21
                    errMesg = "error config argument";
                case 22
                    errMesg = "error control argument";
                case 23
                    errMesg = "error read argument";
                case 24
                    errMesg = "error fetch argument";
                case 25
                    errMesg = "error measuring argument";
                case 26
                    errMesg = "error calculation argument";
                case 27
                    errMesg = "error calibration argument";
                case 101
                    errMesg = "error parameter checksum";
                case 102
                    errMesg = "error userfile checksum";
                case 103
                    errMesg = "error userfile2 checksum";
                case 104
                    errMesg = "error userfile2 argument";
                case 120
                    errMesg = "error overexposure";
                case 121
                    errMesg = "error underexposure";
                case 123
                    errMesg = "error adaption integration time";
                case 130
                    errMesg = "error shutter not exist";
                case 131
                    errMesg = "error no dark measurement";
                case 132
                    errMesg = "error no reference measurement";
                case 133
                    errMesg = "error no transmission measurement";
                case 134
                    errMesg = "error no radiometric calculation";
                case 135
                    errMesg = "error no cct calculation";
                case 136
                    errMesg = "error no cri calculation";
                case 137
                    errMesg = "error no dark compensation";
                case 138
                    errMesg = "error no light measurement";
                case 139
                    errMesg = "error no peak calculation";
                case 140
                    errMesg = "error calibration data";
                case 141
                    errMesg = "error exceed calibration wavelength";
                case 147
                    errMesg = "error scan break";
                case 160
                    errMesg = "error timeout cycle optical trigger";
                case 161
                    errMesg = "error divider cycle time";
                case 170
                    errMesg = "error write parameter to flash";
                case 171
                    errMesg = "error read parameter from flash";
                case 172
                    errMesg = "error erase flash";
                case 180
                    errMesg = "error no calib file";
                case 181
                    errMesg = "error calib file header";
                case 182
                    errMesg = "error write calib file";
                case 183
                    errMesg = "error calib file values";
                case 184
                    errMesg = "error calib file number";
                case 186
                    errMesg = "error clear calib file";
                case 187
                    errMesg = "error clear calib file argument";
                case 190
                    errMesg = "error no lamp file";
                case 191
                    errMesg = "error lamp file header";
                case 192
                    errMesg = "error write lamp file";
                case 193
                    errMesg = "error lamp file values";
                case 194
                    errMesg = "error lamp file number";
                case 196
                    errMesg = "error clear lamp file";
                case 197
                    errMesg = "error clear lamp file argument";
                case 200
                    errMesg = "error ram check";
                case 220
                    errMesg = "error data output";
                case 225
                    errMesg = "error insufcient ram";
                case 230
                    errMesg = "error first memory allocation";
                case 231
                    errMesg = "error second memory allocation";
                case 232
                    errMesg = "error third memory allocation";
                case 251
                    errMesg = "error wavelength range for radiometric calculation";
                case 280
                    errMesg = "error jump boot by battery power";
                case 500
                    errMesg = "error trigger configuration 1";
                case 501
                    errMesg = "error trigger configuration 2";
            end
        end
        
    end
    
    methods (Access = private)
        % Method to initialize communication with the device
        function obj = establishCommunication(obj)
            try
                tmp = ls(obj.portString);
                fprintf('Device found at <strong>%s</strong>\n', strtrim(tmp));
            catch e
                fprintf(sprintf('No device found at <strong>%s</strong>, port does not exist\n', obj.portString));
                fprintf('Potential devices in /dev/tty:\n');
                tmp = dir('/dev/tty*usb*');
                for ii = 1:length(tmp)
                    fprintf('\t<strong>%s</strong>\n', fullfile(tmp.folder, tmp.name));
                end
                error('Exiting...');
            end
        end
        
        function obj = sendCommand(obj, commandToBeSent)
            if ~isstring(commandToBeSent)
               error('Input to sendCommand not a string');
            end
            VCP = serial(obj.portString, 'BaudRate', 921600,...
                'DataBits', 8, ...
                'StopBits', 1, ...
                'FlowControl', 'none', ...
                'Parity', 'none', 'Terminator', 'CR',...
                'Timeout', 5, ...
                'InputBufferSize', 16000);
            fopen(VCP);
            fprintf(VCP, [commandToBeSent, char(13)]);
            errorMsg = fread(VCP, 1);
            obj.parseErrorCode(errorMsg);
            fclose(VCP);
        end
        
        % Method to obtain device-speficic properties of PR-650
        function serialNum = getDeviceSerialNumber(obj)
            serialNum = '2171079';
        end
        
        % Method to shutdown the device
        obj = shutDownDevice(obj)
    end  % Private methods
    
end