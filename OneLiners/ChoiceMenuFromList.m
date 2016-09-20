function choiceIndex = ChoiceMenuFromList(inputCell)
% answer = ChoiceMenuFromList(inputCell)
%
% This function takes a cell array of strings and presents them as a menu
% in the MATLAB command window, allowing the user to make a choice.
%
% 9/20/16   ms      Wrote it.

if isempty(inputCell)
   error('No inputs passed.') 
end

% Have the user select an available option.
numChoices = length(inputCell);
keepPrompting = true;
while keepPrompting
    % Show the available options
    fprintf('\n*** Available options ***\n\n');
    for i = 1:numChoices
        fprintf('%d - <strong>%s</strong>\n', i, inputCell{i});
    end
    fprintf('\n');
    
    choiceIndex = GetInput('Select a Calibration Type', 'number', 1);
    
    % Check the selection.
    if choiceIndex >= 1 && choiceIndex <= numChoices
        fprintf('* Selected choice: %s\n', inputCell{choiceIndex});
        keepPrompting = false;
    else
        fprintf('\n* <strong>Invalid selection.</strong>\n');
    end
end