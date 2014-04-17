function obj = exportCal(obj)

    cal = obj.cal;
    
    fprintf('Exporting new-style cal format to %s.mat\n', obj.calibrationFile);
    SaveCalFile(cal, obj.calibrationFile);
    fprintf('Exported new-style cal format to %s.mat\n', obj.calibrationFile);
    
end
