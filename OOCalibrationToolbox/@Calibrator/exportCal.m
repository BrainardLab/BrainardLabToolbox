function obj = exportCal(obj)

    calStruct = obj.cal;
    
    fprintf('Exporting new-style cal format to %s.mat\n', obj.calibrationFile);
    SaveCalFile(calStruct, obj.calibrationFile);
    
    % Flash window showing that the calibration was finished and where the
    % calibration file was saved
    calibrationMessage = sprintf('\n------------------------------------------------------------------\n\tCalibration data saved in %s.\n------------------------------------------------------------------\n', which(sprintf('%s.mat', obj.calibrationFile)));
    disp(calibrationMessage);

end
