classdef PR650dev < Radiometer
   
    % Public properties (specific to the PR650dev) 
    properties
        % Sync-Mode, 'ON' or 'OFF'
        syncMode;
    end
    
    
    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private)              
        % Handle to communication port
        portHandle = [];
       
        % device files that are known to be for other devices than the PR650
        invalidPortStrings = { 'cu.usbserial-KU000000', 'unspecified' };
    end
    % --- END OF PRIVATE PROPERTIES ---------------------------------------
    
    
    % Public methods
    methods
        
        % Constructor
        function obj = PR650dev(varargin)  
            
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
                fprintf('In PR650dev.constructor() method\n');
            end
    
            % Initialize communication
            obj = obj.establishCommunication();

            % Initialize properties
            obj.deviceModelName     = 'PR-650';
            obj.deviceProvidesSpectralMeasurements = true;
            obj.deviceSerialNum     = obj.getDeviceSerialNumber();
            obj.nativeS             = [380 4 101];
            obj.nativeT             = eye(101);
            obj.nativeMeasurement   = struct('energy', [], 'spectralAxis', []);
            obj.userS               = obj.nativeS;
            obj.userT               = obj.nativeT;
            obj.measurement         = [];
            obj.syncMode            = 'OFF';
        end
  
    end % Public methods
    
    
    % Implementations of required -- Public -- Abstract methods defined in the Radiometer interface   
    methods
        % Set PR650-specific options
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
    
        
    methods (Access = private)     
        % Method to initialize communication with the device
        obj = initCommunication(obj);    
        
        % Method to obtain device-speficic properties of PR-650
        deviceSerialNum = getDeviceSerialNumber(obj);
        
        % Method to read all serial port data
        serialData = readSerialPortData(obj) 

        % Method to measure sync frequency for source.
        syncFreq = measureSyncFreq(obj)
        
        % Method to set sync frequency for source
        % When value = 0, do not use sync mode
        % When value = 1, use last sync measurement
        setSyncFreq(obj, syncFreq)
        
        % Method to take a single measurent of the spectral power distribution of the source light
        measureSPD(obj)
        
        % Method to shutdown the device
        obj = shutDownDevice(obj);
    end  % Private methods 
    
end