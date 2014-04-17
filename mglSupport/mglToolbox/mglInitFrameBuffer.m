function [fbObject, fbTexture] = mglInitFrameBuffer(textureSize)
% [fbObject, fbTexture] = mglInitFrameBuffer(textureSize)
%	Initializes a framebuffer object.
%	
%	Inputs:
%		textureSize -- Texture width/height in pixels, defaults to 2048.
%
%	Outputs:
%		fbObject -- Reference to the framebuffer object.
%		fbTexture -- Reference to the framebuffer texture

global GL;

% Setup defaults.
if ~exist('textureSize','var'), textureSize = 2048; end

% Create the frame buffer object.
fbObject = glGenFramebuffersEXT(1);

if numel(textureSize) == 1
	textureSize(2) = textureSize(1);
end

if textureSize(1) == textureSize(2)
	textureType = GL.TEXTURE_2D;
else
	textureType = GL.TEXTURE_RECTANGLE_ARB;
end

% Bind the framebuffer object and create an empty texture which is where
% we'll draw to.
glBindFramebufferEXT(GL.FRAMEBUFFER_EXT, fbObject);

% Color buffer.
fbTexture = glGenTextures(1);
glBindTexture(textureType, fbTexture);
glTexParameterf(textureType, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
glTexParameterf(textureType, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
glTexParameterf(textureType, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
glTexParameterf(textureType, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
glTexImage2D(textureType, 0, GL.RGBA8, textureSize(1), textureSize(2), 0, GL.RGBA, GL.UNSIGNED_BYTE, 0);

% Stencil and depth buffer.
%rboID = glGenRenderbuffersEXT(1);
%glBindRenderbufferEXT(GL.RENDERBUFFER_EXT, rboID);
%glRenderbufferStorageEXT(GL.RENDERBUFFER_EXT, GL.STENCIL_INDEX, textureSize(1), textureSize(2));
%glRenderbufferStorageEXT(GL.RENDERBUFFER_EXT, GL.DEPTH_COMPONENT, textureSize(1), textureSize(2));
%glBindRenderbufferEXT(GL.RENDERBUFFER_EXT, 0);

% Attach the buffers.
glFramebufferTexture2DEXT(GL.FRAMEBUFFER_EXT, GL.COLOR_ATTACHMENT0_EXT, textureType, fbTexture, 0);
%glFramebufferRenderbufferEXT(GL.FRAMEBUFFER_EXT, GL.DEPTH_ATTACHMENT_EXT, GL.RENDERBUFFER_EXT, rboID);
%glFramebufferRenderbufferEXT(GL.FRAMEBUFFER_EXT, GL.STENCIL_ATTACHMENT_EXT, GL.RENDERBUFFER_EXT, rboID);


status = glCheckFramebufferStatusEXT(GL.FRAMEBUFFER_EXT);

% Check for errors.
if status ~= GL.FRAMEBUFFER_COMPLETE_EXT
	error('mglInitFrameBuffer: failed to create a framebuffer');
end

% Unbind the framebuffer object for later use.
glBindFramebufferEXT(GL.FRAMEBUFFER_EXT, 0);
