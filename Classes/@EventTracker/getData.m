function [data, rvar, timeStamps] = getData(object, variables)
% [data, rvar, timeStamps] = getData(object, variables)
%
% Returns a cell array for containing variable data.
%
% Input:
% object - The EventTracker object you want to retreive data from.
% [variables] - Cell array of variable names.  If empty, the getData
%   assumes you want data for all variables.
%
% Output:
% data - A cell array of data for all requested variables.
% timeStamps - A cell array of timestamp data for all requested variables.
% rvar - A cell array containing the names of all requested variables.

if nargin == 1
	variables = getVariables(object);
end

data = {};
rvar = {};
timeStamps = {};

if ischar(variables)
	variables = {variables};
end

for j = 1:length(variables)
	% Find the variable in the TimeTracker list.
	varIndex = getVariableIndex(object, variables{j});
	
	% Make sure we actually found the variable that was specified.
	if varIndex == -1
		fprintf('*** EventTracker:getData: Variable ''%s'' was not found in the EventTracker object.', variables{j});
		continue;
	end
	
	data{end + 1} = object(varIndex).data(1:object(varIndex).index); %#ok<AGROW>
	timeStamps{end + 1} = object(varIndex).time(1:object(varIndex).index); %#ok<AGROW>
	rvar{end + 1} = object(varIndex).name; %#ok<AGROW>
end
