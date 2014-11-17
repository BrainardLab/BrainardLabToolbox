function mglVerifyBitsPP(screenNumber)
% mglVerifyBitsPP([screenNumber])
%
% Description:
% Draws a square on the screen with a black background and runs through a
% set of 10 colors going from black to white and changing the square color 
% every .5 seconds.  If you see only a black or almost black square, then 
% Bits++ didn't work properly.  If you see 10 obvious color changes, then 
% all is right.
%
% Optional Input:
% screenNumber (integer) - The ID of the screen to open.  Defaults to -1,
%	which means that the last attached monitor is the target screen.
%	screenNumber values should be integers in the range [1,Infinity].

if nargin == 0
	screenNumber = -1;
end

% Tell MGL which screen we want to render to.  If "screenNumber" is -1,
% then we don't call mglSwitchDisplay because -1 is a special code to that
% function telling it to close all open MGL windows.
if screenNumber ~= -1
	if screenNumber < 1
		error('"screenNumber" must be an integer in the range [1,Infinity].');
	end
	
	mglSwitchDisplay(screenNumber);
end

% Enable key capture.
ListenChar(2);
FlushEvents;

try
	% Defaults
	screenWidth = 40;
	screenHeight = 30;
	squareSize = 10;
	
	% Preallocate the Bits++ gamma.
	bitsGamma = zeros(256, 3);
	
	% Create the color values.
	colorValues = linspace(0,1,10)' * [1 1 1];
	
	% Set up the identity gamma so Bits++ will work.
	mglOpen(screenNumber);
	mglClearScreen(0);
	mglSetGammaTable(mglGetIdentityGamma');
	mglFlush;
	
	% Setup the projection matrix.
	mglTransform('GL_PROJECTION', 'glLoadIdentity');
	mglTransform('GL_PROJECTION', 'glOrtho', -screenWidth/2, screenWidth/2, ...
		-screenHeight/2, screenHeight/2, 1, -1);
	
	for i = 1:10
		mglClearScreen(0);
		mglTransform('GL_MODELVIEW', 'glLoadIdentity');
		
		% Draw the square.  The color is set the the 2nd entry in the
		% Bits++ gamma.
		mglFillRect(0, 0, [squareSize squareSize], ones(1,3)/255);
		
		% Set the Bits++ gamma and render the scene.
		bitsGamma(2,:) = colorValues(i,:);
		mglBitsPlusSetClut(bitsGamma);
		
		WaitSecs(0.5);
	end
	
	ListenChar(0);
	mglClose;
catch e
	ListenChar(0);
	mglClose;
	rethrow(e);
end
