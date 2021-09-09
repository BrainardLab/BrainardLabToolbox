% Subclass of @Radiometer, specific to the PR670
%
% 3/27/2014  npc   Wrote it.
%
classdef PR670dev < Radiometer
   
    % Public properties (specific to the PR670dev) 
    properties
        % SyncMode: see obj.validSyncModes
        syncMode;

        % cycles to average : see obj.validCyclesToAverage
        cyclesToAverage;
        
        % sensitivityMode: see obj.validSensitivityModes
        sensitivityMode;
        
        % exposureTime (in milliseconds)
        exposureTime;
        
        % apertureSize; see: obj.validApertureSizes
        apertureSize;
    end
    
    properties (SetAccess = private)
        % struct with current configuration as reported by the PR670
        currentConfiguration = struct();
    end
    
    
    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private)              
        % Handle to communication port
        portHandle = [];
       
        % Device files that are known to be for other devices than the PR670
        invalidPortStrings = { 'cu.usbserial-KU000000', 'unspecified' };
        
        % valid ranges for user-settable properties
        validSyncModes          = {'OFF', 'AUTO', [20 400]};
        validCyclesToAverage    = [1 99];
        validSensitivityModes   = {'STANDARD', 'EXTENDED'};  % 'STANDARD' (exposure range: 6 - 6,000 msec, 'EXTENDED' exposure range: 6 - 30,000 msec
        validExposureTimes      = {'ADAPTIVE', [1 6000], [1 30000]};  % 'ADAPTIVE' is for adaptive exposure, [1-6,000] is for 'STANDARD' sensitivity mode, [1 30000] for the 'EXTENDED' sensitivity mode
        validApertureSizes      = {'1 DEG', '1/2 DEG', '1/4 DEG', '1/8 DEG'};
        
        % Private syncMode
        privateSyncMode;
        
        % Private cyclesToAverage
        privateCyclesToAverage;
        
        % Private sensitivityMode
        privateSensitivityMode;
        
        % Private exposureTime
        privateExposureTime;
        
        % Private apertureSize
        privateApertureSize;
        
        % Private currentConfiguration
        privateCurrentConfiguration;
    end
    % --- END OF PRIVATE PROPERTIES ---------------------------------------
    
    % Public methods
    methods
        
        % Constructor
        function obj = PR670dev(varargin)  
            parser = inputParser;
            parser.addParameter('verbosity', 1, @isscalar);
            parser.addParameter('devicePortString',  [], @(x)(isempty(x) || (ischar(x))));
            parser.addParameter('emulateHardware', false, @islogical);
            
            % Execute the parser
            parser.parse(varargin{:});
            % Create a standard Matlab structure from the parser results.
            p = parser.Results;
            verbosity       = p.verbosity;
            devPortString   = p.devicePortString;
            emulateHardware = p.emulateHardware;
            
            % Call the super-class constructor.
            obj = obj@Radiometer(verbosity, devPortString, emulateHardware);
            
            if (obj.verbosity > 9)
                fprintf('In PR670dev.constructor() method\n');
            end
            
            allInitStepsAtOnce = false;
            if (allInitStepsAtOnce) 
            % Initialize communication
                obj = obj.establishCommunication();
            else
                pause(2.0);
                obj = obj.openPort();

                pause(2.0);
                obj = obj.initCommunication();
            end

            % Initialize properties
            obj.deviceModelName     = 'PR-670';
            obj.deviceProvidesSpectralMeasurements = true;
            obj.deviceSerialNum     = obj.getDeviceSerialNumber();
            obj.nativeS             = [380 2 201];
            obj.nativeT             = eye(obj.nativeS(3));
            obj.nativeMeasurement   = struct('energy', [], 'spectralAxis', []);
            obj.userS               = obj.nativeS;
            obj.userT               = obj.nativeT;
            obj.measurement         = [];
            
            % Initialize private properties
            obj.privateSyncMode         = obj.validSyncModes{1}; 
            obj.privateCyclesToAverage  = obj.validCyclesToAverage(1);
            obj.privateSensitivityMode  = obj.validSensitivityModes{1};
            obj.privateExposureTime     = obj.validExposureTimes{1};
            obj.privateApertureSize     = obj.validApertureSizes{1};
            
            % Initialize protected properties
            obj.availableConfigurationOptionNames       = {'syncMode',        'cyclesToAverage',        'sensitivityMode',         'exposureTime',         'apertureSize'};
            obj.availableConfigurationOptionValidValues = {obj.validSyncModes, obj.validCyclesToAverage, obj.validSensitivityModes, obj.validExposureTimes, obj.validApertureSizes};
        
            % Get current configuration
            obj.privateCurrentConfiguration = obj.getConfiguration();
        end % Constructor
        
    end % Public methods
    
    % Implementations of required -- Public -- Abstract methods defined in the Radiometer interface   
    methods
        
        % PR670-specific configuration options
        obj = setOptions(obj, varargin);
        
        % Method to conduct a single native measurent. For the PR-650 this is an SPD measurement.
        result = measure(obj, varargin);    
        
        % Functions to separate the measure() command into two separate components:
        % triggerMeasure() and getMeasuredData().
        % This is useful if we want to have more than one radiometers measure simulteneously
        triggerMeasure(obj);
        result = getMeasuredData(obj);
         
        function obj = shutDown(obj)
            obj = obj.shutDownDevice();
        end
    end % Implementations of required -- Public -- Abstract methods defined in the Radiometer interface
    
    % Public utility methods 
    methods
        
        % Method to set the backlight level
        setBacklightLevel(obj, level);
        
        % Method to measure the source frequency
        sourceFreq = measureSourceFrequency(obj);
    end
    
    
    % Public methods to set/get state
    methods
        % Setter method for property syncMode
        function set.syncMode(obj, newSyncMode)
            obj.privateSetSyncMode(newSyncMode);
        end
        
        % Getter method for property syncMode
        function value = get.syncMode(obj)
            value = obj.privateSyncMode;
        end
        
        
        % Setter method for property cyclesToAverage
        function set.cyclesToAverage(obj, newCyclesToAverage)
            obj.privateSetCyclesToAverage(newCyclesToAverage);
        end
        
        % Getter method for property cyclesToAverage
        function value = get.cyclesToAverage(obj)
            value = obj.privateCyclesToAverage;
        end

        
        % Setter method for property sensitivityMode
        function set.sensitivityMode(obj, newSensitivityMode)
            obj.privateSetSensitivityMode(newSensitivityMode);
        end
        
        % Getter method for property sensitivityMode
        function value = get.sensitivityMode(obj)
            value = obj.privateSensitivityMode;
        end
        
        
        % Setter method for property exposureTime
        function set.exposureTime(obj, newExposureTime)
            obj.privateSetExposureTime(newExposureTime);
        end
        
        % Getter method for property exposureTime
        function value = get.exposureTime(obj)
            value = obj.privateExposureTime;
        end
        
        
       
        % Setter method for property apertureSize
        function set.apertureSize(obj, newApertureSize)
            obj.privateSetApertureSize(newApertureSize);
        end
        
        % Getter method for property apertureSize
        function value = get.apertureSize(obj)
            value = obj.privateApertureSize;
        end
        
        
        % Getter method for property currentConfiguration
        function value = get.currentConfiguration(obj)
           value = obj.privateCurrentConfiguration;
        end
        
    end
    
    
    methods (Access = private)   

        % Method to open port for PR670 (establish communication  part1)
        obj = openPort(obj);

        % Method to initialize communication with the PR670 (establish communication  part2)
        obj = initCommunication(obj);

        % Method to initialize communication with the device
        obj = establishCommunication(obj)
        
        % Method to obtain device-speficic properties of PR-670
        deviceSerialNum = getDeviceSerialNumber(obj)
        
        % Method to read the serial port data from the PR670
        serialData = readSerialPortData(obj) 
        
        % Method to write a command to the serial port  of the PR670
        % By default, it appends a carriage return (CR) to the end of the string.  
        % Note that if the CR is already there, it won't be appended. 
        % The CR can be disabled as some commands do not need it.  
        % See the PR-670 documentation for which commands need the CR.
        %
        % Example usage: 
        % obj.writeSerialPortCommand('commandString', 'Q', 'appendCR', false);
        % obj.writeSerialPortCommand('commandString', 'D110');
        writeSerialPortCommand(obj, varargin)
        
        % Method to take a single measurent of the spectral power distribution of the source light
        measureSPD(obj);
        
        % Method to read the configuration of the PR670
        response = getConfiguration(obj);

        % Method to updat ehe obj.privateCurrentConfiguration from the raw response
        generateConfigStruct(obj,response)
        
        % Method to read a response from the PR670 or timeout after timeoutInSeconds
        response = getResponseOrTimeOut(obj, timeoutInSeconds, timeoutString);
        
        % Method to set a new value for the syncMode property
        obj = privateSetSyncMode(obj,newSyncMode);
        
        % Method to set a new value for the cyclesToAverage property
        obj = privateSetCyclesToAverage(obj, newCyclesToAverage);
        
        % Method to set a new value for the sensitivityMode property
        obj = privateSetSensitivityMode(obj, newSensitivityMode);
        
        % Method to set a new value for the exposureTime property
        obj = privateSetExposureTime(obj, newExposureTime);
        
        % Method to set a new value for the apertureSize property
        obj = privateSetApertureSize(obj, newApertureSize);
    end % Private methods
end

