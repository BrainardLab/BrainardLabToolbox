% Method to combine svnInfo and matlabInfo into a single struct
% as was done in the old-style format
function  [meterType, meterTypePath] = makeOldStyleMeterType(obj)
    meterType = 0;
    meterTypePath = 'cal.describe.meterModel';
    if (strcmp(obj.inputCal.describe.meterModel, 'PR-650'))
        meterType = 1;
    elseif (strcmp(obj.inputCal.describe.meterModel, 'PR-655'))
        meterType = 4;
    elseif (strcmp(obj.inputCal.describe.meterModel, 'PR-670'))
        meterType = 5;    
    end
end