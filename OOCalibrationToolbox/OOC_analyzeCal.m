function OOC_analyzeCal

    % Load a calibration file
    [cal, calFilename] = GetCalibrationStructure('Enter calibration filename','ViewSonicProbe',[]);
    
    % Instantiate a @CalAnalyzer object
    calAnalyzer = CalibratorAnalyzer(cal);
    
    
    % Analyze the calibration file and display the results arranged in different grids
    calAnalyzer.essentialDataGridDims       = [3 3];
    calAnalyzer.linearityChecksGridDims     = [2 3];  
    calAnalyzer.backgroundEffectsGridDims   = [2 3];  
    
    calAnalyzer.analyze();
end
