function [texture textureDims] = GenCheckerboard(windowPtr, tileRows, tileColumns, colors, isMOGL, numPixels)
% [texture textureDims] = GenCheckerboard(windowPtr, tileRows, tileColumns, [colors], [isMOGL], [numPixels])
%   Generates a checkerboard as a texture.  By default, the checkerboard is
%   black and white.
%
%   'windowPtr' is the pointer to the window we're drawing into.
%
%   'tileRows' and 'tileColumns' specify the the number of tile rows and
%   tile columns in the checkerboard.  A tile is composed of 2 squares: one
%   of each of the colors in 'colors'.
%
%   'colors' is an optional 2x3 matrix that holds the colors for both
%   squares in a tile.  Each row specifies an RGB value.  If omitted, the
%   colors default to black and white.
%
%   If 'isMOGL' is set to true, the the caller can expect that when this
%   function returns we'll still be in MOGL mode.  By default, this is set
%   to false.
%	
%	'numPixels' set the number of pixels used for each tile.  The higher
%	the number, the greater the texture resolution will be.  This defaults
%	to 10.

if nargin < 3 || nargin > 6
    error('Usage: [texture textureDims] = GenCheckerboard(windowPtr, tileRows, tileColumns, [colors], [isMOGL], [numPixels])');
end

switch nargin
    case 3
        colors = [0, 0, 0; 255, 255, 255];
        isMOGL = false;
		numPixels = 10;
    case 4
        isMOGL = false;
		numPixels = 10;
	case 5
		numPixels = 10;
end

% Setup some defaults if an empty matrix was entered for any of the
% optional parameters.
if isempty(colors)
	colors = [0, 0, 0; 255, 255, 255];
end
if isempty(isMOGL)
	isMOGL = false;
end
if isempty(numPixels)
	numPixels = 10;
end

if size(colors, 1) ~= 2 || size(colors, 2) ~= 3
	error('colors must be a 2x3 matrix with each row being an RGB value.');
end

% Generate a black and white checkerboard.
cb = double(checkerboard(numPixels, tileRows, tileColumns) > 0.5);

% Find all the locations of the white color and black color.
[wx, wy] = find(cb == 0);
[bx, by] = find(cb == 1);

% Create a matrix to hold all the RGB values for the checkerboard.
rgbCB = zeros(size(cb, 1), size(cb, 2), 3);
textureDims = [size(rgbCB, 2), size(rgbCB, 1)];

% Switch black and white with whatever colors the user specified.
for i = 1:length(wx)
    rgbCB(wx(i), wy(i), :) = colors(1, :);
    rgbCB(bx(i), by(i), :) = colors(2, :);
end

% Convert the colors into the 0-255 world from whatever the color range was set to.
cr = Screen('ColorRange', windowPtr);
rgbCB = round(rgbCB ./ cr .* 255);

if isMOGL
    Screen('EndOpenGL', windowPtr);
end

texture = Screen('MakeTexture', windowPtr, rgbCB);

if isMOGL
    Screen('BeginOpenGL', windowPtr, 1);
end
