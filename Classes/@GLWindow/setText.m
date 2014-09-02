function setText(GLWObj, objectName, newText)
% setText(GLWObj, objectName, newText)
%
% Description:
% Sets the text of an existing text object.
%
% Input:
% objectName (string) - Name of the text object to modify.
% newText (string) - New string to update the text object.

if nargin ~= 3
	error('Usage: setText(objectName, newText)');
end

% Locate the object in the queue.
objectIndex = GLWObj.findObjectIndex(objectName);
if objectIndex == -1
	error('Text object with name "%s" not found.', objectName);
end

% Make sure that the object is a text object.
if GLWObj.Objects{objectIndex}.ObjectType ~= GLWindow.ObjectTypes.Text
	error('Object must be of type "text".');
end

GLWObj.Objects{objectIndex}.Text = newText;

% Re-add the object to the queue.  This will overwrite the old object.
GLWObj.addObjectToQueue(GLWObj.Objects{objectIndex});
