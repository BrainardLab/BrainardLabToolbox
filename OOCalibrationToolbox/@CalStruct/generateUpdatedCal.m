% Method to generate a cal struct (of the same format at the inputCal)
% by parsing the obj.oldFormatFieldMap.
function cal = generateUpdatedCal(obj)

    cal = struct();
    oldStyleFieldNames = keys(obj.calStructPathMap)
    
    for k = 1:numel(oldStyleFieldNames)
        fieldName  = oldStyleFieldNames{k};
        calPath    = obj.calStructPathMap(fieldName);
        if strcmp(fieldName, 'whichMeterType')
           calPath 
        end
        if ~isempty(calPath)
            fieldValue = obj.oldFormatFieldMap(fieldName);
            eval(sprintf('%s=fieldValue;', calPath));
            sprintf('%s=fieldValue;', calPath)
        end
    end
    
    cal
    
end
