function mglFBEnd
% mglFBEnd
%	Indicates that OpenGL command need no longer be directed into the
%	framebuffer.
global GL;

% Make the window the target
glPopAttrib;
glBindFramebufferEXT(GL.FRAMEBUFFER_EXT, 0);
