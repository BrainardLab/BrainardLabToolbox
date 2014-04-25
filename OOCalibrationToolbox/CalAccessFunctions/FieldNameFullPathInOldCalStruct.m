% Method to find a fieldname's full path within an old-style calStruct
function fieldNameFullPath = FieldNameFullPathInOldCalStruct(calStruct, targetFieldName, previousFieldNameFullPath)
%    
    fieldNameFullPath = '';
    debug = false;
    if (debug)
        fprintf('\n\n ------------- \nSearching for ''%s''.\n', targetFieldName);
    end
    
    subStruct = 'calStruct';
    if ~isempty(previousFieldNameFullPath)
       subStruct = sprintf('calStruct.%s', previousFieldNameFullPath);
    end
        
    structFieldNames  = fieldnames(eval(subStruct));
    fieldNameWasFound = false;  
    fieldIndex        = 1;
    while ((fieldIndex <= length(structFieldNames)) && (fieldNameWasFound == false))
        fieldName     = structFieldNames{fieldIndex};
        fullFieldName = sprintf('%s.%s', subStruct,fieldName);
        
        if ~isstruct(eval(fullFieldName))
            if strcmp(fieldName, targetFieldName)
                if (debug)
                    fprintf('>> %s is not a struct and it matches the target field name! \n', fullFieldName);
                end
                if ~isempty(previousFieldNameFullPath)
                    fieldNameFullPath = sprintf('%s.%s',previousFieldNameFullPath, targetFieldName);
                else
                    fieldNameFullPath = targetFieldName;
                end
                fieldNameWasFound = true;
            end
        else
            % recurse if fieldNameFullPath == ''
            if (isempty(fieldNameFullPath))
                if isempty(previousFieldNameFullPath)
                    updatedFieldNameFullPath = sprintf('%s',fieldName);
                else
                    updatedFieldNameFullPath = sprintf('%s.%s',previousFieldNameFullPath, fieldName);
                end
                if (debug)
                    fprintf('%s is a struct. Will recurse with update path: %s\n', fullFieldName, updatedFieldNameFullPath);
                end
                fieldNameFullPath = FieldNameFullPathInOldCalStruct(calStruct, targetFieldName, updatedFieldNameFullPath);
            end
        end
        fieldIndex = fieldIndex + 1;
    end % for fieldIndex
    
end