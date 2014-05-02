% Method to parse the input cal struct
function parseInputCal(obj)
    % load all known fields
    unifiedFieldNames = keys(obj.fieldMap);
    
    % Pass 1: load properties
    if (obj.verbosity > 0)
        fprintf('Parsing input cal: Phase I\n');
    end
    
    for k = 1:numel(unifiedFieldNames)
        % current unified name
        unifiedName = unifiedFieldNames{k};
        
        % retrieve path in input cal
        if (obj.inputCalHasNewStyleFormat)
            calPath = obj.fieldMap(unifiedName).newCalPath;
        else
            calPath = obj.fieldMap(unifiedName).oldCalPath;
        end
        
        if ~isempty(calPath)
            % get the corresponding private property name
            propertyName = obj.fieldMap(unifiedName).propertyName;
            
            % make sure all sub-structs in the calPath exist in the inputCal
            pathIsValid = true;
            subStruct   = obj.inputCal;
            dotIndices  = strfind(calPath,'.');
            if isempty(dotIndices)
                if ~obj.isFieldOrProperty(subStruct, calPath)   % isfield(subStruct, calPath)
                    fprintf(2,'>>>> Invalid path for field: %s', calPath);
                    pathIsValid = false;
                end
            else
                p = 1;
                for dotNo = 1:length(dotIndices)
                    subStructFieldName = calPath(p:dotIndices(dotNo)-1);
                    if ~obj.isFieldOrProperty(subStruct, subStructFieldName)
                        fprintf(2,'>>>> Invalid path for field: %s', subStructFieldName);
                        pathIsValid = false;
                        break;
                    end
                    p = dotIndices(dotNo)+1;
                    eval(sprintf('subStruct = subStruct.%s;', subStructFieldName));
                end
                % last field
                subStructFieldName = calPath(p:end);
                if ~obj.isFieldOrProperty(subStruct, subStructFieldName)
                   pathIsValid = false;
                end
            end
            
            if pathIsValid
                propertyValue = eval(sprintf('obj.inputCal.%s;',calPath));
            else
                propertyValue = [];
                if (obj.verbosity > 1)
                    fprintf(2,'>>> inputCal does not contain the path %s. Property %s set to [].\n', calPath, propertyName);
                    eval('inputCalFields = obj.inputCal');
                    fprintf('Hit enter to continue.\n\n');
                    pause;
                end
            end
            
            % and set it
            eval(sprintf('obj.%s = propertyValue;',propertyName));
            if (obj.verbosity > 0)
                % Feedback on what hapenned
                if pathIsValid
                    fprintf('%02d. %-40s <- obj.inputCal.%s \n', k, propertyName, calPath);
                else
                    fprintf('%02d. %-40s <- %g \n', k, propertyName, propertyValue);
                end
            end
        else
            if (obj.verbosity > 1)
                fprintf(2, 'A cal path has not been mapped for unifiedName: ''%s''.\n', unifiedName);
            end
        end
    end
    
    if (obj.verbosity > 0)
        fprintf('Finished phase I of parsing.\n\n');
        fprintf('Parsing input cal: Phase II\n');
    end
    
    % Pass 2: convert any properties that need conversion
    % Note. we have to convert in second pass because fieldnames in a map
    % are not guaranteed to be retrieved in the order they were inserted
    % so if we need a field in the conversion of another field we may not
    % have it.
    
    for k = 1:numel(unifiedFieldNames)
        % current unified name
        unifiedName = unifiedFieldNames{k};
        
        % retrieve path in input cal
        if (obj.inputCalHasNewStyleFormat)
            calPath = obj.fieldMap(unifiedName).newCalPath;
        else
            calPath = obj.fieldMap(unifiedName).oldCalPath;
        end
        
        if ~isempty(calPath)
            % get the corresponding private property name
            propertyName = obj.fieldMap(unifiedName).propertyName;
            
            % check if we need to convert the property to old-style format
            if isfield(obj.fieldMap(unifiedName), 'newToOldConversionFname') && (obj.inputCalHasNewStyleFormat)
                % get conversion function handle
                conversionFunctionHandle = obj.fieldMap(unifiedName).newToOldConversionFname;
                
                if (obj.verbosity > 0)
                    % feedback to the user
                    fprintf('Will convert the value of  ''obj.inputCal.%s''  to old-style format. \n', calPath);
                end
                
                % obtain its current value
                eval(sprintf('propertyValue = obj.%s;',propertyName));
            
                % convert value to old-style format
                propertyValue = conversionFunctionHandle(propertyValue);
                
                % and update the private property
                eval(sprintf('obj.%s = propertyValue;',propertyName));
            end
            
       end
    end
    
    if (obj.verbosity > 0)
        fprintf('Finished phase II of parsing.\n\n');
    end
end



