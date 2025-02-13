% Query user to load a cal file and return the calFilename and the calDir
function [calFilename, calDir, cal] = selectCalFile()
    p = getpref('BrainardLabToolbox');
    [calFilename, calDir] = uigetfile('*.mat', 'Select a calibration file to open', p.CalDataFolder);
    fullCalFile = fullfile(calDir,calFilename);
    load(fullCalFile, 'cals');
    fprintf('Calibration file contains %d calibrations\n',length(cals));
    fprintf('Dates:\n');
    for i = 1:length(cals)
        fprintf('\tCalibration %d, date %s\n',i,cals{i}.describe.date);
    end
    calIndex = GetWithDefault('Enter number of calibration to use',length(cals));    
    cal = cals{calIndex};
end
