function deleteTexture(GLWObj, objectID)
% deleteTexture(objectID)
%
% Description:
% Deletes the texture for the object specified by "objectID".
%
% Input:
% objectID (integer) - The index into the GLWObj.Objects cell array that
%   identifies the object.

if nargin ~= 2
	error('Usage: deleteTexture(objectID)');
end

if objectID < 1 || objectID > length(GLWObj.Objects)
	error('"objectID" of %d out of range.', objectID);
end

% Don't bother doing anything if the GLWindow isn't open.
if GLWObj.IsOpen == false
	return;
end

% Loop over all windows to delete the texture for each OpenGL context.
for i = 1:GLWObj.NumWindows
	mglSwitchDisplay(GLWObj.WindowInfo(i).WindowID);
	
	% If the Texture field exists, then there are textures to delete.
	if isfield(GLWObj.Objects{objectID}, 'Texture')
		mglDeleteTexture(GLWObj.Objects{objectID}.Texture(i));
		
		if GLWObj.DiagnosticMode
			fprintf('* Deleting texture %d for object ID %d, on window ID %d.\n', ...
				i, objectID, GLWObj.WindowInfo(i).WindowID);
		end
	end
end

if isfield(GLWObj.Objects{objectID}, 'Texture')
	% Get rid of the Texture field since we're no longer using it.  It will be
	% re-added if another texture gets attached for some reason.
	GLWObj.Objects{objectID} = rmfield(GLWObj.Objects{objectID}, 'Texture');
end
