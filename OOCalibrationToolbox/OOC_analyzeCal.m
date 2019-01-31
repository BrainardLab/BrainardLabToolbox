function OOC_analyzeCal

    % Load a calibration file
    defaultCalFile = 'ViewSonic-1_Calib';
    try
        [cal, calFilename] = GetCalibrationStructure('Enter calibration filename',defaultCalFile,[]);
    catch err
        fullCalFile = input('Calibration file not found using GetCalibrationStructure.\nEnter calibration filename again: ', 's');
        if (exist(fullCalFile, 'file'))
            fprintf('\nThe calibration file ''%s'' was found in %s !!\n\n', fullCalFile, which(fullCalFile));
            v = whos('-file', fullCalFile);
            load(fullCalFile);
            eval(sprintf('cal = %s;', v.name));
            calFilename = fullCalFile;
        else
           error('File ''%s'' not found on the path.', fullCalFile); 
        end
    end

    % Instantiate a @CalAnalyzer object
    calAnalyzer = CalibratorAnalyzer(cal, calFilename);
    
    
    % Analyze the calibration file and display the results arranged in different grids
    calAnalyzer.essentialDataGridDims       = [3 3];
    calAnalyzer.linearityChecksGridDims     = [2 3];  % columns rows
    calAnalyzer.backgroundEffectsGridDims   = [3 2];  
    
    calAnalyzer.analyze();
end
