function OOC_analyzeCal

    % Instantiate a @CalAnalyzer object
    calAnalyzer = CalibratorAnalyzer(...
                   'analysisScriptName', mfilename ...  
                    );
    
    % Load a calibration file
    [cal, calFilename] = GetCalibrationStructure('Enter calibration filename','ViewSonicProbe',[]);
    
    % Analyze the calibration file and display the results arranged in different grids
    calAnalyzer.essentialDataGridDims       = [3 3];
    calAnalyzer.linearityChecksGridDims     = [2 3];  
    calAnalyzer.backgroundEffectsGridDims   = [2 3];  
    
    calAnalyzer.analyze(cal);
    
    % Exit
    calAnalyzer.shutdown();
end
