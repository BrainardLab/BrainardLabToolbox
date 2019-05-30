function OOC_analyzeCal
    % Select a calibration file
    [calFilename, calDir, cal] = CalibratorAnalyzer.selectCalFile();
    
    % Instantiate a @CalAnalyzer object
    calAnalyzer = CalibratorAnalyzer(cal, calFilename, calDir);
    
    % Analyze the calibration file and display the results arranged in different grids
    calAnalyzer.essentialDataGridDims       = [3 3];
    calAnalyzer.linearityChecksGridDims     = [2 3];  % columns rows
    calAnalyzer.backgroundEffectsGridDims   = [3 2];  
    
    calAnalyzer.analyze();
end
