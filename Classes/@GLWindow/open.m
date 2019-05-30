function open(GLWObj)
% open
%
% Description:
% Opens a new OpenGL window.  Takes care of multiple window creation for
% certain display types like 'hdr' and 'stereo' including things like
% framebuffer object creation and setup.
%
% Usage:
% w = GLWindow;
% w.open;

global GL;

if nargin ~= 1
	error('The open method takes no arguments.');
end

% Open up all windows found in the WindowInfo property.  Each entry in
% WindowInfo should have all the information needed to open the window.
for wIndex = 1:GLWObj.NumWindows
	% Point MGL and OpenGL calls towards the specified display.
	mglSwitchDisplay(GLWObj.WindowInfo(wIndex).WindowID);
	
	% Set the multisampling flag if we're not using the old MGL version.
    if ~GLWObj.MGLLegacy
        mglSetParam('multisampling', GLWObj.Multisampling);
    end
    
	% Open the OpenGL window.
	if GLWObj.FullScreen
        if GLWObj.SpoofFullScreen
            mglSetParam('spoofFullScreen',1);
        end
		mglOpen(GLWObj.WindowInfo(wIndex).WindowID);
	else
		mglOpen(0, GLWObj.WindowSize(1), GLWObj.WindowSize(2));
		mglMoveWindow((wIndex-1)*(GLWObj.WindowSize(1)+10), 0);
	end
	
	% Setup a default gamma.  This will get changed later, but makes
	% framebuffer object creation happy for some reason.  An OpenGL error
	% will be generated otherwise.
	mglSetGammaTable([1 1 1]' * linspace(0, 1, 256));
	
	% Create a framebuffer object for the window if flagged.
	if ~GLWObj.NoWarp && GLWObj.WindowInfo(wIndex).Warp
		GLWObj.initFrameBufferObject(wIndex);
		
		% Attach the post processing shader if specified.
		if ~isempty(GLWObj.PostProcessingShader)
			% Make sure we can find the shaders.
			if ~exist([GLWObj.PostProcessingShader '.vert'], 'file') || ~exist([GLWObj.PostProcessingShader '.frag'], 'file')
				mglClose;
				error('Cannot find the vertex and/or fragment shaders for "%s".', GLWObj.PostProcessingShader);
			end
			
			GLWObj.Shaders.PostProcessing(wIndex) = mglShader('install', GLWObj.PostProcessingShader);
			mglShader('linkProgram', GLWObj.Shaders.PostProcessing(wIndex));
			mglShader('useProgram', 0);
		end
	end
	
	% We put this after the framebuffer object creation because OpenGL
	% bugs up and won't create the object if the gamma isn't the identity.
	% Bits++ modes pass the identity gamma to MGL because the actual gamma
	% is passed later to the Bits++ box.
	switch GLWObj.DisplayTypeID
		case {GLWindow.DisplayTypes.BitsPP, GLWindow.DisplayTypes.StereoBitsPP}
			mglSetGammaTable(GLWindow.getIdentityGamma');
			
		otherwise
			mglSetGammaTable(GLWObj.WindowInfo(wIndex).Gamma');
	end
	
	% Set the background color.
	mglClearScreen(GLWObj.WindowInfo(wIndex).BackgroundColor);
	
	% Enable depth testing if we're doing 3D.
	if GLWObj.Is3D
		glEnable(GL.DEPTH_TEST);
	end
	
	% Blank the window.
	mglFlush;
end

% Toggle the cursor.
mglDisplayCursor(double(~GLWObj.HideCursor));

% Indicate that the GLWindow is now "open".
GLWObj.IsOpen = true;

% Make any textures that have been added.  Textures can only be created
% after open a window, which is why we do this now if a texture object was
% added to the GLWindow instance prior to being opened.
for objectID = 1:length(GLWObj.Objects)
	% If an object is flagged to be rendered as a texture, create it.
	if GLWObj.Objects{objectID}.RenderMethod == GLWindow.RenderMethods.Texture
		GLWObj.makeTexture(objectID);
	end
end
