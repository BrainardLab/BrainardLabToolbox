% Method to  display the cal struct
function displayCalStruct(obj)
    % get a copy of cal, so we dot keep calling its getter
    calStruct = obj.cal;

    subStructNames = fieldnames(calStruct);
    for subStructIndex = 1:numel(subStructNames)
        subfield = char(subStructNames(subStructIndex));
        fprintf('\nThe Calibrator''s  < cal.%s >  substruct contains the following', subfield);
        eval(sprintf('fields_and_values = calStruct.%s', subfield));
    end
end