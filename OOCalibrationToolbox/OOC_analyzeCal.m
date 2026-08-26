function OOC_analyzeCal(options)
%{

    Example #1 (default):
        OOC_analyzeCal()

    
    Example #2 (set custom visualixedSPDrangesAbs):
        OOC_analyzeCal(...
            'visualizedSPDrangesAbs', [...
                250 1000 1500 1500 ...
                2000 1000 700 600 ...
                1500 1200 1500 1500 ...
                2500 2500 3000 2500 ...
                ], ...
            'visualizedSPDrangesNorm', [...
                0.25 1.0 1.5 1.5 ...
                2.0 1.0 0.7 0.6 ...
                1.5 1.2 1.500 1.500 ...
                2.500 2.500 3.000 2.500 ...
                ]);

%}

% Set parameters.
arguments
    options.visualizedSPDrangesAbs  (1,:) = []
    options.visualizedSPDrangesNorm (1,:) = []
end


    visualizedSPDrangesAbs = options.visualizedSPDrangesAbs;
    visualizedSPDrangesNorm = options.visualizedSPDrangesNorm;

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

            if (~isempty(visualizedSPDrangesAbs))
                calAnalyzer.visualizedSPDrangesAbs = visualizedSPDrangesAbs;
            end

            if (~isempty(visualizedSPDrangesNorm))
                calAnalyzer.visualizedSPDrangesNorm = visualizedSPDrangesNorm;
            end
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

