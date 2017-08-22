function tex = mglCreateGratingTexture(spatialFreq, pxDims, phaseShift)
% mglCreateGratingTexture - Creates an MGL bar grating texture.
%
% Syntax:
% tex = mglCreateGratingTexture(spatialFreq)
% tex = mglCreateGratingTexture(spatialFreq, pxDims)
% tex = mglCreateGratingTexture(spatialFreq, pxDims, phase)
%
% Input:
% spatialFreq (scalar) - The spatial frequency of the grating. (Hz)
% pxDims (1x2) - The dimensions of the texture. Defaults to [512, 512]. (width, height)(pixels)
% phaseShift (scalar) - Phase shift of the grating. Defaults to 0.
%
% Output:
% tex (MGL texture) - The MGL texture containing the grating.

global MGL;

narginchk(1, 3);

% Make sure that an MGL window is open before creating the texture.
if isempty(MGL) || MGL.displayNumber == -1
	error('A valid MGL window must be open before using this function.');
end

% Setup some defaults.
if ~exist('pxDims', 'var') || isempty(pxDims)
	pxDims = [512 512];
end
if ~exist('phaseShift', 'var') || isempty(phaseShift)
	phaseShift = 0;
end

% Flip the dimensions around because the create texture functions
% interprets the first value as height and the second to be width, whereas
% the user specifies width and height in that order.
pxDims = [pxDims(2), pxDims(1)];

% Round the pixel dimensions to make sure they're integer numbers.
pxDims = round(pxDims);

pxData = round(GenGrating(pxDims, spatialFreq, [], phaseShift));

% Determine if the texture dims are a power of 2.
if pxDims(1) == pxDims(2) && mod(log(pxDims(1))/log(2), 1) == 0
	tex = mglCreateTexture(pxData*255, [], 1, ...
		{'GL_TEXTURE_WRAP_S', 'GL_REPEAT', ...
		 'GL_TEXTURE_WRAP_T', 'GL_REPEAT', ...
		 'GL_TEXTURE_MAG_FILTER', 'GL_LINEAR', ...
         'GL_TEXTURE_MIN_FILTER', 'GL_LINEAR'});
else
	tex = mglCreateTexture(pxData*255, [], 0);
end
