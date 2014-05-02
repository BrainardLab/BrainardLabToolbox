% Getter method for a given unified field name
function fieldValue = get(obj, unifiedFieldName)
    if (~ischar(unifiedFieldName))
        fprintf(2,'>>> field name must be entered in quotes.\n');
        fprintf(2,'>>> Hit enter to continue.\n\n');
        pause;
        return; 
    end
    if (obj.fieldNameIsValid(unifiedFieldName))
        % Find the corresponding property name
        propertyName = obj.fieldMap(unifiedFieldName).propertyName;
        % Call the getter for that property
        fieldValue = eval(sprintf('obj.%s;',propertyName));
    else
        fprintf(2, '>>> Unknown unified field name (''%s''). Cannot get its value.\n', unifiedFieldName);
        obj.printMappedFieldNames(); 
        obj.printMappedFieldNames();
        fprintf(2, '>>> Hit enter to continue.\n\n');
        pause;
    end     
end 