% Method to generate a cal struct (of the old format)
% by parsing the obj.oldFormatFieldMap.
function cal = generateUpdatedCal(obj)

    fprintf('Generating cal with old-style format.\n');
    cal = struct();
    
    % Get all the mapped unified field names
    unifiedFieldNames = keys(obj.fieldMap);
    
    for k = 1:numel(unifiedFieldNames)
        calPath = obj.fieldMap(unifiedFieldNames{k}).oldCalPath;
        if ~isempty(calPath)
            propertyName  = obj.fieldMap(unifiedFieldNames{k}).propertyName;
            propertyValue = eval(sprintf('obj.%s;',propertyName));
            fprintf('%d. Loading cal.%-30s <-- %s\n',k, calPath, propertyName); 
            eval(sprintf('cal.%s = propertyValue;',calPath));
        end
    end
end
