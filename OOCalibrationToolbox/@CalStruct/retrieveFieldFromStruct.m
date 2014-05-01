% Method to check for the existence of and retrieve the a field's 
% value and path in cal.
function [fieldValue, fieldPath] = retrieveFieldFromStruct(obj, subStructName, fieldName)
%
    if (~isempty(subStructName)) && (~isfield(obj.inputCal, subStructName))
        fieldValue = [];
        fieldPath = [];
        return;
    end
    
    if isempty(subStructName)
        structure = eval(sprintf('obj.inputCal'));
        fieldPath = sprintf('cal');
    else
        structure = eval(sprintf('obj.inputCal.%s', subStructName));
        fieldPath = sprintf('cal.%s',subStructName);
    end
    
    structFieldNames = fieldnames(structure);
    
    if (ismember(fieldName, structFieldNames))
        fieldValue = eval(sprintf('structure.%s',fieldName));
        fieldPath  = sprintf('%s.%s',fieldPath,fieldName);
    else
        fprintf(2,'Did not find a field called ''%s'' in the passed structure. Returning empty value.\n', fieldName);
        fprintf('Structure contains the following fieldnames\n');
        structFieldNames = fieldnames(structure);
        for k = 1:numel(structFieldNames)
            fprintf('  > %s\n', structFieldNames{k});
        end
        fieldValue = [];
        fieldPath = [];
    end
end
