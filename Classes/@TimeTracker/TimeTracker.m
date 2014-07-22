function tt = TimeTracker(varList, varSizes)
% tt = TimeTracker(varList, varSizes)
%   Creates an object that can be used to track an event by recording a
%   list of timestamps associated with it.
if nargin ~= 2
    error('Usage: tt = TimeTracker(varList, varSizes)');
end

% Make sure the length of input arguments are equal.
if length(varList) ~= length(varSizes)
    error('varList and varSizes must be 1 x n matrices.');
end

for i = 1:length(varList)
    tt(i).name = varList{i};
    tt(i).data = zeros(1, varSizes(i));
%	tt(i).time = zeros(1, varSizes(i));
    tt(i).index = 0;
end

tt = class(tt, 'TimeTracker');
