% Method to analyze the loaded calStruct
function obj = analyze(obj, calStruct, essentialDataGridDims, linearityChecksGridDims)

    if (strcmp(calStruct.describe.driver, 'object-oriented calibration'))
        % set the @Calibrator's cal struct. The cal setter method also sets 
        % various other properties of obj
        obj.cal = calStruct;
    else
        % set the @Calibrator's cal struct to empty
        obj.cal = [];
        % and notify user
        calStruct.describe
        fprintf('The selected cal struct has an old-style format.\n');
        fprintf('Use mglAnalyzeMonCalSpd to analyze it editinstead.\n');
        return;
    end
    
    obj.refitData();
    obj.computeReusableQuantities();
    
    % For old-style routines that expect an old-format calStruct
    % convert calStruct to old-format:
    % oldFormatCal = Calibrator.calStructWithOldFormat(obj, calStruct);
    
    obj.plotAllData(essentialDataGridDims, linearityChecksGridDims);
end