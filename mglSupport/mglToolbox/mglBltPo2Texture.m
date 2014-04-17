function mglBltPo2Texture(tex, position, rotation, texCoords)
% mglBltPo2Texture - Renders a power-of-two texture.
%
% Syntax:
% mglBltPo2Texture(tex, position)
% mglBltPo2Texture(tex, position, rotation)
% mglBltPo2Texture(tex, position, rotation, texCoords)
%
% Description:
% The standard MGL install doesn't have a way to render a section of a
% power-of-two texture.  This function provides that functionality by
% allowing the user to specify the texture coordinates that will be mapped
% to the display.
%
% Input:
% tex (struct) - A texture structure created by an MGL function containing
%     a power-of-two texture, e.g. a texture created by mglCreateWrappingTexture.
% position (1x2|1x4) - Either a vector defining (x,y) position or a vector
%     defining (x,y,width,height).  If (width,height) aren't defined then
%     they will default to the pixel dimensions of the texture.
% rotation (scalar) - Rotation amount in degrees.  Defaults to 0.
% texCoords (1x4) - Defines the (s,t) bounds of the texture.  (s,t) are
%     texture coordinates that get mapped to the actual polygon defined by the
%     position parameter.  The vector is defined as [sMin, sMax, tMin,
%     tMax].  Defaults to [0 1 0 1].

global GL;

% Make sure MOGL is initialized.
if isempty(GL)
	InitializeMatlabOpenGL;
end

% Check the number of inputs.
error(nargchk(2, 4, nargin));

% Setup some defaults.
if ~exist('rotation', 'var') || isempty(rotation)
	rotation = 0;
end
if ~exist('texCoords', 'var') || isempty(texCoords)
	texCoords = [0 1 0 1];
end

% Make sure we were passed a power-of-two texture.
assert(tex.textureType == GL.TEXTURE_2D, 'mglBltPo2Texture:InvalidTextureType', ...
	'The texture must be a power-of-two texture.');

% If the width and height of the rendered texture aren't defined we use the
% pixel dimensions.
if length(position) == 2
	position(3:4) = [tex.imageWidth, tex.imageHeight];
end

% Setup the rotation and the (x,y) position of the rendered texture.
glMatrixMode(GL.MODELVIEW);
glPushMatrix;
glTranslated(position(1), position(2), 0);
glRotated(rotation, 0, 0, 1);

% Bind the texture so we can draw it.
glEnable(GL.TEXTURE_2D);
glBindTexture(GL.TEXTURE_2D, tex.textureNumber);

% This makes sure that the texture colors are rendered properly.
glColor4dv([1 1 1 1]);

glBegin(GL.QUADS);

% Lower left corner
glTexCoord2d(texCoords(1), texCoords(3));
glVertex2d(-position(3)/2, -position(4)/2);

% Lower right corner
glTexCoord2d(texCoords(2), texCoords(3));
glVertex2d(position(3)/2, -position(4)/2);

% Upper right corner
glTexCoord2d(texCoords(2), texCoords(4));
glVertex2d(position(3)/2, position(4)/2);

% Upper left corner
glTexCoord2d(texCoords(1), texCoords(4));
glVertex2d(-position(3)/2, position(4)/2);

glEnd;

% Stop rendering the texture.
glDisable(GL.TEXTURE_2D);

glPopMatrix;
