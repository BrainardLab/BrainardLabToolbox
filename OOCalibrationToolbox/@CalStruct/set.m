% Setter method for a given unified field name
function set(obj, unifiedFieldName, fieldValue)
    if (obj.fieldNameIsValid(unifiedFieldName))
        % Find the corresponding property name
        propertyName = obj.fieldMap(unifiedFieldName).propertyName;

        if strcmp(obj.fieldMap(unifiedFieldName).access,'read_write')
            % Call the setter for that property
            size(eval(sprintf('obj.%s',propertyName)))
            eval(sprintf('obj.%s = fieldValue;',propertyName)); 
        else
            fprintf(2, '>>> Field name ''%s'' has Read-Only access. Will not set it''s value. <<< \n', unifiedFieldName);
            obj.printMappedFieldNames();
            fprintf(2, '>>> Hit enter to continue.\n\n');
            pause;
        end
    else
        fprintf(2, '>>> Unknown field name: ''%s''. Cannot set it''s value.\n', unifiedFieldName);
        obj.printMappedFieldNames();
        fprintf(2, '>>> Hit enter to continue.\n\n');
        pause;
    end
end    