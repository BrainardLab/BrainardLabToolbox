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

    more = true;
    allAdditionalCal = {};

    while more % Keep asking the user if they want to select another file until they say no

        more_cals = GetWithDefault('\nWould you like to select more files? [0 -> no,1 -> yes]', 0);

        if (more_cals)

            % Select more files
            [calFilename, calDir, cal, additionalCalIndex] = CalibratorAnalyzer.selectCalFile();
            allAdditionalCal{end + 1} = additionalCalIndex;
            % If only one additional file is selected
            if (ischar(calFilename))
                calFilenames{end+1} = calFilename;
                calDirs{end+1} = calDir;
                cals{end+1} = cal;
            else % If multiple additional files are selected
                for i = 1:length(calFilename)
                    calFilenames{end+1} = calFilename{i};
                    calDirs{end+1} = calDir;
                    cals{end+1} = cal{i};
                end
            end


        else % If you did not select any more files 
            calAnalyzer = CalibratorAnalyzer(cals, calFilenames, calDirs);

            more = false;

        end

    end
  
    % Analyze the calibration files and display the results arranged in different grids
    calAnalyzer.essentialDataGridDims       = [3 3];
    calAnalyzer.linearityChecksGridDims     = [2 3];  % columns rows
    calAnalyzer.backgroundEffectsGridDims   = [3 2];  
    calAnalyzer.comparisonGridDims          = [2 2];

    calAnalyzer.analyze();

     % Uncomment these lines to create a key for calibration file name and date index
     % if ~isempty(allAdditionalCal)  % If there is more than one calibration
     %     makeKey(calFilenames, calIndex, allAdditionalCal);
     % else
     %     makeKey(calFilenames, calIndex, []);
     % end

end

