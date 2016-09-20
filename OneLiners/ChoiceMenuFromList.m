function choiceIndex = ChoiceMenuFromList(inputCell, optionalPrompt)
% answer = ChoiceMenuFromList(inputCell, [optionalPrompt])
%
% This function takes a cell array of strings and presents them as a menu
% in the MATLAB command window, allowing the user to make a choice.
%
% 9/20/16   ms      Wrote it.

% Check if there's an input
if isempty(inputCell)
   error('No inputs passed.') 
end

% Display an optional prompt
if nargin > 1
    fprintf('\n<strong>%s</strong>', optionalPrompt);;
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