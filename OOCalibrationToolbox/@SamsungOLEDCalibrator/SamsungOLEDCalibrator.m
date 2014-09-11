classdef SamsungOLEDCalibrator < handle
    % Public access. All Calibrator subclasses inherit these properties.
    % Subclass users can set these properties, so these are public.
    properties
        
    end % Public properties
    
    
    % Public read-only access. % Subclass users can read/write these properties.
    properties (SetAccess = protected) 
        
        % Name of executive script that assembles the Calibrator
        % and the Radiometer object. Specified during object instantiation only.
        executiveScriptName = 'unspecified';
        
        % Name of file in which the cal struct is saved.
        calibrationFile = 'default.mat';
        
        % Handle to the left radiometer object which that acquires
        % measurements from the left target. Specified during object instantiation only.
        leftRadiometerObj = [];
        
        % Handle to the right radiometer object which that acquires
        % measurements from the left target. Specified during object instantiation only.
        rightRadiometerObj = [];
        
        %if it is set to 4, it will use the 10 bit temporal dither
        %available on the 240Hz OLED display
        displayTemporalDither = 4;
        
        % Comment relevant to the instantiated calibrator object
        comment = 'none';
        
    end
    
    
    % The class-user has no need to access these properties directly so they are protected
    properties (SetAccess = protected, GetAccess = protected)   
        % Rectangle defining region on the monitor which the left radiometer is measuring
        leftCalibrationRect;
        
        % Rectangle defining region on the monitor which the right radiometer is measuring
        rightCalibrationRect;
        
        % number of channels of the attached left @Radiometer device
        leftCalibrationDeviceMeasurementChannelsNum;
        
        % number of channels of the attached right @Radiometer device
        rightCalibrationDeviceMeasurementChannelsNum;
        
        % All the performed measurements computed by the calibrate() method.
        rawData = []; 
    end
    
    
    % Private properties. These must be specified at initialization time
    properties (Access = private)
        % Basic info about the host computer
        computerInfo = [];
        svnInfo      = [];
        matlabInfo   = [];
            
        % The left radiometer's model name and serial no
        leftCalibrationDeviceModelName = 'unspecified';
        leftCalibrationDeviceSerialNum = 'unspecified';
        
        % The right radiometer's model name and serial no
        rightCalibrationDeviceModelName = 'unspecified';
        rightCalibrationDeviceSerialNum = 'unspecified';
        
        % handle to first screen
        masterWindowPtr;
        
        % handle to second screen
        slaveWindowPtr;
        
        % array with all the open textures
        texturePointers = [];
        
        % full-field screen rect
        screenRect = [];
        
        % the original LUT (to be restored upon termination)
        origLUT;
        
    end % private properties
    
    
    % Public methods
    methods 
        % Constructor
        function obj = SamsungOLEDCalibrator(varargin) 
            % Configure an inputParser to examine whether the options passed to us are valid
            parser = inputParser;
            parser.addParamValue('executiveScriptName',     obj.executiveScriptName);
            parser.addParamValue('calibrationFile',         obj.calibrationFile);
            parser.addParamValue('leftRadiometerObj',       obj.leftRadiometerObj);
            parser.addParamValue('rightRadiometerObj',      obj.rightRadiometerObj);
            parser.addParamValue('displayTemporalDither',   obj.displayTemporalDither);
            parser.addParamValue('comment',                 obj.comment);
            
            % Execute the parser
            parser.parse(varargin{:});
            % Create a standard Matlab structure from the parser results.
            parserResults = parser.Results;
            pNames = fieldnames(parserResults);
            for k = 1:length(pNames)
                obj.(pNames{k}) = parserResults.(pNames{k}); 
            end
            
            fprintf('In SamsungOLEDCalibrator.constructor() method\n');
            
            if (~isempty(obj.leftRadiometerObj))
                % set the calibration device model name and serial number
                obj.leftCalibrationDeviceModelName = obj.leftRadiometerObj.deviceModelName;
                obj.leftCalibrationDeviceSerialNum = obj.leftRadiometerObj.deviceSerialNum;
                           
                % determine the sensors of the attached @Radiometer device
                if (obj.leftRadiometerObj.deviceProvidesSpectralMeasurements)
                    % spectral device
                    obj.leftCalibrationDeviceMeasurementChannelsNum = obj.leftRadiometerObj.nativeS(3);
                else
                    % colorimetric device, 3 sensors (XYZ)
                    obj.leftCalibrationDeviceMeasurementChannelsNum = 3;
                end
            end
            
            
            if (~isempty(obj.rightRadiometerObj))
                % set the calibration device model name and serial number
                obj.rightCalibrationDeviceModelName = obj.rightRadiometerObj.deviceModelName;
                obj.rightCalibrationDeviceSerialNum = obj.rightRadiometerObj.deviceSerialNum;
                           
                % determine the sensors of the attached @Radiometer device
                if (obj.rightRadiometerObj.deviceProvidesSpectralMeasurements)
                    % spectral device
                    obj.rightCalibrationDeviceMeasurementChannelsNum = obj.rightRadiometerObj.nativeS(3);
                else
                    % colorimetric device, 3 sensors (XYZ)
                    obj.rightCalibrationDeviceMeasurementChannelsNum = 3;
                end
            end   
            
            % Verify validity of screen params values
            obj.verifyScreenParamValues(); 
            
            % Set initial state
            obj.setDisplaysInitialState();
            
        end  % Constructor
        
        % Method to generate calibration rectangles
        displayTargetRects(obj, leftTargetSize, rightTargetSize, leftTargetPos, rightTargetPos);
        
    end % Public methods
    
    % The class-user has no need to call these methods, but our subclasses may.
    methods (Access = protected)
        
    end
    
    
    % Private methods
    methods (Access = private)
        % Method to verify that the attached screen configuration is
        % appropriate
        verifyScreenParamValues(obj);
         
        % Method to set the initial state of the displays
        setDisplaysInitialState(obj);
        
        % Method to display three rects
        display3Rects(obj, stim1, stim2, stim3, stim1Rect, stim2Rect, stim3Rect, ditherOffsets1, ditherOffsets2, ditherOffsets3);
        
        
    end  % private methods
    
    % Public static methods.  These are useful functions that can be called
	% without having to instantiate a @SamsungOLEDCalibrator object first
    methods (Static)
        convertOverUnderParamsToSideBySideParameters(win, leftOffset, leftScale, rightOffset, rightScale);
        matrixDitherOffsets = generateMatrixDitherOffsets(temporalDitheringMode, rows, cols);
    end
end
