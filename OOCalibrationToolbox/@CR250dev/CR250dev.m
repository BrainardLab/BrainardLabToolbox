% Subclass of @Radiometer, specific to the CR250.
% This is the class that is used for all calibrations
% There is also a standalone implementation, @CR250device, which is used
% with the CR250interactive.mlapp
%
    
%  History:
%    April 18, 2025  NPC  Wrote it


classdef CR250dev < Radiometer

    % Public properties (specific to the CR250dev) 
    properties
        % Sync-Mode
        syncMode;

        showDeviceFullResponse;
        measurementTypeToRetrieve;

    end

    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private)              
       
        % device files that are known to be for other devices than the PR650
        invalidPortStrings = { 'cu.usbserial-KU000000', 'unspecified' };
        
        % valid ranges for user-settable properties
        validSyncModes = {...
            'None' ...
            'Manual' ...
            'NTSC' ...
            'PAL' ...
            'CINEMA' ...
        };


        validMeasurementTypes = { ...
            'spectrum' ...
        };

    end
    % --- END OF PRIVATE PROPERTIES ---------------------------------------

    % Public methods
    methods
        
        % Constructor
        function obj = CR250dev(varargin)  
            
            parser = inputParser;
            parser.addParameter('verbosity', 1);
            parser.addParameter('showDeviceFullResponse', false, @islogical);
            parser.addParameter('devicePortString', '/dev/tty.usbmodemA009271',  @(x)(isempty(x)||ischar(x)));
            parser.addParameter('emulateHardware', false);

            % Execute the parser
            parser.parse(varargin{:});
            % Create a standard Matlab structure from the parser results.
            p = parser.Results;
            
            verbosity       = p.verbosity;
            devPortString   = p.devicePortString;
            emulateHardware = p.emulateHardware;

            % Check BrainardLabToolbox prefs for a customized device port
            % and if there is one use that one
            BLToolboxPrefs = getpref('BrainardLabToolbox');
            if (isfield(BLToolboxPrefs, 'PR650DevicePortString')) && (~isempty(BLToolboxPrefs.PR650DevicePortString))
                %fprintf('Overriding passed devPortString (%s) with the one found in BrainardLabToolbox prefs (%s)\n', ...
                %    devPortString, BLToolboxPrefs.PR650DevicePortString);
                %devPortString = BLToolboxPrefs.PR650DevicePortString;
            end
            
            % Call the super-class constructor.
            obj = obj@Radiometer(verbosity, devPortString, emulateHardware);
            
            obj.showDeviceFullResponse = p.showDeviceFullResponse;

            if (obj.verbosity > 9)
                fprintf('In CR250dev.constructor() method\n');
            end
    
            if (obj.emulateHardware)
                return;
            end

            % Initialize communication
            obj = obj.establishCommunication();

            % Initialize properties
            obj.deviceModelName     = 'CR-250';
            obj.deviceProvidesSpectralMeasurements = true;
            obj.deviceSerialNum     = obj.getDeviceSerialNumber();
            obj.nativeS             = [380 2 201];
            obj.nativeT             = eye(obj.nativeS(3));
            obj.nativeMeasurement   = struct('energy', [], 'spectralAxis', []);
            obj.userS               = obj.nativeS;
            obj.userT               = obj.nativeT;
            obj.measurement         = [];
            obj.syncMode            = 'None';
            
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
        obj = establishCommunication(obj);
        
        % Method to parse responses of the CR-250
        [parsedResponse, fullResponse, responseIsOK] = parseResponse(obj, response, commandID)

        % Method to obtain device-speficic properties of CR-250
        deviceSerialNum = getDeviceSerialNumber(obj);
        
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
        measureSPD(obj);
        
        % Method to shutdown the device
        obj = shutDownDevice(obj)
    end  % Private methods 
    

end

