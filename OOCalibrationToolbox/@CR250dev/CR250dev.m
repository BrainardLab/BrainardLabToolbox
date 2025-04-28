% Subclass of @Radiometer, specific to the CR250.
% This is the class that is used for all calibrations
% There is also a standalone implementation, @CR250device, which is used
% with the CR250interactive.mlapp
%
    
%  History:
%    April 18, 2025  NPC  Wrote it


classdef CR250dev < Radiometer

    properties (Constant)
        validSyncModes = {...
            'None' ...
            'Manual' ...   % Manual frequency: User can set a custom SYNC frequency in the range 10Hz - 10KHz
            'NTSC' ...
            'PAL' ...
            'CINEMA' ...
        };

        validSpeedModes = { ...
            'Slow'    ... % for measuring very low light levels
            'Normal'  ... % recommended for most measurements
            'Fast'    ... % measuring medium light levels
            '2x Fast'  ... % measuring high light levels
        };

        validExposureModes = {
            'Auto' ...    % automatic exposure mode
            'Fixed' ...   % fixed exposure mode. User can set a custom exposure time in milliseconds
            }

        validVerbosityLevels = {...
            'min' ...
            'max' ...
            'default' ...
        };

        validMeasurementTypes = { ...
            'spectrum' ...
        };

    end

    % Public properties (specific to the CR250dev) 
    properties
        commandTriggerDelay;
        name;
        syncMode;
        exposureMode;
        speedMode;
        manualSyncFrequency;
        fixedExposureTimeMilliseconds;
        showDeviceFullResponse;
        measurementTypeToRetrieve;
    end

    % --- PRIVATE PROPERTIES ----------------------------------------------
    properties (Access = private)              
       
        % device files that are known to be for other devices than the PR650
        invalidPortStrings = { 'cu.usbserial-KU000000', 'unspecified' };


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

            % Set the MEX driver's verbosity level
            status = CR250_device('setVerbosityLevel', obj.verbosity);

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

            % Defaults
            obj.commandTriggerDelay = 0.3;

            obj.syncMode            = 'None';
            %obj.manualSyncFrequency = 120;

            %obj.speedMode           = 'Normal';
            %obj.fixedExposureTimeMilliseconds = 500;

            %obj.exposureMode        = 'Auto';



            % Initialize protected properties
            obj.availableConfigurationOptionNames       = {'syncMode',        'manualSyncFrequency', 'speedMode',         'exposureMode',         'fixedExposureTimeMilliseconds'};
            obj.availableConfigurationOptionValidValues = {obj.validSyncModes, [],                   obj.validSpeedModes, obj.validExposureModes, []};
        end
  


        % Setter for syncMode
        function set.syncMode(obj, val)
            status = obj.setDeviceSyncMode(val);
            if (status == 0)
                obj.syncMode = val;
            else
                fprintf(2, 'Failed to set the device syncMode to %s\n', val);
            end
        end % set.syncMode

        % Getter for syncMode
        function val = get.syncMode(obj)
            showFullResponse = false;
            [~,~,val] = retrieveCurrentSyncMode(obj, showFullResponse);
        end % get.syncMode


        % Setter for manualSyncFrequency
        function set.manualSyncFrequency(obj, val)
            % First set the sync mode to manual
            status = obj.setDeviceSyncMode('Manual');

            if (status == 0)
                status = obj.setDeviceManualSyncFrequency(val);
                if (status == 0)
                    obj.manualSyncFrequency = val;
                else
                    fprintf(2, 'Failed to set the device manual SYNC frequency to %2.2f\n', val);
                end
            end
        end % set.manualSyncFrequency;

        % Getter for manualSyncFrequency
        function val = get.manualSyncFrequency(obj)
            showFullResponse = ~true;
            [~,~,val] = obj.retrieveCurrentManualSyncFrequency(showFullResponse);
        end % get.manualSyncFrequency


        % Setter for speedMode
        function set.speedMode(obj, val)
            status = obj.setDeviceSpeedMode(val);
            if (status == 0)
                obj.speedMode = val;
            else
                fprintf(2, 'Failed to set the device speedMode to %s\n', val);
            end
        end % set.speedMode

        % Getter for speedMode
        function val = get.speedMode(obj)
            showFullResponse = false;
            [~, ~, val] = retrieveCurrentSpeedMode(obj, showFullResponse);
        end % get.speedMode


        % Setter for exposureMode
        function set.exposureMode(obj, val)
            status = obj.setDeviceExposureMode(val);
            if (status == 0)
                obj.exposureMode = val;
            else
                fprintf(2, 'Failed to set the device exposure Mode to %s\n', val);
            end
        end % set.exposureMode

        % Getter for exposureMode
        function val = get.exposureMode(obj)
            showFullResponse = false;
            [~, ~, val] = retrieveCurrentExposureMode(obj, showFullResponse);
        end % get.exposureMode

        % Setter for fixedExposureTimeMilliseconds
        function set.fixedExposureTimeMilliseconds(obj, val)
            % First set the exposure mode to fixed
            status = obj.setDeviceExposureMode('Fixed');

            if (status == 0)
                status = obj.setDeviceFixedExposureTimeMilliseconds(val);
                if (status == 0)
                    obj.fixedExposureTimeMilliseconds = val;
                else
                    fprintf(2, 'Failed to set the device fixed exposure time to %2.0f milliseconds\n', val);
                end
            end
        end % set.fixedExposureTimeMilliseconds;

        % Getter for fixedExposureTimeMilliseconds
        function val = get.fixedExposureTimeMilliseconds(obj)
            showFullResponse = ~true;
            [~,~,val] = obj.retrieveCurrentFixedExposureTime(showFullResponse);
        end % get.fixedExposureTimeMilliseconds

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
        
        % Methods to set/get the CR250 sync mode
        status = setDeviceSyncMode(obj, val);
        [status, response, val] = retrieveCurrentSyncMode(obj, showFullResponse);

        % Methods to set/get the manual SYNC frequency
        status = setDeviceManualSyncFrequency(obj, val);
        [status, response, val] = retrieveCurrentManualSyncFrequency(obj, showFullResponse);

        % Methods to set/get the capture speed mode
        status = setDeviceSpeedMode(obj, val);
        [status, response, val] = retrieveCurrentSpeedMode(obj, showFullResponse);

        % Methods to set/get the exposure mode
        status = setDeviceExposureMode(obj, val);
        [status, response, val] = retrieveCurrentExposureMode(obj, showFullResponse);

        % Methods to set/get the fixedExposureTimeMilliseconds
        status = setDeviceFixedExposureTimeMilliseconds(obj, val);
        [status, response, val] = retrieveCurrentFixedExposureTime(obj, showFullResponse);

        % Method to get the device's exporture time range
        [status, response, minExposure, maxExposure] = retrieveExposureTimeRange(obj, showFullResponse);

        % Method to take a single measurent of the spectral power distribution of the source light
        measureSPD(obj);
        
        % Method to shutdown the device
        obj = shutDownDevice(obj);

        function p = verbosityIsNotMinimum(obj)
            p = (obj.verbosity > 1);
        end

    end  % Private methods 
    

end

