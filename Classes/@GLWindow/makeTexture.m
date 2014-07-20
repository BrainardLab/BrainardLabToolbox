function makeTexture(GLWObj, objectID)
% makeTexture(objectID)
%
% Description:
% Creates the texture for the object specified by "objectID".
%
% Input:
% objectID (integer) - The index into the GLWObj.Objects cell array that
%   identifies the object.

if nargin ~= 2
	error('Usage: makeTexture(objectID)');
end

if objectID < 1 || objectID > length(GLWObj.Objects)
	error('"objectID" of %d out of range.', objectID);
end

% Loop overall windows to create a texture for each OpenGL context.
for i = 1:GLWObj.NumWindows
	mglSwitchDisplay(GLWObj.WindowInfo(i).WindowID);
	
	switch GLWObj.Objects{objectID}.ObjectType
		case GLWindow.ObjectTypes.Text
			mglTextSet(GLWObj.Objects{objectID}.FontName, GLWObj.Objects{objectID}.FontSize, ...
				GLWObj.Objects{objectID}.Color(i,:), 0, 0, 0);
            
			GLWObj.Objects{objectID}.Texture(i) = mglText(GLWObj.Objects{objectID}.Text);
			
			% Create some nice texture dimensions based on the ratio of the
			% width to height of the texture.
			w = GLWObj.Objects{objectID}.Texture(i).imageWidth * GLWObj.Objects{objectID}.FontSize * GLWObj.SceneDimensions(1) / 200000;
			h = GLWObj.Objects{objectID}.Texture(i).imageHeight * GLWObj.Objects{objectID}.FontSize * GLWObj.SceneDimensions(1) / 200000;
			GLWObj.Objects{objectID}.TextDims(i,:) = [w h];
			
		case GLWindow.ObjectTypes.Image
			if isempty(GLWObj.Objects{objectID}.TextureParams)
				GLWObj.Objects{objectID}.Texture(i) = mglCreateTexture(GLWObj.Objects{objectID}.ImageData{i}*255);
			else
				GLWObj.Objects{objectID}.Texture(i) = mglCreateTexture(GLWObj.Objects{objectID}.ImageData{i}*255, 'xy', 0, ...
					GLWObj.Objects{objectID}.TextureParams);
			end
			
		case GLWindow.ObjectTypes.Grating
			GLWObj.Objects{objectID}.Texture(i) = mglCreateTexture(GLWObj.Objects{objectID}.ImageData{i}*255);
			
		otherwise
			error('Undefined texture creation procedure for object type %d.', GLWObj.Objects{objectID}.ObjectType);
	end
	
	if GLWObj.DiagnosticMode
		fprintf('* Creating texture %d for object ID %d on window ID %d.\n', ...
			i, objectID, GLWObj.WindowInfo(i).WindowID);
	end
end

% Free up the data memory that we no longer need.
switch GLWObj.Objects{objectID}.ObjectType
	case GLWindow.ObjectTypes.Image
		GLWObj.Objects{objectID}.ImageData = {};
		
	case GLWindow.ObjectTypes.Grating
		GLWObj.Objects{objectID}.ImageData = {};
end
