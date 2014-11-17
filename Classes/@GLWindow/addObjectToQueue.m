function addObjectToQueue(GLWObj, obj)
% addObjectToQueue(obj)
%
% Description:
% Adds an object to the object queue.
%
% Input:
% obj (struct) - A structure holding all the information necessary to
% render one of the object type listed by GLWindow.ObjectTypes.

if nargin ~= 2
	error('Usage: addObjectToQueue(obj)');
end

% Look to see if the object already exists in the queue.
queueIndex = GLWObj.findObjectIndex(obj.Name);

% If the object already exists in the queue, delete any associated textures
% so there's no memory leak.
if obj.RenderMethod == GLWindow.RenderMethods.Texture && GLWObj.IsOpen && queueIndex ~= -1
	if queueIndex ~= -1
		GLWObj.deleteTexture(queueIndex);
	end
end

% queueIndex == -1 if not the object was not found in the queue.
if queueIndex == -1
	queueIndex = length(GLWObj.Objects) + 1;
	
	if GLWObj.DiagnosticMode
		fprintf('* New object %s in slot %d\n', obj.Name, queueIndex);
	end
else
	if GLWObj.DiagnosticMode
		fprintf('* Replacing object %s in slot %d\n', obj.Name, queueIndex);
	end
end

% Add the rect to drawing queue.
GLWObj.Objects{queueIndex} = obj;

% If the window is open and it's a texture object, go ahead and create it
% now.
if obj.RenderMethod == GLWindow.RenderMethods.Texture && GLWObj.IsOpen
	GLWObj.makeTexture(queueIndex);
end
