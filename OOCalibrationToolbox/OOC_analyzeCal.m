function OOC_analyzeCal

    % Load a calibration file
    defaultCalFile = '240OLED_SDAL2';
    [cal, calFilename] = GetCalibrationStructure('Enter calibration filename',defaultCalFile,[]);
    
    % Instantiate a @CalAnalyzer object
    calAnalyzer = CalibratorAnalyzer(cal, calFilename);

    % Analyze the calibration file and display the results arranged in different grids
    calAnalyzer.essentialDataGridDims       = [3 3];
    calAnalyzer.linearityChecksGridDims     = [2 3];  % columns rows
    calAnalyzer.backgroundEffectsGridDims   = [3 2];  
    
    calAnalyzer.analyze();
end
