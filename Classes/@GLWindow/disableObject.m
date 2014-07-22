function disableObject(GLWObj, objectName)
% disableObject(objectName)
%
% Description:
% Disables a specificed object.
%
% Input:
% objectName (string) - Name of the object to disable.
%
% Output:

if nargin ~= 2
	error('Usage: disableObject(objectName)');
end

% Locate the object in the queue.
objectIndex = GLWObj.findObjectIndex(objectName);

% Verify if the object was found.
if objectIndex == -1
	error('GLWindow.disableObject: object with id "%s" not found.', objectName);
end

% Enable the object.
GLWObj.Objects{objectIndex}.Enabled = false;
