function calStructHasNewStyleFormat = CalStructHasNewStyleFormat(calStruct)

    calStructHasNewStyleFormat = false;
    if isfield(calStruct.describe, 'driver')
        if strcmp(calStruct.describe.driver, 'object-oriented calibration')
            if (~((isfield(calStruct.describe, 'isExportedFromNewStyleCalStruct')) && (calStruct.describe.isExportedFromNewStyleCalStruct == true)))
                calStructHasNewStyleFormat = true;
            end
        end
    end
    
end
