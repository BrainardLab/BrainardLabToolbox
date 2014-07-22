function tt = EventTracker(varList, varSizes, varTypes)
% tt = EventTracker(varList, [varSizes], [varTypes])
%
% Description:
% Creates an object that can be used to track an arbitrary event.  A
% timestamp is automatically added to all events.
%
% Required Inputs:
% varList - A cell array of strings where each string is the name of a
%           tracked variable.
%
% Optional Inputs:
% varSizes - Array of integers that specifies the upperbound number of data
%            points for each variable in 'varList'.  Default is 100 for
%            each variable.
% varTypes - A cell array of strings where each string can be one of the
%            following values: 'double', 'cell', or 'string'.  These values
%            determine the type of array that will hold the data points for
%            each variable.  Default type is 'double'.
%
% Output:
% tt - An EventTracker object.

if nargin < 1 || nargin > 3
    error('Usage: tt = EventTracker(varList, [varSizes], [varTypes])');
end

% Setup defaults if necessary.
if ~exist('varSizes', 'var') || isempty(varSizes)
	if ischar(varList)
		varListLength = 1;
	else
		varListLength = length(varList);
	end
	
	varSizes = ones(1, varListLength) * 100;
end
if ~exist('varTypes', 'var') || isempty(varTypes)
	if ischar(varList)
		varListLength = 1;
	else
		varListLength = length(varList);
	end
	
	varTypes = cell(1, varListLength);
	for i = 1:varListLength
		varTypes{i} = 'double';
	end
end

% Convert string values into a cell arrays.
if ischar(varList)
	varList = {varList};
end
if ischar(varTypes)
	varTypes = {varTypes};
end

% Make sure the length of input arguments are equal.
if length(varList) ~= length(varSizes)
    error('varList and varSizes must be 1 x n matrices.');
end

for i = 1:length(varList)
    tt(i).name = varList{i}; %#ok<AGROW>
	tt(i).time = zeros(1, varSizes(i)) - 1; %#ok<AGROW>
    tt(i).index = 0; %#ok<AGROW>
	
	switch lower(varTypes{i})
		case 'double'
			tt(i).data = zeros(1, varSizes(i)); %#ok<AGROW>
		case {'string', 'cell'}
			tt(i).data = cell(1, varSizes(i)); %#ok<AGROW>
		otherwise
			error('EventTracker: Invalid variable type');
	end
end

tt = class(tt, 'EventTracker');
