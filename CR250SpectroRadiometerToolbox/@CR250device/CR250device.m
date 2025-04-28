classdef CR250device < handle
% Class to manage a CR250 spectroradiometer. 
% This is a standalone implementation. It exposes a lot of
% functionality of the CR250, and is used as a testbed for developing
% the MEX driver.
% There is also a @CR250dev class which is a subclass of @Radiometer, 
% which has a less functionality and which is what is used for all calibrations.
%

%  History:
%    April 13, 2025  NPC  Wrote it

% Examples:
%{
    % Compile the MEX driver
    CR250device.compileMexDriver();
%}

%{
    % Open the CR250
    theCR250dev = CR250device(...
        'verbosity', 'max');

    % Current config
    theCR250dev.deviceConfig();

    % Set the verbosity to maximum
    %theCR250dev.verbosity = 'max';

    % See what syncModes are supported
    theCR250dev.validSyncModes

    % Set the sync mode to NTSC
    theCR250dev.syncMode = 'NTSC';

    % Set the sync mode to None
    theCR250dev.syncMode = 'None';

    % Or set it to manual mode with a sync Frequency of 120 Hz;
    theCR250dev.syncMode = 'Manual';
    theCR250dev.manualSyncFrequency = 120.45;

    % Get some info on the device: range of exposureTimes (milliseconds)
    exposureRangeMilliseconds = theCR250dev.exposureTimeRange

    % See what exposureModes are supported
    theCR250dev.validExposureModes

    % Set the exposure model to 'Fixed' (meaning fixed duration)
    theCR250dev.exposureMode = 'Fixed';

    % And set the fixed exposure time to 2000 msec
    theCR250dev.fixedExposureTimeMilliseconds = 2000;

    % Set the exposure model to 'Auto' (meaning automatic duration)
    theCR250dev.exposureMode = 'Auto';



    % See what capture speed modes are supported
    theCR250dev.validSpeedModes

    % Set the capture speed to 'Slow' (to measure a dim light source)
    theCR250dev.speedMode = 'Slow';

    % Set the capture speed to 'Normal' (to measure a medium intensity light source)
    theCR250dev.speedMode = 'Normal';

    % Conduct an SPD measurement. This will start measuring immediately (no delay)
    theCR250dev.measure();

    % Retrieve the SPD measurement
    [theSpectralSupport, theSPD] = theCR250dev.retrieveMeasurement();

    figure(1);
    bar(theSpectralSupport, theSPD, 1);

    % Close the CR250
    theCR250dev.close()

%}


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

    % Public properties
    properties  (GetAccess=public, SetAccess=public)
        commandTriggerDelay;
        name;
        verbosity;
        syncMode;
        exposureMode;
        speedMode;
        manualSyncFrequency;
        fixedExposureTimeMilliseconds;
        showDeviceFullResponse;
        measurementTypeToRetrieve;
    end

    % Read-only private properties
    properties (GetAccess=public, SetAccess=private)
        devicePortString;
        deviceSerialNum;
        firmware;
        exposureTimeRange;
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
            p.addParameter('commandTriggerDelay', 0.3, @isnumeric);
            p.addParameter('devicePortString', '',  @(x)(isempty(x)||ischar(x)));
            p.addParameter('verbosity', 'min', @(x)(ismember(x, obj.validVerbosityLevels)));
            p.addParameter('syncMode', 'None', @(x)(ismember(x, obj.validSyncModes)));
            p.addParameter('speedMode', 'Normal', @(x)(ismember(x, obj.validSpeedModes)));
            p.addParameter('showInfo', false, @istrue);

            % Parse input
            p.parse(varargin{:});
            obj.name = p.Results.name;
            obj.commandTriggerDelay = p.Results.commandTriggerDelay;
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


            % Open the device
            obj.open();

            % Set default properties
            obj.syncMode = p.Results.syncMode;
            obj.speedMode = p.Results.speedMode;
            obj.measurementTypeToRetrieve = 'spectrum';

            if (p.Results.showInfo)
                obj.deviceConfig();
            end
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

        function val = get.manualSyncFrequency(obj)
            showFullResponse = ~true;
            [~,~,val] = obj.retrieveCurrentManualSyncFrequency(showFullResponse);
        end % get.manualSyncFrequency


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


        % Getter for exposureTimeRange
        function val = get.exposureTimeRange(obj)
            showFullResponse = ~true;
            [~,~,minExposure, maxExposure] = obj.retrieveExposureTimeRange(showFullResponse);
            val = [minExposure maxExposure];
        end % get.minExposureTime


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

        % Method to retrieve the units of the radiometric data returned
        retrieveRadiometricUnits(obj);

        % Method to retrieve a measurements
        [theSpectralSupport, theSpectrum] = retrieveMeasurement(obj);

        % Method to set the device sync mode
        status = setDeviceSyncMode(obj, val)

        % Method to set the device manual sync frequency
        status = setDeviceManualSyncFrequency(obj, val);

        % Method to set the device speed mode
        status = setDeviceSpeedMode(obj, val);

        % Method to set the device exposure mode
        status = setDeviceExposureMode(obj, val);

        % Method to set the device fixed exposure time (in milliseconds)
        status = setDeviceFixedExposureTimeMilliseconds(obj, val);

        % Method to query the CR250 for various infos
        retrieveDeviceInfo(obj, commandID, showFullResponse);

        % Method to retrieve the current syncMode
        [status, response, val] = retrieveCurrentSyncMode(obj, showFullResponse);

        % Method to retrieve the current manual SYNC frequency
        [status, response, val] = retrieveCurrentManualSyncFrequency(obj, showFullResponse);

        % Method to retrieve the current speedMode
        [status, response, val] = retrieveCurrentSpeedMode(obj, showFullResponse);

        % Method to retrieve the current exposureMode
        [status, response, val] = retrieveCurrentExposureMode(obj,showFullResponse);

        % Method to retrieve the current fixed exposure time
        [status, response, val] = retrieveCurrentFixedExposureTime(obj, showFullResponse);

        % Method to retrieve the min and max exposure times
        [status, response, minExposure, maxExposure] = retrieveExposureTimeRange(obj, showFullResponse);

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