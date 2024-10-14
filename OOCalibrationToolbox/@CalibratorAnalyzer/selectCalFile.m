% Query user to load a cal file and return the calFilename and the calDir
function [calFilename, calDir, cal] = selectCalFile()

    p = getpref('BrainardLabToolbox');
    [calFilename, calDir] = uigetfile('*.mat', 'Select a calibration file to open', p.CalDataFolder, 'MultiSelect','on');

    % If only one additional file is selected
    if (ischar(calFilename))
        fullCalFile = fullfile(calDir,calFilename);
        load(fullCalFile, 'cals');
        fprintf('\nLoading calibration file 2...\n');
        fprintf('\nCalibration file contains %d calibrations\n',length(cals));
        fprintf('Dates:\n');
        for i = 1:length(cals)
            fprintf('\tCalibration %d, date %s\n',i,cals{i}.describe.date);
        end
        calIndex = GetWithDefault('Enter number of calibration to use',length(cals));
        cal = cals{calIndex};
    else % If multiple additional files are selected
        cal = {};
        for i = 1:length(calFilename)
            % Note: This assumes that the files are in the same directory
            fullCalFile = fullfile(calDir, calFilename{i});
            load(fullCalFile, 'cals');
            fprintf('\nLoading calibration file %d...\n', i + 1);
            fprintf('\nCalibration file contains %d calibrations\n', length(cals));
            fprintf('Dates:\n');
            for i = 1:length(cals)
                fprintf('\tCalibration %d, date %s\n',i,cals{i}.describe.date);
            end
            calIndex = GetWithDefault('Enter number of calibration to use',length(cals));
            this_cal = cals{calIndex};
            cal{end + 1} = this_cal;
        end
    end

end
   

