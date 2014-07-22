function setObjectProperty(GLWObj, objectName, property, value)
% setObjectProperty(objectName, property, value)
%
% Description:
% Sets an object property.  This function should be used with caution as it
% doesn't do any checks to validate new property value.
%
% Inputs:
% objectName (string) - Name of the object to access.
% property (string) - Name of the property to set.
% value (depends) - The new value of the property.

if nargin ~= 4
	error('Usage: setObjectProperty(objectName, property, value)');
end

% Locate the object in the queue.
queueIndex = GLWObj.findObjectIndex(objectName);

% Verify if the object was found.
if queueIndex == -1
	error('Object with name "%s" not found.', objectName);
end

% Make sure the property exists.
if ~isfield(GLWObj.Objects{queueIndex}, property)
	error('Invalid property value "%s".', property);
end

% Set the property.
GLWObj.Objects{queueIndex}.(property) = value;
