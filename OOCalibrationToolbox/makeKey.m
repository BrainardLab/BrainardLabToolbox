function makeKey(calFilenames)

    % Make a separate figure that is a "key"
    % To match calibration number to file name
    
    keyFig = figure('Name', 'Calibration File Key', 'NumberTitle', 'off', ...
        'Position', [100, 100, 475, 250]);
    
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
    
    keyData = [calibrationNumbers, calFilenames(:)];
    
    % Create the table
    keyTable = uitable('Parent', keyPanel, ...
        'Data', keyData, ...
        'ColumnName', {'Calibration Number', 'File Name'}, ...
        'Position', [20 20 400 200], ... % Adjust position and size as needed
        'ColumnEditable', [false false], ... % Make columns non-editable
        'FontSize', 18);
    
    % Adjust column widths if necessary
    set(keyTable, 'ColumnWidth', {175, 175}); 

end

