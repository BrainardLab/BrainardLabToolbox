% Method to check the validity of the requested field name.
function isValid = fieldNameToGetIsValid(obj, oldFormatFieldName)
%
    isValid = true;
    
    % Get all the mapped field names
    mappedFieldNames = keys(obj.oldFormatFieldMap);
    
    % make sure fieldname is in the FieldMap
    if (~ismember(oldFormatFieldName, mappedFieldNames))
        fprintf(2,'Requested field named, ''%s'', is not mapped! Check the field''s name.\n', oldFormatFieldName); 
        isValid = false;
    else
        % Check if 'S_device' was requested
        if strcmp(oldFormatFieldName, 'S_device')
            % Inform user that the use of S_device is discouraged
            fprintf(2,'The use of ''S_device'' is discouraged. Use ''S'' instead.\n');
        end
    
        % Check if 'S_ambient' was requested
        if strcmp(oldFormatFieldName, 'S_ambient')
            % Inform user that the use of S_device is discouraged
            fprintf(2,'The use of ''S_ambient'' is discouraged. Use ''S'' instead.\n');
        end
        
        % If 'S' was requested, make sure that there is no 'S_device' or
        % 'S_ambient' in the inputCal, and if there are, make sure that
        % they match 'S'.
        if strcmp(oldFormatFieldName, 'S')
            
            S_device  = [];
            S_ambient = [];
            
            if (obj.inputCalHasNewStyleFormat)
                S = obj.inputCal.rawData.S;
                if isfield(obj.inputCal.processedData, 'S_device')
                    S_device = obj.inputCal.processedData.S_device;
                end
                if isfield(obj.inputCal.processedData, 'S_ambient')
                    S_ambient = obj.inputCal.processedData.S_ambient;
                end
            else
                S = obj.inputCal.describe.S;
                if isfield(obj.inputCal, 'S_device')
                    S_device = obj.inputCal.S_device;
                end
                if isfield(obj.inputCal, 'S_ambient')
                    S_ambient = obj.inputCal.S_ambient;
                else
                    fprintf('Note: The input cal contains an ''S_ambient'' field that matches the ''S'' field.\n');
                end
            end
           
            if ~isempty(S_device)
                if (any(S-S_device)) 
                    fprintf(2,' ''S'' and ''S_device'' do not match.\n');
                else
                    fprintf('Note: The input cal contains an ''S_device'' field that matches the ''S'' field.\n');
                end
            end
            
            if ~isempty(S_ambient)
               if (any(S-S_ambient)) 
                    fprintf(2,' ''S'' and ''S_ambient'' do not match.\n');
                    isValid = false;
                else
                    fprintf('Note: The input cal contains an ''S_ambient'' field that matches the ''S'' field.\n');
                end 
            end

        end
    end
    
    
end
