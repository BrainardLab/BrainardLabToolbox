classdef Radiometer < handle
% Abstract class (interface) for all Radiometer-type objects:
% i.e., spectro-radiometers or colorimeters. All subclasses of
% Radiometer must implement the methods defined here, but the
% implementation may be different for a spectro-radiometer vs
% a colorimeter class. By using an abstract superclass we 
% enfore consistency amongst all subclasses. 
% Also all subclasses  must specify the properties defined here.
% The data contained in these properties may differ from one
% class to another but their names must be the same.

    % Public access.
    properties
    end % Public properties

    % Protected properties. All Radiometer subclasses can read these, but they cannot set them. 
    properties (SetAccess = protected)
        % Verbosity level (1 = minimal, 10 = max)
        verbosity
        
        % Information on the Radiometer's host computer and enviromnent
        hostInfo
        
        % the model name of the device
        deviceModelName   
        
        % the serial number of the device
        deviceSerialNum  
        
        % flag indicating whether the @Radiometer device provides spectral
        % measurements (true) or colorimeteric measurements (false)
        deviceProvidesSpectralMeasurements
        
        % the native spectral sampling of the device, in the form in the
        % form [FirstSample SampleIntervalInNm NspectralSamples], e.g. [380 4 101]
        nativeS   
        
        % the native sensor matrix (Msensors x NspectralSamles)
        % e.g., 101 x 101 for a radiometer, 3 x 101 for an XYZ colorimeter 
        nativeT       
        
        % the last native measuremnt camptured by the device
        nativeMeasurement       
        
        % user-specified spectral sampling
        userS
        
        % user-specified spectral sensor matrix
        userT
        
        % the last measurement after application of userS, userT to the last native measurement
        measurement     
        
        % the quality associated with the last measurement
        measurementQuality
    end
    
    % The class-user has no need to access these properties directly so they are protected
    properties (SetAccess = protected, GetAccess = protected)
        % The port string, i.e. /dev/cu.KeySerial1 
        portString;
        
        % Names and valid values for the user-settable configurations of
        % the radiometer - these are hardware-specific, so they are set by the subclasses
        availableConfigurationOptionNames;
        availableConfigurationOptionValidValues;
    end
    
    % Private properties
    properties (Access = private)
        % List of serial port devices to look for.
        portDeviceNames = { lower('keyserial1'), lower('usbmodem'), lower('usbserial'), lower('cu.USA') };
    
        % Enumerate cu* devices - they correspond to serial ports:
        portDeviceFiles = dir('/dev/cu*');
        
        % Private Verbosity
        privateVerbosity;
        
    end % private properties
    
    % Abstract, public methods. Each subclass *must* implenent its own
    % version of all functions listed as abstract. If it does not, 
    % it cannot instantiate any objects.
    methods(Abstract)
        
        % Method to set device-specific configuration options
        obj = setOptions(obj, varargin);
        
        % Method to conduct a single native measurement;
        result = measure(obj);
        
        % Functions to separate the measure() command into two separate components:
        % triggerMeasure() and getMeasuredData().
        % This is useful if we want to have more than one radiometers measure simulteneously
        triggerMeasure(obj);
        result = getMeasuredData(obj);
        
        % Method to shutdown the Radiometer
        shutDown(obj);
    end
    
    % Public methods
    methods
        % Constructor
        function obj = Radiometer(verbosity, devPortString)
            
            obj.verbosity = verbosity;
            if ~isempty(devPortString)
                obj.portString = devPortString;
            else
                obj = obj.privateGetPortString();
            end
            
            if (obj.verbosity > 9)
                fprintf('In Radiometer.constructor() method\n');
            end

        end
        
        % Setter method for property verbosity
        function set.verbosity(obj, new_verbosity)
            obj.privateSetVerbosity(new_verbosity);
            %fprintf('\nNew verbosity level: %d\n', obj.verbosity);
        end
        
        % Getter method for property verbosity
        function verbosity = get.verbosity(obj)
            verbosity = obj.privateVerbosity;
        end
        
        
        % Getter method for property hostInfo
        function hostInfo = get.hostInfo(obj)
            hostInfo = obj.privateGetHostInfo();
        end    
        
        % Method to list the avaible configuration options and their valid ranges
        listConfigurationOptions(obj);
        
    end % public methods
     

    % The class-user has no need to call these methods, but our subclasses may.
    methods (Access = protected)
        % Method to check the validity of the selected port
        invalidPort = checkPortValidity(obj, invalidPortStrings)   
        
        % Method to transform a native measurement according to params passed
        measurement = adjustMeasurement(obj, varargin);
        
        % Method to check if two values are same
        isTrue = valuesAreSame(obj,newValue, oldValue);
    end % methods (Access = protected)
    
    
    % Private methods
    methods (Access = private)
        % Method to search all known portDeviceNames to determine
        % whether there is a match for the attached serial devices.
        obj = privateGetPortString(obj)

        % Method to get SVN, matlab, and computer info
        hostInfo = privateGetHostInfo(obj)

        % Method to set the verbosity level
        verbosity = privateSetVerbosity(obj,new_verbosity)
    end 
end  % classdef
