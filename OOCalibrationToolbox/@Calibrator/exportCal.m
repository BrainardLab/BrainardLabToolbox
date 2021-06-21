function obj = exportCal(obj)

    calStruct = obj.cal;
    
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
