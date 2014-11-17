function trackedVars = listTrackedVariables(object)

if nargin ~= 1
    error('Usage: trackedVars = listTrackedVariables(object)');
end

%fprintf('%d tracked variables\n', length(object));
for i = 1:length(object)
    %fprintf('''%s''\n', object(i).name);
    trackedVars{i} = object(i).name;
end