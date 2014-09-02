function data = getData(object, variable)
if nargin ~= 2
    error('Usage: data = getData(object, variable)');
end

% Find the variable in the TimeTracker list.
varIndex = -1;
for i = 1:length(object)
    if strcmp(object(i).name, variable)
        varIndex = i;
        break;
    end
end

% Make sure we actually found the variable that was specified.
if varIndex == -1
    error('Variable ''%s'' was not found in the TimeTracker object.', variable);
end

data = object(varIndex).data(1:object(varIndex).index);