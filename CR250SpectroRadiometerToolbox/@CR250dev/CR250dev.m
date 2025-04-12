classdef CR250dev < handle
    % CR250dev

    properties (Constant)
        validSyncModes = {...
            'none' ...
            'auto' ...
            'manual' ...
            'NTSC' ...
            'PAL' ...
            'CINEMA' ...
        };

        validVerbosityLevels = {...
            'min' ...
            'max' ...
            'default' ...
        };
    end

    % Public properties
    properties  (GetAccess=public, SetAccess=public)
        name;
        verbosity;
        syncMode;
    end

    % Read-only private properties
    properties (GetAccess=public, SetAccess=private)
        serialDevicePortName
    end

    % Private properties
    properties (GetAccess=private, SetAccess=private)
    
    end


    % Public methods
    methods
        
        % Constructor
        function obj = CR250dev(varargin)
            % Parse input
            p = inputParser;
            p.addParameter('name', 'CR250', @ischar);
            p.addParameter('serialDevicePortName', '/dev/tty.usbmodemA009271', @ischar);
            p.addParameter('verbosity', 'min', @(x)(ismember(x, obj.validVerbosityLevels)));
            p.addParameter('syncMode', 'auto', @(x)(ismember(x, obj.validSyncModes)));
  
            % Parse input
            p.parse(varargin{:});
            obj.name = p.Results.name;
            obj.serialDevicePortName = p.Results.serialDevicePortName;
            obj.verbosity = p.Results.verbosity;
            obj.syncMode = p.Results.syncMode;
        end  % Constructor


        % Setter for syncMode
        function set.syncMode(obj, val)
            obj.setSyncMode(val);
        end % set.syncMode

        % Getter for syncMode
        function val = get.syncMode(obj)
            val = obj.retrieveCurrentSyncMode();
        end % set.syncMode

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

    end % Public methods

    methods (Access=private)
        % Method to parse the device response stream
        [parsedResponse, fullResponse] = parseResponse(obj, response, commandID);

        % Method to query the CR250 for various infos
        retrieveDeviceInfo(obj, commandID, showFullResponse);

        % Method to retrieve the current syncMode
        val = retrieveCurrentSyncMode(obj);
    end

    methods (Static)

        % Method to compile the Mex driver for the CR250
        function compileMexDriver()
            disp('Compiling CR250 device driver ...');
            currentDir = pwd;
            f = which('CR250dev');
            mexDriverDir = strrep(f, '@CR250dev/CR250dev.m', 'MexDriver');
            cd(mexDriverDir);
            mex('CR250_device.c');
            cd(currentDir);
            disp('CR250 device MEX driver compiled sucessfully!');
        end 

    end

end