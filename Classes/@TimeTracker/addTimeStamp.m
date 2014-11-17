function object = addTimeStamp(object, variable, timeStamp)
% Adds a time stamp to the given variable for a TimeTracker object.

if nargin ~= 3
    error('Usage: addTimeStamp(object, variable, timeStamp)');
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

object(varIndex).index = object(varIndex).index + 1;
object(varIndex).data(object(varIndex).index) = timeStamp;