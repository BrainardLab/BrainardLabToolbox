function close(GLWObj)
% close(GLWObj)
%
% Description:
% Closes an open GLWindow.
%
% Usage:
% w = GLWindow;
% w.open;
% w.close;

if nargin ~= 1
	error('Usage: close');
end

if GLWObj.IsOpen == true
	% Go through all the objects in the Object queue and delete any
	% attached textures so that we free up memory.
	for i = 1:length(GLWObj.Objects)
		GLWObj.deleteTexture(i);
	end
	
	% Now reset all the gamma tables to the identity for all windows.
	GLWObj.Gamma = [];
	
	% For Bits++ displays we need to render the gamma string on the screen
	% to get it to reset.
	%**** Do that here ****%
	
	% Go through each object and delete any attached textures.
	for i = 1:length(GLWObj.Objects)
		GLWObj.deleteTexture(i);
	end
	
	% Now close all open windows.
	for i = 1:GLWObj.NumWindows
		mglSwitchDisplay(GLWObj.WindowInfo(i).WindowID);
		mglClose;
	end
	
	GLWObj.IsOpen = false;
	GLWObj.Objects = {};
	
	% Make sure the cursor is visible again.
	mglDisplayCursor(1);
end
