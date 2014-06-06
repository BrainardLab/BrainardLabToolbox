function obj = exportCal(obj)

    fprintf('Exporting new-style cal format to %s.mat\n', obj.calibrationFile);
    SaveCalFile(obj.cal, obj.calibrationFile);
    fprintf('Exported new-style cal format to %s.mat\n', obj.calibrationFile);
end
