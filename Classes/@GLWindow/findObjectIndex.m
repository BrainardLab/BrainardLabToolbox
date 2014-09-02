function index = findObjectIndex(GLWObj, objectName)
% index = findObjectIndex(objectName)
%
% Description:
% Finds the index into the queue for an object.
%
% Input:
% objectName (string) - Names of the object to search for.
%
% Output:
% index (integer vector) - The queue index of the item specified by
%	'objectName'.  A -1 index is returned if the object wasn't found.

if nargin ~= 2
	error('Usage: index = findObjectIndex(objectName)');
end

% Defaults to -1.  Stays this value if no matching object is found.
index = -1;

for i = 1:length(GLWObj.Objects)
	if strcmp(objectName, GLWObj.Objects{i}.Name)
		index = i;
		break;
	end
end
