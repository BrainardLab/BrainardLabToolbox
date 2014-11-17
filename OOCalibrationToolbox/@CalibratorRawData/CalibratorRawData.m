% Class that defines a struct that stores the @Calibrator's raw data.
% We use this instead of a basic struct for a
% the following reasons: (i) field name checking (to avoid typos in field names)
% (ii) field value checking (to avoid incorrect field value types).
%
% 3/13/2014  npc Wrote it.
%

classdef CalibratorRawData
    % public properties
	properties 
        
        % the S-vector (specral sampling) of the attached @Radiometer.
        % Computed by the @Calibrtor's calibrate() method.
        S = [];
        
        % [settingsNumToBeMeasured x measurementChannelsNum] matrix
        % containing the first set basic linearity measurements.
        % Computed by the @Calibrtor's calibrate() method.
        basicLinearityMeasurements1 = [];
        
        % [settingsNumToBeMeasured x measurementChannelsNum] matrix
        % containing the second set basic linearity measurements.
        % Computed by the @Calibrtor's calibrate() method.
        basicLinearityMeasurements2 = [];
        
        % [1 x gammaCurvePointsNum] matric with input gamma values.
        % Computed by the @Calibrtor's calibrate() method.
        gammaInput = [];
        
        % [gammaCurvePointsNum x (primariesNum*primaryBasesNum)] matrix
        % of output gamma values. 
        % Computed by the @Calibrtor's fitLinearModel() method.
        gammaTable;
        
        % [averagesNum x PrimariesNum x gammaCurvePointsNum] matrix
        % containing the randomized sequence with which gamma curve points were measured.
        % Computed by the @Calibrtor's calibrate() method.
        gammaCurveSortIndices = [];
       
        % [averagesNum x PrimariesNum x gammaCurvePointsNum x measurementChannelsNum] matrix
        % containing the full-gamma curve measurements for each trial.
        % Computed by the @Calibrtor's calibrate() method.
        gammaCurveMeasurements = [];
        
        % [PrimariesNum x gammaCurvePointsNum x measurementChannelsNum] matrix
        % containing the full-gamma curve measurements (trial-averaged)
        % Computed by the @Calibrtor's calibrate() method.
        gammaCurveMeanMeasurements = [];
        
        % [backgroundsSettingsNum x foregroundSettingsNum x measurementChannelsNum] matrix
        % containing  the background-dependence measurements.
        % Computed by the @Calibrtor's calibrate() method.
        backgroundDependenceMeasurements = [];
        
        % [1 x measurementChannelsNum] matrix with the ambient light measurements.
        % Computed by the @Calibrtor's calibrate() method.
        ambientMeasurements = [];            
    end
    
    % Public methods
    methods
        
        % Constructor
        function obj = CalibratorRawData(varargin)
            % do nothing
            % fprintf('New @CalibratorRawData object generated.\n');
        end
    end
    
end
