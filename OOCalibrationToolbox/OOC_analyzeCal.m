function OOC_analyzeCal

    % Instantiate a @CalAnalyzer object
    calAnalyzer = CalibratorAnalyzer(...
                   'analysisScriptName', mfilename ...  
                    );
    
    % Load a calibration file
    [calStruct, calFilename] = GetCalibrationStructure('Enter calibration filename','HDRFrontYokedMondrianfull',[]);
    
    % Analyze the calibration file and display the results
    calAnalyzer.analyze(calStruct);
    
    % Print cal struct
    calAnalyzer.displayCalStruct();
    
    % Exit
    calAnalyzer.shutdown();
end
