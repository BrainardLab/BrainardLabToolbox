function OOC_analyzeCal

    % Instantiate a @CalAnalyzer object
    calAnalyzer = CalibratorAnalyzer(...
                   'analysisScriptName', mfilename ...  
                    );
    
    % Load a calibration file
    [calStruct, calFilename] = GetCalibrationStructure('Enter calibration filename','HDRFrontYokedMondrianfull',[]);
    
    % Analyze the calibration file and display the results in a 4x4 grid
    essentialDataGridDims = [3 3];
    linearityChecksGridDims = [3 4];
    calAnalyzer.analyze(calStruct, essentialDataGridDims, linearityChecksGridDims);
    
    % Print cal struct
    calAnalyzer.displayCalStruct();
    
    % Exit
    calAnalyzer.shutdown();
end
