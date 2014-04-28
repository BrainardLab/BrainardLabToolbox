function CalStructDisplay(calStruct, marginForContents, previousFieldNameFullPath)

    % Check input arguments
    if (nargin < 1)
        error('A calStruct must be provided.');
    elseif (nargin < 3)
       marginForContents = 100;
       previousFieldNameFullPath = '';
    end
    
    subStruct = 'calStruct';
    if ~isempty(previousFieldNameFullPath)
       subStruct = sprintf('calStruct.%s', previousFieldNameFullPath);
    end

    level = length(findstr(subStruct, '.'));
    structFieldNames  = fieldnames(eval(subStruct));
    
    if (level == 0)
        fprintf('\ncalStruct:\n');
    end


    marginForContents = 110;
    marginForFieldType = 80;
    
    for fieldIndex = 1:length(structFieldNames)
        
        fieldName       = structFieldNames{fieldIndex};
        entry           = sprintf('%- 45s.', subStruct);
        fullFieldName   = sprintf('%s.%s', subStruct,fieldName);
        fieldValue      = eval(fullFieldName);   
        fieldValueDims  = size(fieldValue);
        
        entry = [entry sprintf('%s',fieldName)];
        currentLength = length(entry);
        while currentLength < marginForFieldType
          entry = [entry ' '];  
           currentLength = length(entry);
        end
            
        entry = [entry sprintf('%s',' [')];
        
        for dimIndex = 1:length(fieldValueDims)-1
           entry = [entry sprintf('% 6d x', fieldValueDims(dimIndex))];
        end
        entry = [entry sprintf('%- 4d] ', fieldValueDims(end))];
        
        if isstruct(fieldValue)
            entry = [entry sprintf('struct ')];
            if (prod(fieldValueDims) > 1)
                entry = [entry sprintf(' array.')]; 
            end
            fprintf('%s\n', entry); 
            entry = [];
            if isempty(previousFieldNameFullPath)
               updatedFieldNameFullPath = sprintf('%s',fieldName);
            else
               updatedFieldNameFullPath = sprintf('%s.%s',previousFieldNameFullPath, fieldName);
            end
            % Recurse into substruct
            CalStructDisplay(calStruct, marginForContents, updatedFieldNameFullPath);
            
        elseif ischar(fieldValue)
            entry = [entry sprintf('char', fieldValue)];
            if (prod(fieldValueDims) > 1)
                entry = [entry sprintf(' array.')]; 
            end
            
        elseif iscell(fieldValue)
            entry = [entry sprintf('cell')];
            if (prod(fieldValueDims) > 1)
                entry = [entry sprintf(' array.')]; 
            end
            
        elseif isnumeric(fieldValue)
            if (isfloat(fieldValue))
                entry = [entry sprintf('float')];
            end
            if (isinteger(fieldValue))
                entry = [entry sprintf('integer')];
            end
            if (prod(fieldValueDims) > 1)
                entry = [entry sprintf(' array.')]; 
            end
            
        else
            entry = [entry sprintf('unknown class')];
        end
        
        
        
        if ~isstruct(fieldValue)
            % Realign
            currentLength = length(entry);
            while currentLength < marginForContents
              entry = [entry ' '];  
               currentLength = length(entry);
            end 
            entry = [entry sprintf(' ==>  ')];
            
            if ischar(fieldValue)
                entry = [entry sprintf('''%s''', fieldValue)];
                
            elseif (isnumeric(fieldValue))
                elements = min(10, numel(fieldValue));
                if (isfloat(fieldValue))
                    for k = 1:elements
                        entry = [entry sprintf('%3.3f ', fieldValue(k))];
                        if (k < elements)
                            entry = [entry ', '];
                        elseif (elements < numel(fieldValue))
                            entry = [entry ' ...'];
                        end
                    end
                elseif (isinteger(fieldValue))
                    for k = 1:elements
                        entry = [entry sprintf('%d ', fieldValue(k))];
                        if (k < elements)
                            entry = [entry ', '];
                        elseif (elements < numel(fieldValue))
                            entry = [entry ' ...'];
                        end
                    end
                end

            elseif (iscell(fieldValue))
                elements = min(10, numel(fieldValue));
                for k = 1:elements
                    cellValue = fieldValue{k};
                    if ischar(cellValue)
                        entry = [entry sprintf('''%s'' ', cellValue)];
                    elseif isfloat(cellValue)
                        entry = [entry sprintf('%2.3f ', cellValue)];
                    elseif isinteger(cellValue)
                        entry = [entry sprintf('%d ', cellValue)];
                    end
                    if (k < elements)
                        entry = [entry ', '];
                    elseif (elements < numel(fieldValue))
                        entry = [entry ' ...'];
                    end
                end
                
            end
        end
        
        if (~isempty(entry))
            fprintf('%s\n', entry);  
        end
    end

    
end