function object = addData(object, variables, values)
% object = addData(object, variables, values)
%
% Description:
% Adds data to the EventTracker.
%
% Input:
% object (EventTracker) - The object to which you will add data.
% variables (string|cell array of strings) - Variables you want to add
%    data to.
% values (value type|cell array) - Cell array of values matching the
%    'variables' parameters or a single value matching the value type of the
%    'variable' type if there's only one variable being added to.
%
% Output:
% object (EventTracker) - The updated object.


% Use the PTB GetSecs function if it's available.  Otherwise, use the
% built-in Matlab function 'cputime' which is less accurate.
if exist('GetSecs.m', 'file')
	timeStamp = GetSecs;
else
	timeStamp = cputime;
end

if nargin ~= 3
    error('Usage: addData(object, variables, values)');
end

% Convert 'varList' into a cell array if it's a single string.
if ischar(variables)
	variables = {variables};
end

% Convert 'values' into a cell array if necessary.
if ~iscell(values)
	values = {values};
end

if length(variables) ~= length(values)
	error('EventTracker:addData: variables must be the same length as values');
end

targetIndices = [];
for j = 1:length(variables)
	% Find the variable in the TimeTracker list.
	varIndex = getVariableIndex(object, variables{j});
	targetIndices(end + 1) = varIndex; %#ok<AGROW>
	
	% Make sure we actually found the variable that was specified.
	if varIndex == -1
		fprintf('*** EventTracker:add: Variable ''%s'' was not found in the EventTracker object.', variables{j});
		continue;
	end
	
	% Store the data and increment the index count.
	index = object(varIndex).index + 1;
	if iscell(object(varIndex).data)
		object(varIndex).data{index} = values{j};
	else
		object(varIndex).data(index) = values{j};
	end
	object(varIndex).index = index;
	object(varIndex).time(index) = timeStamp;
end
