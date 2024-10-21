function OOC_analyzeCal

    close all

    % Initialize empty cell arrays to store calibration data
    calFilenames = {};
    calDirs = {};
    cals = {};
    
    % Select the first calibration file
    [calFilename, calDir, cal, calIndex] = CalibratorAnalyzer.singleSelectCalFile();
    calFilenames{end+1} = calFilename;
    calDirs{end+1} = calDir;
    cals{end+1} = cal;

    % If you select more files, the file that you selected first is 
    % the reference calibration

    more_cals = GetWithDefault('\nWould you like to select more files? If so, the file you just selected will be the reference calibration. [0 -> no,1 -> yes]', 0);

    if (more_cals)

        % Select more files
        [calFilename, calDir, cal, additionalCalIndex] = CalibratorAnalyzer.selectCalFile();
        % If only one additional file is selected
        if (ischar(calFilename))
            calFilenames{end+1} = calFilename;
            calDirs{end+1} = calDir;
            cals{end+1} = cal;
            calAnalyzer = CalibratorAnalyzer(cals, calFilenames, calDirs);
        else % If multiple additional files are selected
            for i = 1:length(calFilename)
                calFilenames{end+1} = calFilename{i};
                calDirs{end+1} = calDir;
                cals{end+1} = cal{i};
            end
            calAnalyzer = CalibratorAnalyzer(cals, calFilenames, calDirs);
        end


    else % If you did not select any more files (not doing a comparison)
        calAnalyzer = CalibratorAnalyzer(cals, calFilenames, calDirs);

    end
  
    % Analyze the calibration files and display the results arranged in different grids
    calAnalyzer.essentialDataGridDims       = [3 3];
    calAnalyzer.linearityChecksGridDims     = [2 3];  % columns rows
    calAnalyzer.backgroundEffectsGridDims   = [3 2];  
    calAnalyzer.comparisonGridDims          = [2 2];

    calAnalyzer.analyze();

     % Creating a key for calibration file name and date index
    if (more_cals)  % If there is more than one calibration
        makeKey(calFilenames, calIndex, additionalCalIndex);
    else
        makeKey(calFilenames, calIndex, []);
    end

end