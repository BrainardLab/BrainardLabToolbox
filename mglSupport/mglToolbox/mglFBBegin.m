function mglFBBegin(fbObject, fbTexSize)
% mglFBBegin
%	Directs all OpenGL commands after this call to the specified 
%	framebuffer object.
%
%	Inputs:
%		fbObject -- A valid framebuffer object.
%		fbTexSize -- The size of the texture associated with the
%				framebuffer object.
global GL;

if nargin ~= 2
	error('Usage: mglFBBegin(fbObject, fbTexSize)');
end

glBindFramebufferEXT(GL.FRAMEBUFFER_EXT, fbObject);

% Save the view port and set it to the size of the texture
glPushAttrib(GL.VIEWPORT_BIT);
glViewport(0, 0, fbTexSize(1), fbTexSize(2));
