function obj = GLW_DeleteTextures(obj, windowID, diagnosticMode)
% obj = GLW_DeleteTextures(obj, windowID, diagnosticMode)
%
% Description:
% Deletes any textures attached to 'obj'.
%
% Input:
% obj (struct) - Render object in GLWindow.
% windowID (1xN integer) - Array of window IDs attached to this GLWindow
%	object.
%
% Output:
% obj (struct) - Updated render object.

% Delete any textures attached to the object.
if isfield(obj, 'texture') && ~isempty(obj.texture)
	for i = 1:length(windowID)
		mglSwitchDisplay(windowID(i));
		glDeleteTextures(1, obj.texture(i).textureNumber);
		
		if diagnosticMode
			fprintf('* Deleting texture number %d on window %d.\n', ...
				obj.texture(i).textureNumber, windowID(i));
		end
	end
end
