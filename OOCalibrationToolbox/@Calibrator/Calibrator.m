% Abstract class (interface) for all Calibrator-type objects:
% i.e., mgl-based, psychtoolbox-based etc. All subclasses of
% Calibrator must implement the methods defined here, but the
% implementation may be different for am mgl-based stimulus generation
% vs a psychtoolbox-based stimulus generation. By using an abstract superclass 
% we enfore consistency amongst all subclasses. 
% Also all subclasses  must specify the properties defined here.
% The data contained in these properties may differ from one
% class to another but their names must be the same.
%
% 3/27/2014  npc   Wrote it.
%

classdef Calibrator < handle
    % Public access. All Calibrator subclasses inherit these properties.
    % Subclass users can set these properties, so these are public.
    properties
        
    end % Public properties
    
    properties (Dependent = true)
        % A CalibratorOptions struct with various options that can be set.
        % To see all the available options type: doc CalibratorOptions.
        options;
        
        % Structure with all the information need to conduct a calibration.
        cal;
    end % Dependent properties
    
    % Public read-only access. % Subclass users can read/write these properties.
    properties (SetAccess = protected)  
        % Type of graphics engine used, 'MGL', or 'PTB-3'
        graphicsEngine = 'uspecified';
        
        % Name of executive script that assembles the Calibrator
        % and the Radiometer object. Specified during object instantiation only.
        executiveScriptName = 'unspecified';
        
        % Name of file in which the cal struct is saved.
        calibrationFile = 'default.mat';
        
        % Revision of calibration struct (OOP version starts at 2.0) 
        calStructRevisionNo = 2.0;
        
        % Handle to the Radiometer object which that acquires the
        % measurements. Specified during object instantiation only.
        radiometerObj = [];
        
        % description of ALL attached displays
        displaysDescription = [];
        
        % description of display to be calibrated
        screenInfo = struct('screenSizePixel', [], 'refreshRate', []);
        
        % Screen ID on which the calibration is run on, 1 = main screen. 
        % Specified during object instantiation only.
        screenToCalibrate = 2;
        
        % Expected screen size (width, height) in pixels.
        % Specified during object instantiation only.
        desiredScreenSizePixel = [1920 1080];
        
        % Expected screen refresh rate (Hz).
        % Specified during object instantiation only.
        desiredRefreshRate = 60;

        % David Hoffman's addition for 240Hz Samsung panel
        % If it is set to 4, it will use the 10 bit temporal dither
        % available on the 240Hz OLED display
        % Defaults to single frame (no temporal dither)
        displayTemporalDither=1;

        % Type of display device, e.g., 'monitor', 'projector', etc.
        % Specified during object instantiation only.
        displayDeviceType = 'unspecified';
        
        % Name of the display device.
        % Specified during object instantiation only.
        displayDeviceName = 'unspecified';
        
        % Number of primaries in display device, for a regular monitor, 3.
        % Specified during object instantiation only.
        displayPrimariesNum = 'unspecified';
        
        % Comment relevant to the instantiated calibrator object
        comment = 'none';
    end
    
    
    % The class-user has no need to access these properties directly so they are protected
    properties (SetAccess = protected, GetAccess = protected) 
        
        % Rectangle defining calibration region on the monitor
        calibrationRect;
        
        % number of channels of the attached @Radiometer device
        measurementChannelsNum;
        
        % A @CalibratorRawData object containing all the performed measurements
        % Computed by the calibrate() method.
        rawData = [];
        
        % processed data from fitting the rawData
        processedData = []; 
    end
    
    % Private properties. These must be specified at initialization time
    properties (Access = private)
       
        % Basic info about the host computer
        computerInfo = [];
        svnInfo      = [];
        matlabInfo   = [];
            
        % The radiometer's model name and serial no
        calibrationDeviceModelName = 'unspecified';
        calibrationDeviceSerialNum = 'unspecified';
        
        privateOptions = CalibratorOptions;
        
        privateCal;
    end % private properties
        
    % Other private properties
    properties (Access = private)
        
    end

    % Abstract -- public -- methods. Each subclass has to implenent its own
    % version. If it does not, it cannot instantiate objects.
    methods(Abstract)
        % Method to conduct a calibration sequency
        obj = calibrate(obj)  
    
        % Method to ensure that the parameters of the screen match those specified by the user
        obj = verifyScreenParamValues(obj)
        
        % Method to shutdown the calibrator
        obj = shutdown(obj)
    end
    
    % Protected, so that Calibrator subclasses can call these methods
    methods (Access = protected)

    end
    
    % Public methods
    methods
        
        % Constructor
        function obj = Calibrator(initParams) 
            % Configure an inputParser to examine whether the options passed to us are valid
            parser = inputParser;
            parser.addParamValue('executiveScriptName',             obj.executiveScriptName);
            parser.addParamValue('calibrationFile',                 obj.calibrationFile);
            parser.addParamValue('radiometerObj',                   obj.radiometerObj);
            parser.addParamValue('screenToCalibrate',               obj.screenToCalibrate);
            parser.addParamValue('desiredRefreshRate',              obj.desiredRefreshRate);
            parser.addParamValue('displayTemporalDither',           obj.displayTemporalDither);
            parser.addParamValue('desiredScreenSizePixel',          obj.desiredScreenSizePixel);
            parser.addParamValue('displayDeviceType',               obj.displayDeviceType);
            parser.addParamValue('displayPrimariesNum',             obj.displayPrimariesNum);
            parser.addParamValue('displayDeviceName',               obj.displayDeviceName);
            parser.addParamValue('comment',                         obj.comment);
            % Execute the parser
            parser.parse(initParams{:});
            % Create a standard Matlab structure from the parser results.
            parserResults = parser.Results;
            pNames = fieldnames(parserResults);
            for k = 1:length(pNames)
                obj.(pNames{k}) = parserResults.(pNames{k}); 
            end

            if (obj.options.verbosity > 9)
                fprintf('In Calibrator.constructor() method\n');
            end
            
            if (~isempty(obj.radiometerObj))
                % set the calibration device model name and serial number
                obj.calibrationDeviceModelName = obj.radiometerObj.deviceModelName;
                obj.calibrationDeviceSerialNum = obj.radiometerObj.deviceSerialNum;
                           
                % determine the sensors of the attached @Radiometer device
                if (obj.radiometerObj.deviceProvidesSpectralMeasurements)
                    % spectral device
                    obj.measurementChannelsNum = obj.radiometerObj.nativeS(3);
                else
                    % colorimetric device, 3 sensors (XYZ)
                    obj.measurementChannelsNum = 3;
                end
            end
            
            % Get computer info
            a = GetComputerInfo;
            obj.computerInfo = sprintf('%s''s %s, %s', a.userShortName, a.localHostName, a.OSVersion);
            
            % Get SVN info
            a = GetBrainardLabStandardToolboxesSVNInfo;
            obj.svnInfo    = a.svnInfo;
            obj.matlabInfo = a.matlabInfo;
            clear 'a'
        end
        
        
        % Setter for dependent property options
        function set.options(obj, updatedOptions)
            if isa(updatedOptions, 'CalibratorOptions')
                
                % check displayPrimariesNum for consistency with other variables
                if (obj.displayPrimariesNum ~= length(updatedOptions.fgColor))
                    error('Calibrator property ''displayPrimariesNum'' does not agree with the length of the ''options.fgColor'' value.');
                end
                
                if (obj.displayPrimariesNum ~= length(updatedOptions.bgColor))
                    error('Calibrator property ''displayPrimariesNum'' does not agree with the length of the ''options.bgColor'' value.');
                end
                
                if (obj.displayPrimariesNum ~= size(updatedOptions.basicLinearitySetup.settings,1))
                    error('Calibrator property ''displayPrimariesNum'' does not agree with the rows of the ''options.basicLinearitySetup.settings'' matrix');
                end
                
                if (obj.displayPrimariesNum ~= size(updatedOptions.backgroundDependenceSetup.settings,1))
                    error('Calibrator property ''displayPrimariesNum'' does not agree with the rows of the ''options.backgroundDependenceSetup.settings'' matrix');
                end
                
                if (obj.displayPrimariesNum ~= size(updatedOptions.backgroundDependenceSetup.bgSettings,1))
                    error('Calibrator property ''displayPrimariesNum'' does not agree with the rows of the ''options.backgroundDependenceSetup.bgSettings'' matrix');
                end
                
                obj.privateOptions = updatedOptions;
            else
                error('Options must be a ''CalibratorOptions'' object.');
            end
        end
        
        % Getter for dependent property 'options'
        function options = get.options(obj)
            options = obj.privateOptions;
        end
        
        
        % Setter method for property cal.
        % Used to reset the object state of the @Calibrator (usually to re-analyze the data)
        function set.cal(obj, newCal)      
            % Set private copy of cal
            obj.privateCal = newCal;
            
            if (isempty(newCal))
                return;
            end
            
            % update state of @Calibrator properties based on newCal
            
            % Various info about host computer and radiometer used
            obj.computerInfo = obj.privateCal.describe.computerInfo;
            obj.svnInfo      = obj.privateCal.describe.svnInfo;
            obj.matlabInfo   = obj.privateCal.describe.matlabInfo;
            obj.calibrationDeviceModelName = obj.privateCal.describe.meterModel;
            obj.calibrationDeviceSerialNum = obj.privateCal.describe.meterSerialNumber;
        
            % The measurementChannelsNum property
            obj.measurementChannelsNum  = size(obj.privateCal.rawData.gammaCurveMeanMeasurements,3);
            
            % The various descriptive properties
            obj.graphicsEngine          = obj.privateCal.describe.graphicsEngine;
            obj.executiveScriptName     = obj.privateCal.describe.executiveScriptName;
            obj.calibrationFile         = obj.privateCal.describe.calibrationFile;
            obj.calStructRevisionNo     = obj.privateCal.describe.calStructRevisionNo;
            obj.radiometerObj           = [];  % set radiometer object to empty if we are loading an existing cal
            obj.displaysDescription     = obj.privateCal.describe.displaysDescription;
            obj.screenInfo              = obj.privateCal.describe.screenInfo;
            obj.screenToCalibrate       = obj.privateCal.describe.whichScreen;
            obj.desiredScreenSizePixel  = obj.privateCal.describe.screenSizePixel;
            obj.desiredRefreshRate      = obj.privateCal.describe.hz;
            obj.displayDeviceType       = obj.privateCal.describe.displayDeviceType;
            obj.displayDeviceName       = obj.privateCal.describe.displayDeviceName;
            obj.displayPrimariesNum     = obj.privateCal.describe.displayPrimariesNum;
            obj.comment                 = obj.privateCal.describe.comment;
        
            % The options property
            obj.options = CalibratorOptions( ...
                'verbosity',                        2, ...
                'whoIsDoingTheCalibration',         obj.privateCal.describe.who, ...
                'emailAddressForDoneNotification',  obj.privateCal.describe.doneNotificationEmail, ...
                'blankOtherScreen',                 obj.privateCal.describe.blankOtherScreen, ...
                'whichBlankScreen',                 obj.privateCal.describe.whichBlankScreen, ...
                'blankSettings',                    obj.privateCal.describe.blankSettings, ...
                'bgColor',                          obj.privateCal.describe.bgColor, ...
                'fgColor',                          obj.privateCal.describe.fgColor, ...
                'meterDistance',                    obj.privateCal.describe.meterDistance, ...
                'leaveRoomTime',                    obj.privateCal.describe.leaveRoomTime, ...
                'nAverage',                         obj.privateCal.describe.nAverage, ...       
                'nMeas',                            obj.privateCal.describe.nMeas, ...         
                'boxSize',                          obj.privateCal.describe.boxSize, ...
                'boxOffsetX',                       obj.privateCal.describe.boxOffsetX, ...              
                'boxOffsetY',                       obj.privateCal.describe.boxOffsetY, ...
                'primaryBasesNum',                  obj.privateCal.describe.primaryBasesNum, ...
                'gamma',                            obj.privateCal.describe.gamma... 
                );
            
            % The raw data property
            obj.rawData = obj.privateCal.rawData;
            
            % The processed data property
            obj.processedData = obj.privateCal.processedData;
        end
        
        % Getter method for dependent property 'cal'
        function cal = get.cal(obj)   

            % Generate cal struct
            calDescriptor = struct( ...
                'who',                      obj.options.whoIsDoingTheCalibration, ...
                'doneNotificationEmail',    obj.options.emailAddressForDoneNotification, ...
                'date',                     sprintf('%s %s',date,datestr(now,14)), ...
                'computerInfo',             obj.computerInfo, ...
                'svnInfo',                  obj.svnInfo, ...
                'matlabInfo',               obj.matlabInfo, ...
                'executiveScriptName',      obj.executiveScriptName, ...
                'driver',                   sprintf('object-oriented calibration'), ...
                'graphicsEngine',           obj.graphicsEngine, ...
                'calStructRevisionNo',      obj.calStructRevisionNo, ...
                'calibrationFile',          obj.calibrationFile, ...
                'displaysDescription',      obj.displaysDescription, ...
                'whichScreen',              obj.screenToCalibrate, ...
                'comment',                  obj.comment, ...  
                'displayDeviceType',        obj.displayDeviceType, ...       
                'displayDeviceName',        obj.displayDeviceName, ...
                'displayPrimariesNum',      obj.displayPrimariesNum, ...
                'blankOtherScreen',         obj.options.blankOtherScreen, ...
                'whichBlankScreen',         obj.options.whichBlankScreen, ...
                'blankSettings',            obj.options.blankSettings, ...
                'hz',                       obj.screenInfo.refreshRate, ...
                'screenSizePixel',          obj.screenInfo.screenSizePixel, ...
                'screenInfo',               obj.screenInfo, ...
                'meterModel',               obj.calibrationDeviceModelName, ...
                'meterSerialNumber',        obj.calibrationDeviceSerialNum, ...
                'meterDistance',            obj.options.meterDistance, ...
                'leaveRoomTime',            obj.options.leaveRoomTime, ...
                'nAverage',                 obj.options.nAverage, ...
                'nMeas',                    obj.options.nMeas, ...                   % number of samples in the [0..1] range (RGB settings)
                'boxSize',                  obj.options.boxSize, ...                 % adjust to the size of the target.
                'boxOffsetX',               obj.options.boxOffsetX, ...              % x offset (in pixels) of square on screen (used to check off-axis monitor properties)
                'boxOffsetY',               obj.options.boxOffsetY, ...              % y offset (in pixels) of square on screen (used to check off-axis monitor properties)
                'bgColor',                  obj.options.bgColor, ...
                'fgColor',                  obj.options.fgColor, ...
                'primaryBasesNum',          obj.options.primaryBasesNum, ...
                'gamma',                    obj.options.gamma, ...
                'useBitsPP',                0, ...
                'dacsize',                  8 ...   
                );
            
                % Form calibration struct
                obj.privateCal = struct(...
                            'describe',                     calDescriptor, ...
                            'basicLinearitySetup',          obj.options.basicLinearitySetup, ...
                            'backgroundDependenceSetup',    obj.options.backgroundDependenceSetup,...
                            'rawData',                      obj.rawData, ...
                            'processedData',                obj.processedData ...
                          );
                      
                cal = obj.privateCal;
        end  
        
        % Method to display the cal struct
        displayCalStruct(obj);
        
        % Method to export the cal struct in the old format (compatibility
        % mode)
        exportOldFormatCal(obj);
    end % public methods
    
    % Public static methods.  These are useful functions that can be called
	% without having to instantiate a @Calibrator object first
	methods (Static)
        oldFormatCalStruct = calStructWithOldFormat(obj, newFormatCalStruct);
    end % static methods
    
    
    % The class-user has no need to call these methods, but our subclasses may.
    methods (Access = protected)
        % Method to generate a calibration rectabgle
        calibrationRect = generateCalibrationRect(obj);
        
        % Method to prompt the user about leaving the room
        promptUserToLeaveTheRoom(obj, userPrompt);
        
        % Method to prompt the user that the calibration is done
        promptUserThatCalibrationIsDone(obj,beepWhenDone);
        
        % Method to set the notification settings
        setNotificationPreferences(obj);
        
        % Method to process the rawData and compute the processedData property
        processRawData(obj);
        
        % Method to fit a linear model to the raw gamma data obtained
        fitLinearModel(obj);
        
        % Method to fit the raw gamma data obtained
        fitRawGamma(obj, nInputLevels);
        
        % Method to update cal struct with ambient stuff
        addAmbientData(obj);
    
        % Method that puts up a plot of the essential data
        plotBasicMeasurements(obj);
    end % methods (Access = protected)
    
    
    % Private methods
    methods (Access = private)
               
    end  % private methods
    
    
end  % classdef
