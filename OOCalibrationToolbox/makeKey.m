function makeKey(calFilenames, calIndex, allAdditionalCal)

    % Make a separate figure that is a "key"
    % To match calibration number to file name
    
    keyFig = figure('Name', 'Calibration File Key', 'NumberTitle', 'off', ...
        'Position', [100, 100, 475*1.17, 250*1.5]);
    
    % Create a panel in the figure
    keyPanel = uipanel('Parent', keyFig, 'Position', [0.05 0.05 0.9 0.9]);
    
    calibrationNumbers = cell(length(calFilenames), 1);
    
    % Calibration number and corresponding file names
    for i = 1:length(calFilenames)
        if i == 1
            calibrationNumbers{i} = 'Ref Cal';
        else
            calibrationNumbers{i} = sprintf('Cal %d', i);
        end
    end

    % Accounting for the case where there's only one additional file
    if length(allAdditionalCal) == 1
        keyData = [calibrationNumbers, calFilenames(:), {calIndex(1), allAdditionalCal(1)}'];
    elseif isempty(allAdditionalCal) % Or zero additional files
        keyData = [calibrationNumbers, calFilenames(:), {calIndex(1)}'];
    else % Or multiple additional files
        calIndexData = {calIndex, allAdditionalCal};
        keyData = [calibrationNumbers, calFilenames(:), calIndexData(:)];
    end

    % Create the table
    keyTable = uitable('Parent', keyPanel, ...
        'Data', keyData, ...
        'ColumnName', {'Calibration Number', 'File Name', 'Calibration Date'}, ...
        'Position', [20 20 400*1.25 200*1.5], ... % Adjust position and size as needed
        'ColumnEditable', [false false], ... % Make columns non-editable
        'FontSize', 18);
    
    % Adjust column widths if necessary
    set(keyTable, 'ColumnWidth', {135, 175, 135}); 

end

