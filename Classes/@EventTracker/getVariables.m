function v = getVariables(object)
% Returns the variables stored in this EventTracker.

v = cell(1, length(object));
for i = 1:length(v)
	v{i} = object(i).name;
end
