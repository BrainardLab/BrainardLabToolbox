function objectProperty = getObjectProperty(GLWObj, objectName, property)
% objectProperty = getObjectProperty(objectName, property)
%
% Description:
% Gets an object property.
%
% Inputs:
% objectName (string) - Name of the object to access.
% property (string) - Name of the property to get.
%
% Output:
% objectProperty - The property associated with "objectName".

if nargin ~= 3
	error('Usage: objectProperty = getObjectProperty(objectName, property)');
end

% Locate the object in the queue.
objectIndex = GLWObj.findObjectIndex(objectName);

% Verify if the object was found.
if objectIndex == -1
	error('Object with name "%s" not found.', objectName);
end

% Get the value
objectProperty = GLWObj.Objects{objectIndex}.(property);
