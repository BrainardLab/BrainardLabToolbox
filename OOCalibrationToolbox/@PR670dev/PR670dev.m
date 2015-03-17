classdef PR670dev < Radiometer
   
    % Public properties (specific to the PR670dev) 
    properties
        % SyncMode: see obj.validSyncModes
        syncMode;

        % cycles to average : see obj.validCyclesToAverage
        cyclesToAverage;
        
        % sensitivityMode: see obj.validSensitivityModes
        sensitivityMode;
        
        % apertureSize; see: obj.validApertureSizes
        apertureSize;
    end
    
    properties (SetAccess = private)
        validSyncModes          = {'OFF', 'AUTO', [20 400]};
        validCyclesToAverage    = [1 99];
        validSensitivityModes   = {'STANDARD', 'EXTENDED'};  % 'STANDARD' (exposure range: 6 - 6,000 msec, 'EXTENDED' exposure range: 6 - 30,000 msec
        validApertureSizes      = {'1 DEG', '1/2 DEG', '1/4 DEG', '1/8 DEG'};
    end
    
    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private)              
        % Handle to communication port
        portHandle = [];
       
        % Device files that are known to be for other devices than the PR670
        invalidPortStrings = { 'cu.usbserial-KU000000', 'unspecified' };
        
        % Private syncMode
        privateSyncMode;
        
        % Private cyclesToAverage
        privateCyclesToAverage;
        
        % Private sensitivityMode
        privateSensitivityMode;
        
        % Private sapertureSize
        privateApertureSize;
    end
    % --- END OF PRIVATE PROPERTIES ---------------------------------------
    
    % Public methods
    methods
        
        % Constructor
        function obj = PR670dev(varargin)  
            parser = inputParser;
            parser.addParamValue('verbosity',   1);
            parser.addParamValue('devicePortString',  []);
            
            % Execute the parser
            parser.parse(varargin{:});
            % Create a standard Matlab structure from the parser results.
            p = parser.Results;
            verbosity       = p.verbosity;
            devPortString   = p.devicePortString;
            
            % Call the super-class constructor.
            obj = obj@Radiometer(verbosity, devPortString);
            
            if (obj.verbosity > 9)
                fprintf('In PR670dev.constructor() method\n');
            end
            
            % Initialize communication
            obj = obj.establishCommunication();

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
            
            % Initialize default options
            obj.privateSyncMode         = obj.validSyncModes{1}; 
            obj.privateCyclesToAverage  = obj.validCyclesToAverage(1);
            obj.privateSensitivityMode  = obj.validSensitivityModes{1};
            obj.privateApertureSize     = obj.validApertureSizes{1};
        end % Constructor
        
    end % Public methods
    
    % Implementations of required -- Public -- Abstract methods defined in the Radiometer interface   
    methods
        % Set PR670-specific options
        obj = setOptions(obj, varargin);
        
        % Method to conduct a single native measurent. For the PR-650 this is an SPD measurement.
        result = measure(obj, varargin);    
        
        % Functions to separate the measure() command into two separate components:
        % triggerMeasure() and getMeasuredData().
        % This is useful if we want to have more than one radiometers measure simulteneously
        triggerMeasure(obj);
        result = getMeasuredData(obj);
         
        obj = shutDown(obj);  
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
        
        % Getter method for property cyclesToAverage
        function value = get.sensitivityMode(obj)
            value = obj.privateSensitivityMode;
        end
        
       
        % Setter method for property apertureSize
        function set.apertureSize(obj, newApertureSize)
            obj.privateSetApertureSize(newApertureSize);
        end
        
        % Getter method for property apertureSize
        function value = get.apertureSize(obj)
            value = obj.privateApertureSize;
        end
    end
    
    
    methods (Access = private)     
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
        config = getConfiguration(obj);

        % Method to read a response from the PR670 or timeout after timeoutInSeconds
        response = getResponseOrTimeOut(obj, timeoutInSeconds, timeoutString);
        
        % Method to set a new value for the syncMode property
        obj = privateSetSyncMode(obj,newSyncMode);
        
        % Method to set a new value for the cyclesToAverage property
        obj = privateSetCyclesToAverage(obj, newCyclesToAverage);
        
        % Method to set a new value for the sensitivityMode property
        obj = privateSetSensitivityMode(obj, newSensitivityMode);
        
        % Method to set a new value for the apertureSize property
        obj = privateSetApertureSize(obj, newApertureSize);
    end % Private methods
end

