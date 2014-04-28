function OOC_analyzeCal

    % Instantiate a @CalAnalyzer object
    calAnalyzer = CalibratorAnalyzer(...
                   'analysisScriptName', mfilename ...  
                    );
    
    % Load a calibration file
    [calStruct, calFilename] = GetCalibrationStructure('Enter calibration filename','ViewSonicProbe',[]);
    
    CalStructDisplay(calStruct, 100, '');
    
    % Analyze the calibration file and display the results arranged in different grids
    calAnalyzer.essentialDataGridDims       = [3 3];
    calAnalyzer.linearityChecksGridDims     = [2 3];  
    calAnalyzer.backgroundEffectsGridDims   = [2 3];  
    calAnalyzer.analyze(calStruct);
    
    % Print cal struct
    calAnalyzer.displayCalStruct();
    
    % Exit
    calAnalyzer.shutdown();
end
