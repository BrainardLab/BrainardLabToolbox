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
        end
            
    end % Implementations of required -- Public -- Abstract methods defined in the Radiometer interface
    
    methods
        
        % Method to turn on and off the laser
        function obj = switchLaserState(obj, laserState)
            % Check whether to turn laser on or off
            if laserState == 0
                SpectroCALLaserOff(obj.portString);
            elseif laserState == 1
                SpectroCALLaserOn(obj.portString);
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
        
        % Method to obtain device-speficic properties of PR-650
        function serialNum = getDeviceSerialNumber(obj)
            serialNum = '2171079';
        end
        
        % Method to shutdown the device
        obj = shutDownDevice(obj)
    end  % Private methods
    
end