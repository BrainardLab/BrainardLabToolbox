function vIndex = getVariableIndex(object, variable)
% Returns the index of the variable in the data structure that holds all
% the data.  -1 is returned if the variable isn't found.

if nargin ~= 2
	error('EventTracker:getVariableIndex: Invalid number of arguments.');
end

if ~ischar(variable)
	error('EventTracker:getVariableIndex: ''variable'' must be a string.');
end

vIndex = -1;
for i = 1:length(object)
	if strcmp(object(i).name, variable)
		vIndex = i;
		break;
	end
end
