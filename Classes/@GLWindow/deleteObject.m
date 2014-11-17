function deleteObject(GLWObj, objectName)
% deleteObject(objectName)
%
% Description:
% Removes an object from the rendering queue.  Also deletes any texture
% memory associated with the object.
%
% Input:
% objectName (string) - Name of the object to delete.

if nargin ~= 2
	error('Usage: deleteObject(objectName)');
end

% Make sure that 'objectName' is a string.
if ~ischar(objectName)
	error('"objectName" must be a string.');
end

% Find the object queue index.
queueIndex = GLWObj.findObjectIndex(objectName);

% Check to make sure we found the requested object.
if queueIndex == -1
	error('* Could not find object with name "%s".', objectName);
end

% Delete any textures attached to the object.
GLWObj.deleteTexture(queueIndex);

% Remove the object from the queue.
GLWObj.Objects = GLWObj.Objects(1:length(GLWObj.Objects) ~= queueIndex);
