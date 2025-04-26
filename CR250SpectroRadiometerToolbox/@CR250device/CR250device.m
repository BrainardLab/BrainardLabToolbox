classdef CR250device < handle
    % Class to manage a CR250 spectroradiometer. 
    % This is a standalone implementation. There is also a @CR250dev
    % which is a subclass of @Radiometer, for consistency with the other
    % radiometers
    %
    % Syntax:
    %   % Instantiate
    %   myCR250 = CR250device();
    %
    %   % Instantiate
    %   myCR250 = CR250device(...
    %       'devicePortString', '/dev/someTTY', ...
    %       'verbosity', 'max');
    %
    %   % Get device configuration
    %   myCR250.deviceConfig();
    %
    %   % Set sync mode to manual
    %   myCR250.syncMode = 'manual'
    %  
    %   % Measure a spectrum
    %   myCR250.measure('spectrum');
    %
    
    %  History:
    %    April 13, 2025  NPC  Wrote it

    properties (Constant)
        validSyncModes = {...
            'None' ...
            'Manual' ...
            'NTSC' ...
            'PAL' ...
            'CINEMA' ...
        };

        validVerbosityLevels = {...
            'min' ...
            'max' ...
            'default' ...
        };

        validMeasurementTypes = { ...
            'spectrum' ...
        };

    end

    % Public properties
    properties  (GetAccess=public, SetAccess=public)
        name;
        verbosity;
        syncMode;
        manualSyncFrequency;
        showDeviceFullResponse;
        measurementTypeToRetrieve;
    end

    % Read-only private properties
    properties (GetAccess=public, SetAccess=private)
        devicePortString;
        deviceSerialNum;
        firmware;
    end

    % Private properties
    properties (GetAccess=private, SetAccess=private)
    
    end


    % Public methods
    methods
        
        % Constructor
        function obj = CR250device(varargin)
            % Parse input
            p = inputParser;
            p.addParameter('name', 'CR250', @ischar);
            p.addParameter('devicePortString', '',  @(x)(isempty(x)||ischar(x)));
            p.addParameter('verbosity', 'min', @(x)(ismember(x, obj.validVerbosityLevels)));
            p.addParameter('syncMode', 'Manual', @(x)(ismember(x, obj.validSyncModes)));
  
            % Parse input
            p.parse(varargin{:});
            obj.name = p.Results.name;
            obj.devicePortString = p.Results.devicePortString;
            obj.verbosity = p.Results.verbosity;
            obj.showDeviceFullResponse = false;

            if (isempty(obj.devicePortString))
                if (IsLinux)
                    obj.devicePortString = '/dev/ttyACM0';
                else
                    obj.devicePortString = '/dev/tty.usbmodemA009271';
                end
            end

            obj.devicePortString
            pause
            obj.measurementTypeToRetrieve = 'spectrum';

            obj.open();
            obj.syncMode = p.Results.syncMode;

            obj.deviceConfig();

        end  % Constructor


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
            val = obj.syncMode();
        end % get.syncMode

        % Setter for verbosity
        function set.verbosity(obj, val)
            if (ismember(val, obj.validVerbosityLevels))
                obj.verbosity = val;
                switch (val)
                    case 'min'
                        status = CR250_device('setVerbosityLevel', 1);
                    case 'default'
                        status = CR250_device('setVerbosityLevel', 5);
                    case 'max'
                        status = CR250_device('setVerbosityLevel', 10);
                end % switch
            else
                fprintf(2,'Incorrect verbosity level:''%s''. Type CR250dev.validVerbosityLevels to see all available levels.', val);
            end
        end % set.verbosity


        % Method to open the CR250
        open(obj);

        % Method to close the CR250
        close(obj);

        % Method to get the device configuration
        deviceConfig(obj);

        % Method to toggle the echo
        toggleEcho(obj);

        % Method to conduct a measurement
        measure(obj);

        % Method to retrieve a measurements
        [theSpectralSupport, theSpectrum] = retrieveMeasurement(obj);

        % Method to set the device sync mode
        status = setDeviceSyncMode(obj, val)

        % Method to query the CR250 for various infos
        retrieveDeviceInfo(obj, commandID, showFullResponse);

        % Method to retrieve the current syncMode
        [status, response] = retrieveCurrentSyncMode(obj, showFullResponse);

        % Method to retrieve the current manual SYNC frequency
        [status, response] = retrieveCurrentManualSyncFrequency(obj, showFullResponse);

    end % Public methods

    methods (Access=private)
       
        % Method to parse the device response stream
        [parsedResponse, fullResponse, responseIsOK] = parseResponse(obj, response, commandID);
    end

    methods (Static)

        % Method to compile the Mex driver for the CR250
        function compileMexDriver()
            disp('Compiling CR250 device driver ...');
            currentDir = pwd;
            f = which('CR250device');
            mexDriverDir = strrep(f, '@CR250device/CR250device.m', 'MexDriver');
            cd(mexDriverDir);
            mex('CR250_device.c');
            cd(currentDir);
            disp('CR250 device MEX driver compiled sucessfully!');
        end 

    end

end