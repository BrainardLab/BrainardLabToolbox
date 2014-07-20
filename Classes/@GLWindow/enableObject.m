function enableObject(GLWObj, objectName)
% enableObject(objectName)
%
% Description:
% Enables a specificed object.
%
% Input:
% objectName (string) - Name of the object to enable.

if nargin ~= 2
	error('Usage: enableObject(objectName)');
end

% Locate the object in the queue.
objectIndex = GLWObj.findObjectIndex(objectName);

% Verify if the object was found.
if objectIndex == -1
	error('GLWindow.enableObject: object with id "%s" not found.', objectName);
end

% Enable the object.
GLWObj.Objects{objectIndex}.Enabled = true;
