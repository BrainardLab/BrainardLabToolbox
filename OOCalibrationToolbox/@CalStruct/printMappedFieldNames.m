function printMappedFieldNames(obj)

    % Get all the mapped field names
    mappedFieldNames = keys(obj.oldFormatFieldMap);
    [~,indices] = sort(lower(mappedFieldNames));
    
    fprintf('\nMapped field names:\n');
    rowsNum = 25;
    for row = 1:rowsNum
        for col = 1:3
            k = row + (col-1)*rowsNum;
            if (k <= size(mappedFieldNames,2))
                fprintf(' %3d. %-25s ', k, char(mappedFieldNames{indices(k)}));
            end
        end
        fprintf('\n');
    end
    
end
