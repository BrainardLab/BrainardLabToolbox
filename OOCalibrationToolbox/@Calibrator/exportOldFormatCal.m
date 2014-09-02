% Method to export the cal struct in the old format. 
% Provides backwards compatibility with old programs.
function exportOldFormatCal(obj)

    calStruct = obj.cal;
    
    % Generate a calStruct with old-format
    oldFormatCal = Calibrator.calStructWithOldFormat(obj, calStruct);
    
    % Generate file name for old-format calStruct 
    oldStyleCalFileName = sprintf('%s_OldFormat', obj.calibrationFile);
    
    % Save old-format calStruct
    fprintf('Exporting old-style cal format to %s.mat\n', oldStyleCalFileName);
    SaveCalFile(oldFormatCal, oldStyleCalFileName);
    fprintf('Exported old-style cal format to %s.mat\n', oldStyleCalFileName);
    
end

        