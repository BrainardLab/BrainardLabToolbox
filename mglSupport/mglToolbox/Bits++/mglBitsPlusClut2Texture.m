function texturePtr = mglBitsPlusClut2Texture(clut)
% texturePtr = mglBitsPlusClut2Texture(windowPtr, clut)
%
%   Generates an MGL texture containing the CLUT + magic code
%   required to set the clut in Bits++ mode.
%
%   'clut' should be a 256x3 matrix consisting of values in the range
%   [0,1].

if nargin ~= 1
    error('Usage: texturePtr = mglBitsPlusClut2Texture(clut)');
end

% Convert the clut into Bits++ values.
clut = clut .* (2^16 - 1);

% Convert the clut into the special one for Bits++.
encodedClut = BitsPlusEncodeClutRow(clut);

% Generate the texture holding the Bits++ clut.
texturePtr = mglCreateTexture(encodedClut);
