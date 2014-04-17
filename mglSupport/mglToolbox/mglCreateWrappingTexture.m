function tex = mglCreateWrappingTexture(texData)
% mglCreateWrappingTexture - Creates an OpenGL texture that can wrap.
%
% Syntax:
% tex = mglCreateWrappingTexture(texData)
%
% Description:
% In OpenGL, power of two sized textures have a special feature that let
% you wrap the texture boundaries when applying to a polygon.  MGL doesn't
% have a built in way to generate Po2 textures, so this function allows you
% to do that using MOGL commands.
%
% Input:
% texData (MxMx3|MxMx4) - Matrix containing the texture data.  Data should
%     be in the [0,255] range.
%
% Output:
% tex (struct) - A structure containing the texture data.

global GL;

if isempty(GL)
	InitializeMatlabOpenGL;
end

% Validate the input.
d = size(texData);
assert(ndims(texData) == 3, 'mglCreateWrappingTexture:NumDims', 'Input must be a 3D matrix');
assert(d(1) == d(2) && (d(3) == 3 || d(3) == 4), 'mglCreateWrappingTexture:InvalidDims', ...
	'Input must be a MxMx3 or MxMx4 matrix');
assert(mod(log(d(1))/log(2), 1) == 0, 'mglCreateWrappingTexture:NotPowerOfTwo', ...
	'Input''s width and height dimensions must be a power of 2.');

% Create the texture and its parameters.
texID = glGenTextures(1);
glBindTexture(GL.TEXTURE_2D, texID);
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
glTexParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
glPixelStorei(GL.UNPACK_ROW_LENGTH, 0);

% Reshape the image data.
numRows = size(texData, 1);
rData = ones(4, numRows, numRows)*255;
for i = 1:3
	rData(i,:,:) = transpose(flipud(texData(:,:,i)));
end

% Load the texture data.
glTexImage2D(GL.TEXTURE_2D, 0, GL.RGBA, numRows, numRows, 0, ...
	GL.RGBA, GL.UNSIGNED_BYTE, uint8(rData));

% Store texture information in a struct used by other MGL functions.  Take
% a look at mglCreateTexture.m to see how this variable is setup.
tex.textureNumber = texID;
tex.imageWidth = numRows;
tex.imageHeight = numRows;
tex.textureAxes = 'yx';
tex.textureType = GL.TEXTURE_2D;
tex.liveBuffer = 0;
tex.textImageRect = [0 0 0 0];
tex.hFlip = 0;
tex.vFlip = 0;
tex.isText = 0;
tex.allParams = [tex.textureNumber, tex.imageWidth, tex.imageHeight, 0, ...
	tex.hFlip, tex.vFlip, 0, 0, mglGetParam('xPixelsToDevice'), ...
	mglGetParam('yPixelsToDevice'), mglGetParam('deviceHDirection'), ...
	mglGetParam('deviceVDirection'), mglGetParam('verbose'), tex.textureType];
