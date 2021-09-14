function obj = exportCal(obj)

    calStruct = obj.cal;
    
    % Add extra fields to calStruct

    
    % Add extra fields to calStruct
    extraFieldsForCalStruct = {...
        'customLinearitySetup' ...          
        'customBackgroundDependenceSetup' ... 
        'calibratorTypeSpecificParamsStruct' ...
        'skipLinearityTest' ...
        'skipBackgroundDependenceTest' ...
        'skipAmbientLightMeasurement'...
    };
    % Get all properties of the obj.options @CalibratorOptions object
    props = properties(obj.options);
    % Add the ones that exist
    extraOptions = [];
    for fIndex = 1:numel(extraFieldsForCalStruct)
        theFieldName = extraFieldsForCalStruct{fIndex};
        if (any(ismember(props, theFieldName)))
            fprintf('Adding ''%s'' to calStruct\n', theFieldName);
            extraOptions.(theFieldName) = obj.options.(theFieldName);
        end
    end
    if (~isempty(extraOptions))
        calStruct.extraOptions = extraOptions;
    end
    
    fprintf('Exporting new-style cal format to %s.mat\n', obj.calibrationFile);
    
    BLToolboxPrefs = getpref('BrainardLabToolbox');
    if (isfield(BLToolboxPrefs, 'CalDataFolder')) && (~isempty(BLToolboxPrefs.CalDataFolder))
        SaveCalFile(calStruct, obj.calibrationFile, BLToolboxPrefs.CalDataFolder);
    else     
        SaveCalFile(calStruct, obj.calibrationFile);
    end
    
    % Flash window showing that the calibration was finished and where the
    % calibration file was saved
    calibrationMessage = sprintf('\n------------------------------------------------------------------\n\tCalibration data saved in %s.\n------------------------------------------------------------------\n', which(sprintf('%s.mat', obj.calibrationFile)));
    disp(calibrationMessage);

end
