function CalStructDisplay(calStruct, marginForFieldType, marginForContents, previousFieldNameFullPath)

    % Check input arguments
    if (nargin < 1)
        error('A calStruct or calStruct filename (in quotes) must be provided.');
    elseif (nargin < 4)
       marginForFieldType = 90;
       marginForContents = 130;
       previousFieldNameFullPath = '';
    end
    
    if ischar(calStruct)
        calFileName = calStruct;
        calStruct = [];
        [calStruct, calFilename] = GetCalibrationStructure('Enter calibration filename',calFileName,[]); 
    end
    
    subStruct = 'calStruct';
    if ~isempty(previousFieldNameFullPath)
       subStruct = sprintf('calStruct.%s', previousFieldNameFullPath);
    end

    level = length(findstr(subStruct, '.'));
    structFieldNames = fieldnames(eval(subStruct));
   
    if (level == 0)
        fprintf('\n\n\n');
        fprintf('<strong><--------- F U L L   P A T H ---------->     <-- F I E L D  N A M E -->       <-- F I E L D   S I Z E  &  T Y P E -->              <---------------- F I E L D  V A L U E  ------------> </strong>\n');
    end
    
    for fieldIndex = 1:length(structFieldNames)
        
        fieldValueHasUnknownClass = false;
        fieldValueIsObject        = false;
        
        fieldName       = structFieldNames{fieldIndex};
        fullFieldName   = sprintf('%s.%s', subStruct,fieldName);
        fieldValue      = eval(fullFieldName); 
        fieldValueDims   = size(fieldValue);
        
        if isstruct(fieldValue)
            entry = sprintf('\n%- 45s.', subStruct); 
            entry = [entry sprintf('<strong>%s</strong>',fieldName)];
            currentLength = length(entry);
            while currentLength < marginForFieldType+5
              entry = [entry ' '];  
               currentLength = length(entry);
            end
        elseif isobject(fieldValue)
            entry = sprintf('\n%- 45s.', subStruct); 
            entry = [entry sprintf('<strong>%s</strong>',fieldName)];
            currentLength = length(entry);
            while currentLength < marginForFieldType+5
              entry = [entry ' '];  
               currentLength = length(entry);
            end
            fieldValueIsObject = true;
        else
            entry = sprintf('%- 45s.', subStruct);
            entry = [entry sprintf('%s',fieldName)];
            currentLength = length(entry);
            while currentLength < marginForFieldType
              entry = [entry ' '];  
               currentLength = length(entry);
            end
        end
        
        
        if isstruct(fieldValue) || isobject(fieldValue)
            entry = [entry sprintf('%s',' [')];
            for dimIndex = 1:length(fieldValueDims)-1
               entry = [entry sprintf('% d x ', fieldValueDims(dimIndex))];
            end
            entry = [entry sprintf('%d] ', fieldValueDims(end))];
        else
            entry = [entry sprintf('%s',' [')];
            for dimIndex = 1:length(fieldValueDims)-1
               entry = [entry sprintf('%d x ', fieldValueDims(dimIndex))];
            end
            entry = [entry sprintf('%d] ', fieldValueDims(end))];
        end
        
        if isstruct(fieldValue)
            entry = [entry sprintf('struct ')];
            if (prod(fieldValueDims) > 1)
                entry = [entry sprintf(' array (displaying contents of first one only)')]; 
            end
            fprintf('%s\n', entry); 
            entry = [];
            if isempty(previousFieldNameFullPath)
               updatedFieldNameFullPath = sprintf('%s',fieldName);
            else
               updatedFieldNameFullPath = sprintf('%s.%s',previousFieldNameFullPath, fieldName);
            end
            % Recurse into substruct
            CalStructDisplay(calStruct, marginForFieldType, marginForContents, updatedFieldNameFullPath);
            
        elseif isobject(fieldValue)
            entry = [entry sprintf('object of class @<strong>%s</strong>',class(fieldValue))];
            if (prod(fieldValueDims) > 1)
                entry = [entry sprintf(' array')]; 
            end
            fprintf(2,'%s\n', entry); 
            entry = [];
            
            if isempty(previousFieldNameFullPath)
               updatedFieldNameFullPath = sprintf('%s',fieldName);
            else
               updatedFieldNameFullPath = sprintf('%s.%s',previousFieldNameFullPath, fieldName);
            end
            % Recurse into substruct
            CalStructDisplay(calStruct, marginForFieldType, marginForContents,  updatedFieldNameFullPath);
            
        elseif ischar(fieldValue)
            entry = [entry sprintf('char', fieldValue)];
            if (prod(fieldValueDims) > 1)
                entry = [entry sprintf(' array')]; 
            end
            
        elseif iscell(fieldValue)
            entry = [entry sprintf('cell')];
            if (prod(fieldValueDims) > 1)
                entry = [entry sprintf(' array')]; 
            end
            
        elseif isnumeric(fieldValue)
            if (isfloat(fieldValue))
                entry = [entry sprintf('float')];
            end
            if (isinteger(fieldValue))
                entry = [entry sprintf('integer')];
            end
            if (prod(fieldValueDims) > 1)
                entry = [entry sprintf(' array')]; 
            end
        else
            entry = [entry sprintf('unknown class')];
            fieldValueHasUnknownClass = true;
        end
        
        if (~isstruct(fieldValue)) && (~isobject(fieldValue))
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
            if (fieldValueHasUnknownClass)
                fprintf(2,'\n%s', entry);
            else
                fprintf('%s\n', entry);
            end
        end
        
        if (fieldIndex == length(structFieldNames))
            fprintf('\n');
        end
    end  
end
