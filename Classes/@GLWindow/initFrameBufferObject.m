function initFrameBufferObject(GLWObj, winfoID)
% initFrameBufferObject(windowID)
%
% Description:
% Initializes the frame buffer object for the specified window, i.e.
% warping.
%
% Input:
% winfoID (integer) - The WindowInfo ID of the window for which to setup
%   the framebuffer object.

if nargin ~= 2
	error('Usage: initFrameBufferObject(windowID)');
end

% Load the warp data which creates the 'warpParams' variable.
if GLWObj.DiagnosticMode
	fprintf('- Loading warp data for window %d...', winfoID);
end
cal = LoadCalFile(GLWObj.WindowInfo(winfoID).WarpFile);
if GLWObj.DiagnosticMode
	fprintf('Done\n');
end

% Pull out the translation and scale parameters if they exist.
if isfield(cal.warpParams, 'translation')
	GLWObj.WindowInfo(winfoID).WarpScale = cal.warpParams.scale;
	GLWObj.WindowInfo(winfoID).WarpTranslation = cal.warpParams.translation;
end

% Setup the framebuffer object.
if GLWObj.DiagnosticMode
	fprintf('- Creating framebuffer object for window %d...', winfoID);
end
if isfield(cal.warpParams, 'fbSize')
	fbSize = cal.warpParams.fbSize;
else
	fbSize = [cal.warpParams.fbObject.width, cal.warpParams.fbObject.height];
end
GLWObj.WindowInfo(winfoID).FBObject = mglCreateFrameBufferObject(fbSize(1), fbSize(2));

if GLWObj.DiagnosticMode
	fprintf('Done\n');
end

% Newer warp files contain information about the physical size of the frame
% buffer object and how it was mapped onto the display.  Store that if it
% exists.  Otherwise, we'll assume that the framebuffer object scene
% dimensions are identical to GLWindow scene dimensions.
if isfield(cal.warpParams, 'fbSceneDims')
	GLWObj.WindowInfo(winfoID).FBSceneDims = cal.warpParams.fbSceneDims;
else
	GLWObj.WindowInfo(winfoID).FBSceneDims = GLWObj.SceneDimensions;
end

if GLWObj.DiagnosticMode
	fprintf('Using framebuffer object scene dimensions of [%f, %f].\n', ...
		GLWObj.WindowInfo(winfoID).FBSceneDims(1), GLWObj.WindowInfo(winfoID).FBSceneDims(2));
end

% Create the screen warp display list.
if GLWObj.DiagnosticMode
	fprintf('- Creating warp display list for window %...', winfoID);
end

GLWObj.WindowInfo(winfoID).WarpList = mglCreateWarpList(cal.warpParams.actualGrid, ...
 	[GLWObj.WindowInfo(winfoID).FBObject.width GLWObj.WindowInfo(winfoID).FBObject.height]);

if GLWObj.DiagnosticMode
	fprintf('Done\n');
end
