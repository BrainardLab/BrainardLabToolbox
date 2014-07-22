function glwObj = initGLWFrameBuffer(glwObj, index)
% glwObj = initGLWFrameBuffer(glwObj, index)
%
% Description:
% Creates a framebuffer object and warp grid for a single OpenGL window in
% a GLWindow object.
%
% Input:
% glwObj (GLWindow) - GLWindow object.
% index (integer) = This is the index into the internal structures that
%	containing OpenGL window specific information.  For a regular HDR
%	window, this value will always be 1 because there is only 1 OpenGL
%	window that will be warped.  For other types, such as stereo, this
%	value will be either 1 or 2.
%
% Output:
% glwObj (GLWindow) - Updated GLWindow object containing the newly created
%	framebuffer object and warping information.

global GL;

% Load the warp data which creates the 'warpParams' variable.
if glwObj.diagnosticmode
	fprintf('- Loading warp data for window %d...', index);
end
cal = LoadCalFile(glwObj.private.warpFile{index});
if glwObj.diagnosticmode
	fprintf('Done\n');
end

% Pull out the translation and scale parameters if they exist.
if isfield(cal.warpParams, 'translation')
	glwObj.private.warpScale(index,:) = cal.warpParams.scale;
	glwObj.private.warpTranslation(index,:) = cal.warpParams.translation;
end

% Setup the framebuffer object.
if glwObj.diagnosticmode
	fprintf('- Creating framebuffer object...');
end
glwObj.private.fbSize{index} = cal.warpParams.fbSize;
[glwObj.private.fbObject{index}, glwObj.private.fbTexture{index}] = ...
	mglInitFrameBuffer(glwObj.private.fbSize{index});

% This lets us know what kind of framebuffer object we made
% since we must texture map it later.
if glwObj.private.fbSize{index}(1) == glwObj.private.fbSize{index}(2)
	glwObj.private.fbTexType{index} = GL.TEXTURE_2D;
else
	glwObj.private.fbTexType{index} = GL.TEXTURE_RECTANGLE_ARB;
end
if glwObj.diagnosticmode
	fprintf('Done\n');
end

% Create the screen warp display list.
if glwObj.diagnosticmode
	fprintf('- Creating warp display list...');
end
if glwObj.private.fbTexType{index} == GL.TEXTURE_2D
	glwObj.private.warpList{index} = ...
		HDRCreateWarpList(cal.warpParams.actualGrid, [1 1]);
else
	glwObj.private.warpList{index} = ...
		HDRCreateWarpList(cal.warpParams.actualGrid, ...
		glwObj.private.fbSize{index});
end
if glwObj.diagnosticmode
	fprintf('Done\n');
end
