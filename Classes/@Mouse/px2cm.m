function cmCoords = px2cm(obj, targetScreen, screenDimsCm)

if nargin ~= 3
	error('Usage: cmCoords = px2cm(targetScreen, screenDimsCm)');
end

% Get the pixel dimensions of the target screen.
p = obj.DisplayInfo(targetScreen).screenSizePixel;
px = p(1);
py = p(2);

% Get the display bounds.  The display bounds tells us where this screen is
% in absolute screen coordinates with respect to all screens attached to
% the computer.  Essentially, these are offsets we need to subtract off the
% mouse position so we can tell where it is on the screen of interest.
if isfield(obj.DisplayInfo(targetScreen), 'displayBounds')
    displayBounds = obj.DisplayInfo(targetScreen).displayBounds;
else
    displayBounds = zeros(1,4);
end

% Get the current mouse position.
mouseState = obj.MouseStatePx;

% The mouse coordinates are in a global context with respect to all other
% monitors attached to the computer.  This means that the screen with the
% largest height represents the full [0,1] portion of the global vertical
% space.  The consquence of this is that smaller monitors will never have a
% 0 vertical position for the mouse.  As a result, we have to subtract off
% the difference between the mouse's current monitor vertical size and the
% biggest monitor's vertical size.
verticalOffset = obj.MaxDisplayHeight - py;
mouseState.y = mouseState.y - verticalOffset;

% We also need to subtract off the horizontal offset the mouse screen has
% in global coordinates.
mouseState.x = mouseState.x - displayBounds(1);
    
% Make sure the mouse is on the screen.
if mouseState.x >= 0 && mouseState.x <= px && mouseState.y <= py
	% This matrix transforms pixel coordinates into centimeter screen
	% coordinates.
	T = [screenDimsCm(1)/px, 0, -screenDimsCm(1)/2; ...
		0, screenDimsCm(2)/py, -screenDimsCm(2)/2];
	
	M = T * [mouseState.x, mouseState.y, 1]';
	cmCoords.x = M(1);
	cmCoords.y = M(2);
else
	cmCoords = [];
end
