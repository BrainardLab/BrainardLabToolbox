% Subclass of @Radiometer, specific to the PR670
%
% 3/27/2014  npc   Wrote it.
%

classdef PR650dev < Radiometer
   
    % Public properties (specific to the PR650dev) 
    properties
        % Sync-Mode
        syncMode;
    end
    
    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private)              
        % Handle to communication port
        portHandle = [];
       
        % device files that are known to be for other devices than the PR650
        invalidPortStrings = { 'cu.usbserial-KU000000', 'unspecified' };
        
        % valid ranges for user-settable properties
        validSyncModes  = {'OFF', 'ON'};  
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
            
            % Check BrainardLabToolbox prefs for a customized device port
            % and if there is one use that one
            BLToolboxPrefs = getpref('BrainardLabToolbox');
            if (isfield(BLToolboxPrefs, 'PR650DevicePortString')) && (~isempty(BLToolboxPrefs.PR650DevicePortString))
                fprintf('Overriding passed devPortString (%s) with the one found in BrainardLabToolbox prefs (%s)\n', ...
                    devPortString, BLToolboxPrefs.PR650DevicePortString);
                devPortString = BLToolboxPrefs.PR650DevicePortString;
            end
            
            % Call the super-class constructor.
            obj = obj@Radiometer(verbosity, devPortString, false);
            
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
        
        % PR650-specific configuration options
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
        obj = establishCommunication(obj)
        
        % Method to obtain device-speficic properties of PR-650
        deviceSerialNum = getDeviceSerialNumber(obj)
        
        % Method to read all serial port data
        serialData = readSerialPortData(obj) 

        % Method to read a response or timeout after timeoutInSeconds
        response = getResponseOrTimeOut(obj, timeoutInSeconds, timeoutString);
        
        % Method to measure sync frequency for source.
        syncFreq = measureSyncFreq(obj)
        
        % Method to set sync frequency for source
        % When value = 0, do not use sync mode
        % When value = 1, use last sync measurement
        setSyncFreq(obj, syncFreq)
        
        % Method to take a single measurent of the spectral power distribution of the source light
        measureSPD(obj)
        
        % Method to shutdown the device
        obj = shutDownDevice(obj)
    end  % Private methods 
    
end