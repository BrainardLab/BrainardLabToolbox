function printMappedFieldNames(obj)

    % load all known fields
    unifiedFieldNames = keys(obj.fieldMap);
    [~,indices] = sort(lower(unifiedFieldNames));
    
    fprintf('\nMapped field names:\n');
    rowsNum = 25;
    for row = 1:rowsNum
        for col = 1:3
            k = row + (col-1)*rowsNum;
            if (k <= size(unifiedFieldNames,2))
                fprintf(' %3d. %-25s ', k, char(unifiedFieldNames{indices(k)}));
            end
        end
        fprintf('\n');
    end
    
end
