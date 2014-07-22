function index = findObjectIndex(objectQueue, objectList)
% index = findObjectIndex(objectQueue, objectList)
%
% Description:
% Finds the index|indices into the queue for an object(s).
%
% Input:
% objectQueue (cell array) - The internal object queue.
% objectList (cell array of strings) - Names of the objects to search for.
%
% Output:
% index (integer vector) - The queue indices of the items specified by
%	'objectList'.  A -1 index is return if the object(s) wasn't found.

if isempty(objectQueue)
	index = -1;
	return;
end

% Make a cell array of all objects in the queue.
for i = 1:length(objectQueue)
	objectNames{i} = objectQueue{i}.name; %#ok<AGROW>
end

% Convert 'objectList' into a cell array if it's just a string.
if ischar(objectList)
	objectList = {objectList};
end

numObjects = length(objectList);

index = zeros(1, numObjects);
j = 0;

for i = 1:numObjects
	qi = strmatch(objectList{i}, objectNames, 'exact');
	
	% If there was no name match, set the object index to be -1.
	if isempty(qi)
		qi = -1;
	end
		
	j = j + 1;
	index(j) = qi;
end
