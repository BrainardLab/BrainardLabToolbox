% GLWObj = GLWindow(windowparams)
%
% Description:
% Constructor for a GLWindow object.  Takes key/value pair inputs to set
% various parameters of the window.  Returns a new GLWindow object.  This
% value must be kept track of in order to use any of the classes member
% functions.
%
% Available Key/Value Pairs:
% * 'BackgroundColor', 1x3|1x4 double - RGB or RGBA background color.
%    Values should be in the range [0,1].
% * 'DisplayType', string - Sets the display type.  Can be any of the
%    following values: 'normal', 'bit++', or 'hdr'.  Default: 'normal'.
% * 'Fullscreen', logical - Toggles fullscreen mode on/off.  Default:
%    true.
% * 'SceneDimensions', 1x2 or 1x3 (for stereo) double - Specifies the axes range of the
%    embedded OpenGL window.  That means if you specify a value of [10 10],
%    the window will only display objects drawn into the [-5 5 -5 5] axes
%    space.  Most likely, you will set this to the viewable display size in
%    centimeters of the monitor that will display the stimulus.  Default: [30 30].
% * 'WindowID', integer - Specifies the display to create the OpenGL
%    window.  The main screen has a WindowID of 1, the last screen attached
%    to the computer will have a WindowID of <number of monitors>.  If the
%    window is opened in non fullscreen mode, the screenID should be an
%    arbitrary integer greater than 0.  Default: Last available display.
% * 'WindowPosition', 1x2 integer - Specifies the location of the upper left
%    corner of the window in non fullscreen mode in screen pixels.  Default: [0 0].
% * 'WindowSize', 1x2 integer - Specifies the width and height of a non
%    fullscreen window in pixels. Default: [300 300].

classdef GLWindow < handle
	% Properties internal to the class I don't want users to see or be able
	% to set.
	properties (Access = private)
		% True if the gamma is set automatically when in Bits++ mode.
		AutoGamma;
		
		% This variable is used to track the location (index) into the
		% gamma that a particular object color is using.  When an object is
		% created, it is assigned a Bits++ index into the gamma where we
		% will set its actual color.  The color of the object in the
		% framebuffer will be its Bits++ index minus 1 divided by 255.  We
		% start it at 2 because we will always use a Bits++ index of 0 to
		% specify the background color.
		BitsPPIndex = 2;
		
		% True if the gamma was specifically specified by the user.
		GammaSpecified = false;
		
		% True if the OpenGL windows are open.
		IsOpen = false;
		
		% This flags if the next function call should be understood to have
		% been called internally by the class.  This is useful if you want
		% a function to modify its functionality based on who's calling a
		% class member function.
		InternalCall = false;
		
		% Cell array which contains the queue of objects added.
		Objects = {};
		
		% Struct array keeping track of some of the low level window
		% information.  Some GLWindow display types have multiple MGL
		% windows associated with them.
		WindowInfo = [];
		
		% Numerical representation of the display type.
		DisplayTypeID;
		
		% Struct that holds any installed shaders attached to the GLWindow.
		Shaders;
		
        % Flag that indicates if we're using legacy MGL libraries.
        MGLLegacy = false;
	end
	
	% Properties that aren't settable, but the user can see.
	properties (SetAccess = private)
		% The low level display information.
		DisplayInfo;
		
		% Toggles fullscreen mode.
		FullScreen;
		
		% Toggles cursor visibility.
		HideCursor;
		
		% Toggles multisampling.
		Multisampling;
		
		% This lets you explicitly turn off any warping.  Mainly used for
		% debugging, it's not advisable to use this in production code.
		NoWarp;
		
		% The number of displays used.
		NumWindows;
		
		% The debug level MOGL calls use.
		OpenGLDebugLevel;
		
		% Size of the OpenGL window(s) in pixels (width, height).
		WindowSize;
		
		% Shader for post processing of the scene.  Currently, only works
		% with warping enabled.
		PostProcessingShader;
	end
	
	% Publically viewable and settable properties.
	properties
		% If true, diagnostic messages are printed to the console.
		DiagnosticMode;
		
		% The coordinate system dimensions of the OpenGL window.
		SceneDimensions;
		
		% X,Y,Z scaling applied to all windows.
		Scale = [1 1 1];
	end
	
	% These properties depend on other properties to load properly, thus
	% must be set Dependent.  Dependent properties don't have their set
	% functions called when loaded from a file.
	properties (Dependent = true)
		% Background Color.
		BackgroundColor;
		
		% Gamma.
		Gamma;
		
		% The distance between the pupils of the observers eyes.  Only
		% useful for rendering in stereo modes.
		InterocularDistance;
		
		% The [x,y,z] position of the 3D cursor. Only useful for rendering in stereo modes.
		Cursor3Dposition;
		
	end
	
	% Dependent private properties.  See above comment for why we're doing
	% this.  Users can see these properties, but can't set them.
	properties (SetAccess = private, Dependent = true)
		% The selected display type.
		DisplayType;
		
		% Indicates if the GLWindow is being rendered in 2D or 3D.
		Is3D;
		
		% The warp file(s) for the back screen of a HDR display.
		WarpFile;
		
		% The window ID(s) used for each OpenGL window.
		WindowID;
		
		% The position of the OpenGL window(s) in screen pixel coordinates.
		WindowPosition;
	end
	
	% Private versions of some of the public properties.  These private
	% variables are used to thwart class loading ordering issues as suggested
	% by Matlab's documentation.
	properties (Access = private)
		PrivateBackgroundColor;
		PrivateGamma;
		PrivateInterocularDistance;
		PrivateCursor3Dposition;
		PrivateDisplayType;
		PrivateWarpFile;
		PrivateWindowID;
		PrivateWindowPosition;
	end
	
	% Constants
	properties (Constant = true)
		% The types of displays GLWindow knows about.
		DisplayTypes = struct('Normal', 1, 'BitsPP', 2, 'HDR', 3, ...
			'Stereo', 4, 'StereoBitsPP', 5, 'StereoHDR', 6);
		
		% Object types that we can add to the GLWindow.
		ObjectTypes = struct('Rect', 1, 'Oval', 2, 'Mondrian', 3, ...
			'Image', 4, 'Text', 5, 'Noise', 6, 'DotSet', 7, 'Cross', 8, ...
			'Triangle', 9, 'Grating', 10, 'Line', 11, 'PolygonSet', 12, ...
			'Wedge', 13, 'MultiChromaDotSet', 14, 'AlignmentGrid', 15, ...
            'MonocularCursor2D', 16, 'CrossHairsCursor3D', 17, 'SimpleCursor3D', 18, ...
            'HollowRectangle', 19 );
		
		% Render methods for objects.
		RenderMethods = struct('Normal', 1, 'Texture', 2);
		
		% Variations of the Mondrian object type.
		MondrianTypes = struct('Normal', 1, 'HorizontalAdelson', 2, ...
			'VerticalAdelson', 3, 'SmoothWall', 4, 'JaggedWall', 5);
		
		% Display identifiers used by different display types.  Many
		% properties can be set using a struct with specific fieldnames,
		% e.g. the color for a rectangle on an HDR display can be passed as
		% a struct with the fields 'front' and 'back'.  We define them here
		% so they're in a common location.
		DisplayFields = struct('StereoHDR', {{'left_front' 'left_back' 'right_front' 'right_back'}}, ...
							   'HDR', {{'front' 'back'}}, ...
							   'Stereo', {{'left' 'right'}});
	end
	
	% Public methods
	methods
		% Constructor
		function GLWObj = GLWindow(varargin)
			parser = inputParser;
			parser.addParamValue('WindowID', []);
			parser.addParamValue('FullScreen', []);
			parser.addParamValue('WindowPosition', []);
			parser.addParamValue('WindowSize', []);
			parser.addParamValue('OpenGLDebugLevel', []);
			parser.addParamValue('SceneDimensions', []);
			parser.addParamValue('HideCursor', []);
			parser.addParamValue('BackgroundColor', []);
			parser.addParamValue('Gamma', -1);
			parser.addParamValue('DisplayType', []);
			parser.addParamValue('DiagnosticMode', []);
			parser.addParamValue('WarpFile', []);
			parser.addParamValue('InterocularDistance', 0);
			parser.addParamValue('Cursor3Dposition', [0 0 0.01; 0 0 0.01]);
			parser.addParamValue('NoWarp', false);
			parser.addParamValue('Multisampling', 1);
			parser.addParamValue('PostProcessingShader', []);
			
			% Execute the parser to make sure input is good.
			parser.parse(varargin{:});
			
			% Create a standard Matlab structure from the parser results.
			parserResults = parser.Results;
			
			% We flag if an explicit gamma or calibration file was passed
			% This makes it easier for later checking.
			if isnumeric(parserResults.Gamma) && isscalar(parserResults.Gamma) && parserResults.Gamma == -1
				% Only relevant to Bits++ mode. If no gamma is passed then
				% we will let GLWindow set the gamma table entries.
				GLWObj.AutoGamma = true;
				GLWObj.GammaSpecified = false;
				
				% A NaN value for the gamma means we want to use the
				% identity.
				parserResults.Gamma = [];
			else
				% If the gamma is explicitly set, we don't use the auto
				% gamma feature (only valid for Bits++).
				GLWObj.AutoGamma = false;
				
				GLWObj.GammaSpecified = true;
			end
			
			% Get display info.  The display info is a low level request
			% for information about all attached monitors.
			GLWObj.DisplayInfo = mglDescribeDisplays;
			
			% These properties are set first because other properties need
			% to know their values before being set.
			GLWObj.FullScreen = parserResults.FullScreen;
			GLWObj.DisplayType = parserResults.DisplayType;
			
			% If not in any sort of Bits++ mode, force AutoGamma to be off
			% since we don't need it.
			if ~any(GLWObj.DisplayTypeID == [GLWindow.DisplayTypes.BitsPP GLWindow.DisplayTypes.StereoBitsPP])
				GLWObj.AutoGamma = false;
			end
			
			% Take the parser results and stick them into the GLWindow
			% object's properties.
			parserFields = fieldnames(parserResults);
			for i = 1:length(parserFields)
				fieldName = parserFields{i};
				
				% Don't bother with the 'DisplayType' or 'FullScreen'
				% properties because they were already set.
				if ~any(strcmp(fieldName, {'DisplayType', 'FullScreen'}))
					GLWObj.(fieldName) = parserResults.(fieldName);
				end
			end
            
            % Look to see if we're using the old MGL.
            if exist('mgllegacy.txt', 'file')
                GLWObj.MGLLegacy = true;
            end
			
			% Setup some data in the WindowInfo property that's not set
			% elsewhere.  For most other variables in WindowInfo I've tried
			% to make use of the class property set functions to set the
			% data related to the property itself.  I'm not sure if this is
			% a great or terrible idea, but that's how it is.  Stuff in
			% this section is code that at the time didn't fit in well with
			% any property functions.
			switch GLWObj.DisplayTypeID
				case GLWObj.DisplayTypes.Normal					
					% No Bits++
					GLWObj.WindowInfo.BitsPP = false;
					
				case GLWObj.DisplayTypes.BitsPP					
					% Use Bits++
					GLWObj.WindowInfo.BitsPP = true;
					
					% Reset the background color here because the ordering
					% of the initial property setting may have caused the
					% default Gamma to overwrite the one made by setting
					% the BackgroundColor in AutoGamma mode.
					GLWObj.BackgroundColor = GLWObj.BackgroundColor;
					
				case GLWObj.DisplayTypes.StereoBitsPP
					for i = 1:GLWObj.NumWindows
						% Use Bits++ gamma.
						GLWObj.WindowInfo(i).BitsPP = true;
					end
					
					% Reset the background color here because the ordering
					% of the initial property setting may have caused the
					% default Gamma to overwrite the one made by setting
					% the BackgroundColor in AutoGamma mode.
					GLWObj.BackgroundColor = GLWObj.BackgroundColor;
					
				case GLWObj.DisplayTypes.Stereo
					for i = 1:GLWObj.NumWindows
						% No Bits++
						GLWObj.WindowInfo(i).BitsPP = false;
					end
					
				case GLWObj.DisplayTypes.HDR
					for i = 1:GLWObj.NumWindows
						% No Bits++
						GLWObj.WindowInfo(i).BitsPP = false;
					end
					
				case GLWObj.DisplayTypes.StereoHDR
					for i = 1:GLWObj.NumWindows
						% No Bits++
						GLWObj.WindowInfo(i).BitsPP = false;
					end
					
				otherwise
					error('Invalid display type of "%s" requested.', GLWObj.DisplayType);
			end
        end
		
        % Destructor
        function delete(GLWObj)
            close(GLWObj)
        end
        
		% Closes all windows attached to the GLWindow.
		close(GLWObj)
		
		% Opens all windows necessary for the GLWindow.
		open(GLWObj)

		% Draws the scene.
		swapTimes = draw(GLWObj, clearPreviousScene)
		
		% Adds a 3D cursor to the scene
		addCursor3D(GLWObj, diameter, diskDiamter, lineWidth, rgbColor, varargin);
		
        % Adds a 3D cursor to the scene
		addSimpleCursor3D(GLWObj, diameter,  rgbColor, varargin);
        
        % Adds an alignment grid to the scene (this is used to verify stereo alignment)
		addAlignmentGrid(GLWObj, nodePositions, rgbColor, varargin);
        
		% Adds a rectangle to the scene.
		addRectangle(GLWObj, center, dimensions, rgbColor, varargin)
		
		% Adds an oval to the scene.
		addOval(GLWObj, center, dimensions, rgbColor, varargin)
		
		% Adds a line to the scene.
		addLine(GLWObj, startPoint, endPoint, thickNess, rgbColor, varargin)
		
		% Adds a dot set.
		addDotSet(GLWObj, dotPositions, rgbColors, dotSize, varargin)
		
		% Adds a cross to the scene.
		addCross(GLWObj, center, dimensions, rgbColor, varargin)
		
		% Adds a set of polygons.
		addPolygonSet(GLWObj, vertexList, rgbColor, varargin);
		
		% Disables an object.
		disableObject(GLWObj, objectName)
        
        % Disables all objects.
        disableAllObjects(GLWObj, objectExclusions)
		
		% Enables an object.
		enableObject(GLWObj, objectName)
		
		% Sets an object's color.
		setObjectColor(GLWObj, objectName, objectColor)
		
		% Sets the text for a Text object.
		setText(GLWObj, objectName, newText)
		
		% Deletes and object from the queue.
		deleteObject(GLWObj, objectName)
		
		% Sets a Mondrian patch color.
		setMondrianPatchColor(GLWObj, mondrianName, rowIndex, colIndex, patchColor)
		
		% Sets a Mondrian patch depth.
		setMondrianPatchDepth(GLWObj, mondrianName, rowIndex, colIndex, patchDepth)
		
		% Sets a Mondrian patch rotation.
		setMondrianPatchRotation(GLWObj, mondrianName, rowIndex, colIndex, patchRotation)
		
		images = dumpSceneToTiff(GLWObj, tiffFileName)
		
		objectList = showQueue(GLWObj, quiet)
		
        % Finds and object's index into the object render queue.
		index = findObjectIndex(GLWObj, objectName)
        
		% Clears the object queue.
		wipe(GLWObj, exclusions)
	end % Public methods
	
	% Overrides for the = operator.  Each property should have one of these
	% that validates its input and sets up default values.
	methods
		function val = get.Is3D(GLWObj)
			if length(GLWObj.SceneDimensions) == 3
				val = true;
			else
				val = false;
			end
		end
		
		% Scale
		function set.Scale(GLWObj, desiredScale)
			% Make sure the scale is in the right format.
			if isnumeric(desiredScale) && ndims(desiredScale) == 2 && all(size(desiredScale) == [1 3])
				GLWObj.Scale = desiredScale;
			elseif isempty(desiredScale)
				GLWObj.Scale = [1 1 1];
			else
				error('Scale should be a 1x3 array of floating point values.');
			end
		end
		
		% BackgroundColor
		function set.BackgroundColor(GLWObj, desiredBackgroundColor)
			GLWObj.PrivateBackgroundColor = GLW_ValidateBackgroundColor(desiredBackgroundColor, GLWObj.DisplayTypeID);
			
			% Grab a copy of the gamma for AutoGamma mode because we want to
			% modify it's contents without triggering the Gamma set
			% function.
			if GLWObj.AutoGamma
				%  If the Gamma property isn't initialized, we'll do that
				%  now so that we'll have something to work with.
				if isempty(GLWObj.Gamma)
					GLWObj.Gamma = [];
				end
				
				aGamma = GLWObj.Gamma;
			end
			
			for i = 1:GLWObj.NumWindows
				% In AutoGamma mode, the background color is always the
				% first element of the Gamma, i.e. RGB [0 0 0].
				if GLWObj.AutoGamma
					GLWObj.WindowInfo(i).BackgroundColor = [0 0 0 0];
					aGamma{i}(1,:) = GLWObj.PrivateBackgroundColor(i, 1:3);
				else
					GLWObj.WindowInfo(i).BackgroundColor = GLWObj.PrivateBackgroundColor(i,:);
				end
			end
			
			if GLWObj.AutoGamma
				% Now that we've updated our Gamma copy, let's update the
				% real thing.
				GLWObj.Gamma = aGamma;
			end
		end
		function b = get.BackgroundColor(GLWObj)
			b = GLWObj.PrivateBackgroundColor;
		end
		
		% DiagnosticMode
		function set.DiagnosticMode(GLWObj, val)
			if isempty(val)
				val = false;
			elseif ~islogical(val)
				error('DiagnosticMode must be set to a logical.');
			end
			
			GLWObj.DiagnosticMode = val;
		end
		
		% Interocular distance.
		function set.InterocularDistance(GLWObj, ioDist)
			switch GLWObj.DisplayTypeID
				case {GLWindow.DisplayTypes.Normal, GLWindow.DisplayTypes.BitsPP}
					% For single display setups, we'll just use the right
					% eye's view.
					GLWObj.WindowInfo.InterocularOffset = ioDist/2;
					
				case {GLWindow.DisplayTypes.Stereo, GLWindow.DisplayTypes.StereoBitsPP}
					GLWObj.WindowInfo(1).InterocularOffset = -ioDist/2; % Left screen
					GLWObj.WindowInfo(2).InterocularOffset = ioDist/2;  % Right screen
					
				case GLWindow.DisplayTypes.StereoHDR
					% Left displays
					for i = 1:2
						GLWObj.WindowInfo(i).InterocularOffset = -ioDist/2;
					end
					
					% Right displays
					for i = 3:4
						GLWObj.WindowInfo(i).InterocularOffset = ioDist/2;
					end
					
				otherwise
					for i = 1:GLWObj.NumWindows
						GLWObj.WindowInfo(i).InterocularOffset = 0;
					end
					
			end
			
			GLWObj.PrivateInterocularDistance = ioDist;
		end
		function ioDist = get.InterocularDistance(GLWObj)
			ioDist = GLWObj.PrivateInterocularDistance;
		end
		
		
		% Cursor 3D position.
		function set.Cursor3Dposition(GLWObj, cursor3Dposition)
            
			switch GLWObj.DisplayTypeID
				case {GLWindow.DisplayTypes.Normal, GLWindow.DisplayTypes.BitsPP}
					% For single display setups, we'll just use the entered position
					GLWObj.WindowInfo.Cursor3Dposition = cursor3Dposition;
					
				case {GLWindow.DisplayTypes.Stereo, GLWindow.DisplayTypes.StereoBitsPP}
                    % If we are using the Radiance warping, that includes a
                    % translation component (which only applies to
                    % pre-rendered images using Radiance, Blender etc),
                    % in which left and right images have been rendered using the off-axis method
                    % i.e., by shifting the camera to the left for the left
                    % eye view and right for the right eye view
                    % We do not the cursor to be shifted in the same way so
                    % substract this translation component from the
                    % specified position. If we are using the NoRadiance
                    % warping, the WarpTranslation will be [0 0], so the
                    % following correction will have no effect.
                    for displayIndex = 1:2
                        xShift = GLWObj.WindowInfo(displayIndex).WarpTranslation(1);
                        yShift = GLWObj.WindowInfo(displayIndex).WarpTranslation(2);
                        GLWObj.WindowInfo(displayIndex).Cursor3Dposition = cursor3Dposition(displayIndex,:) - [xShift yShift 0];
                    end
					
				case GLWindow.DisplayTypes.StereoHDR
					% Left displays
                    for displayIndex = 1:2
                        xShift = GLWObj.WindowInfo(displayIndex).WarpTranslation(1);
                        yShift = GLWObj.WindowInfo(displayIndex).WarpTranslation(2);
                        GLWObj.WindowInfo(displayIndex).Cursor3Dposition = cursor3Dposition(displayIndex,:) - [xShift yShift 0];  
                    end
                    
					% Right displays
					for displayIndex = 3:4
                        xShift = GLWObj.WindowInfo(displayIndex).WarpTranslation(1);
                        yShift = GLWObj.WindowInfo(displayIndex).WarpTranslation(2);
                        GLWObj.WindowInfo(displayIndex).Cursor3Dposition = cursor3Dposition(displayIndex,:) - [xShift yShift 0];  
                    end
					
				otherwise
					for i = 1:GLWObj.NumWindows
						GLWObj.WindowInfo(i).Cursor3Dposition = [0 0 0];
                    end
            end
	
            
            for displayIndex = 1:GLWObj.NumWindows
                if ((isfield(GLWObj, 'PrivateCursor3Dposition')) && (isfield(GLWObj.WindowInfo(displayIndex), 'Cursor3Dposition')))
                    GLWObj.PrivateCursor3Dposition(displayIndex,:) =  GLWObj.WindowInfo(displayIndex).Cursor3Dposition;
                end
            end
        end
        
		function cursor3DpositionInVirtualAndScreenCoords = get.Cursor3Dposition(GLWObj)
            
            % This is the capital Z (should be 76.4 cm for our stereo rig)
            ZDistanceOfVergencePlaneFromViewer = GLWObj.SceneDimensions(3);
            
            % This is the inter-ocular distance
            epsilon = GLWObj.InterocularDistance;
            
            cursor3DpositionInVirtualAndScreenCoords = struct;
            cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition = GLWObj.PrivateCursor3Dposition;

            switch GLWObj.DisplayTypeID
				case {GLWindow.DisplayTypes.Normal, GLWindow.DisplayTypes.BitsPP}
                    % For single display setups, we'll just use the entered position
                    cursor3DpositionInVirtualAndScreenCoords.screenCoords = GLWObj.PrivateCursor3Dposition;
                    
                case {GLWindow.DisplayTypes.Stereo, GLWindow.DisplayTypes.StereoBitsPP}
                   
                    for displayIndex = 1:2
                        
                        if (GLWObj.PrivateCursor3Dposition(displayIndex,3) > -200)
                            % Since the z-coord in openGL is zero at the
                            % vergence plane, whereas the z-coord in virtual screen coords is zero at the cyclopean
                            % eye position, we have to do the following coordinate inversion
                            cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,3) = ZDistanceOfVergencePlaneFromViewer - cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,3);
                        else
                           % z < 200 corresponds to a cursor that is supposed to be invisible, so do not do anything 
                           %fprintf('Ignoring mouse at display index: %d (z = %2.2f)\n', displayIndex, GLWObj.PrivateCursor3Dposition(displayIndex,3));
                           cursor3DpositionInVirtualAndScreenCoords.screenCoords(displayIndex,1:2) = [nan nan];
                           continue;
                        end
            
                        %fprintf('Computing screen coords for mouse at display index: %d (z = %2.2f)\n', displayIndex, GLWObj.PrivateCursor3Dposition(displayIndex,3));
                        
                        if (abs(GLWObj.PrivateCursor3Dposition(displayIndex,3)) <= 0.1)
                            % let's assume that the cursor is effectively at zero
                            cursor3DpositionInVirtualAndScreenCoords.screenCoords(displayIndex,1:2) = cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,1:2);
                        else
                            [xLeftScreen, yLeftScreen, xRightScreen, yRightScreen] = ...
                                StereoViewController.virtualXYZpositionToScreenCoords(cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,1), ...
                                                                                      cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,2), ...
                                                                                      cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,3), ...
                                                                                      ZDistanceOfVergencePlaneFromViewer, epsilon);
                            if (displayIndex == 1)
                                cursor3DpositionInVirtualAndScreenCoords.screenCoords(displayIndex,:) = [xLeftScreen yLeftScreen];
                            else
                                cursor3DpositionInVirtualAndScreenCoords.screenCoords(displayIndex,:) = [xRightScreen yRightScreen];
                            end
                        end
                    end % for displayIndex
                    
                case GLWindow.DisplayTypes.StereoHDR
                    
                    for displayIndex = 1:4
                        
                        if (GLWObj.PrivateCursor3Dposition(displayIndex,3) > -200)
                            % Since the z-coord in openGL is zero at the
                            % vergence plane, whereas the z-coord in virtual screen coords is zero at the cyclopean
                            % eye position, we have to do the following coordinate inversion
                            cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,3) = ZDistanceOfVergencePlaneFromViewer - cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,3);
                        else
                           % z < 200 corresponds to a cursor that is supposed to be invisible, so do not do anything 
                           %fprintf('Ignoring mouse at display index: %d (z = %2.2f)\n', displayIndex, GLWObj.PrivateCursor3Dposition(displayIndex,3));
                           cursor3DpositionInVirtualAndScreenCoords.screenCoords(displayIndex,1:2) = [nan nan];
                           continue;
                        end
                    
                       if (abs(GLWObj.PrivateCursor3Dposition(displayIndex,3)) <= 0.1)
                            % let's assume that the cursor is effectively at zero
                            cursor3DpositionInVirtualAndScreenCoords.screenCoords(displayIndex,1:2) = cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,1:2);
                        else
                            [xLeftScreen, yLeftScreen, xRightScreen, yRightScreen] = ...
                                StereoViewController.virtualXYZpositionToScreenCoords(cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,1), ...
                                                                                      cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,2), ...
                                                                                      cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(displayIndex,3), ...
                                                                                      ZDistanceOfVergencePlaneFromViewer, epsilon);
                            if (displayIndex == 1) ||  (displayIndex == 2)  
                                % front and back left displays (respectively)
                                cursor3DpositionInVirtualAndScreenCoords.screenCoords(displayIndex,:) = [xLeftScreen yLeftScreen];
                            else
                                %front and back right displays (3,4, respectively)
                                cursor3DpositionInVirtualAndScreenCoords.screenCoords(displayIndex,:) = [xRightScreen yRightScreen];
                            end
                      end  
                  end
            end
		end
		
		% DisplayType
		function set.DisplayType(GLWObj, desiredDisplayType)
			% Make sure we haven't already called this set method because
			% we don't want to overwrite the WindowInfo property that
			% contains a lot of information.
			if ~isempty(GLWObj.WindowInfo)
				error('This property setting function should only be called once per GLWindow instance.');
			end
			
			[GLWObj.PrivateDisplayType, GLWObj.DisplayTypeID] = GLW_ValidateDisplayType(desiredDisplayType);
			
			% Set the number of windows we're going to use for this display
			% type.
			switch GLWObj.DisplayTypeID
				case GLWObj.DisplayTypes.Normal
					GLWObj.NumWindows = 1;
				case GLWObj.DisplayTypes.BitsPP
					GLWObj.NumWindows = 1;
				case {GLWObj.DisplayTypes.Stereo, GLWObj.DisplayTypes.StereoBitsPP}
					GLWObj.NumWindows = 2;
				case GLWObj.DisplayTypes.HDR
					GLWObj.NumWindows = 2;
				case GLWObj.DisplayTypes.StereoHDR
					GLWObj.NumWindows = 4;
				otherwise
					error('Invalid display type ID: %d', GLWObj.DisplayTypeID);
			end
			
			% Initialize the struct array we'll use to keep information
			% about each window.
			GLWObj.WindowInfo = GLW_CreateWindowInfoStruct(GLWObj.NumWindows);
		end
		function d = get.DisplayType(GLWObj)
			d = GLWObj.PrivateDisplayType;
		end
		
		% FullScreen
		function set.FullScreen(GLWObj, val)
			if isempty(val)
				val = true;
			elseif ~islogical(val)
				error('FullScreen must be a logical value.');
			end
			
			GLWObj.FullScreen = val;
		end
		
		% HideCursor
		function set.HideCursor(GLWObj, val)
			if isempty(val)
				val = false;
			elseif ~islogical(val)
				error('HideCursor must be a logical value.');
			end
			
			GLWObj.HideCursor = val;
		end
		
		% WarpFile
		function set.WarpFile(GLWObj, desiredWarpFile)
			GLWObj.PrivateWarpFile = GLW_ValidateWarpFile(desiredWarpFile, GLWObj.DisplayTypeID);
			
			switch GLWObj.DisplayTypeID
				case GLWObj.DisplayTypes.Normal
					% Toggle warping if a warp file was specified.
					if isempty(GLWObj.PrivateWarpFile)
						GLWObj.WindowInfo.Warp = false;
					else
						GLWObj.WindowInfo.Warp = true;
						GLWObj.WindowInfo.WarpFile = GLWObj.PrivateWarpFile{1};
						
						% These properties aren't set for normal warping in
						% the calibration file so set them to do nothing
						% here.
						GLWObj.WindowInfo.WarpTranslation = [0 0];
						GLWObj.WindowInfo.WarpScale = [1 1];
					end
					
				case GLWObj.DisplayTypes.BitsPP
					% Toggle warping on if the warpfile name isn't NaN.
					if ~isempty(GLWObj.PrivateWarpFile)
						GLWObj.WindowInfo.Warp = true;
						GLWObj.WindowInfo.WarpFile = GLWObj.PrivateWarpFile{1};
						
						% These properties aren't set for normal warping in
						% the calibration file so set them to do nothing
						% here.
						GLWObj.WindowInfo.WarpTranslation = [0 0];
						GLWObj.WindowInfo.WarpScale = [1 1];
					else
						GLWObj.WindowInfo.Warp = false;
					end
					
				case GLWObj.DisplayTypes.StereoBitsPP
					% All windows are warped in stereo mode.
					for i = 1:GLWObj.NumWindows
						GLWObj.WindowInfo(i).Warp = true;
						GLWObj.WindowInfo(i).WarpFile = GLWObj.PrivateWarpFile{i};
					end
					
				case {GLWObj.DisplayTypes.Stereo, GLWObj.DisplayTypes.StereoHDR}
					% All windows are warped in stereo and stereo HDR
					% modes.
					for i = 1:GLWObj.NumWindows
						GLWObj.WindowInfo(i).Warp = true;
						GLWObj.WindowInfo(i).WarpFile = GLWObj.PrivateWarpFile{i};
					end
					
				case GLWObj.DisplayTypes.HDR
					% Toggle the back screen (projector) to be warped.
					GLWObj.WindowInfo(1).Warp = false;
					GLWObj.WindowInfo(2).Warp = true;
					
					% These properties aren't set for normal warping in
					% the calibration file so set them to do nothing
					% here.
					GLWObj.WindowInfo(2).WarpTranslation = [0 0];
					GLWObj.WindowInfo(2).WarpScale = [1 1];
					
					GLWObj.WindowInfo(2).WarpFile = GLWObj.PrivateWarpFile{1};
					
				otherwise
					error('Invalid display type of "%s" requested.', GLWObj.DisplayType);
			end
		end
		function w = get.WarpFile(GLWObj)
			w = GLWObj.PrivateWarpFile;
		end
		
		% Gamma
		function set.Gamma(GLWObj, gammaValue)
			GLWObj.PrivateGamma = GLW_ValidateGamma(gammaValue, GLWObj.DisplayTypeID);
			
			% Update WindowInfo.
			for i = 1:GLWObj.NumWindows
				GLWObj.WindowInfo(i).Gamma = GLWObj.PrivateGamma{i};
				
				% Go ahead and load the gamma if the window(s) is open.  We
				% don't bother setting the low level gamma for Bits++ modes
				% because it's passed to the box when we render the scene.
				if GLWObj.IsOpen && GLWObj.DisplayTypeID ~= GLWindow.DisplayTypes.BitsPP && ...
						GLWObj.DisplayTypeID ~= GLWindow.DisplayTypes.StereoBitsPP
					mglSwitchDisplay(GLWObj.WindowInfo(i).WindowID);
					mglSetGammaTable(GLWObj.WindowInfo(i).Gamma');
				end
			end
		end
		function g = get.Gamma(GLWObj)
			g = GLWObj.PrivateGamma;
		end
		
		% OpenGLDebugLevel
		function set.OpenGLDebugLevel(GLWObj, debugLevel)
			% Default
			if isempty(debugLevel)
				debugLevel = 1;
			end
			
			GLWObj.OpenGLDebugLevel = debugLevel;
			
			% Reset the OpenGL debug level in MOGL.
			InitializeMatlabOpenGL(0, GLWObj.OpenGLDebugLevel);
		end
		
		% SceneDimensions
		function set.SceneDimensions(GLWObj, desiredSceneDimensions)
			GLWObj.SceneDimensions = GLW_ValidateSceneDimensions(desiredSceneDimensions);
		end
		
		% WindowID
		function set.WindowID(GLWObj, desiredWindowID)
			GLWObj.PrivateWindowID = GLW_ValidateWindowID(desiredWindowID, GLWObj.DisplayTypeID, GLWObj.FullScreen);
			
			% For display types where there is a single window, convert the
			% default window ID value of -1 into the last display ID.
			if GLWObj.NumWindows == 1 && GLWObj.PrivateWindowID == -1
				GLWObj.PrivateWindowID = length(GLWObj.DisplayInfo);
			end
			
			% Update WindowInfo.
			for i = 1:GLWObj.NumWindows
				GLWObj.WindowInfo(i).WindowID = GLWObj.PrivateWindowID(i);
			end
		end
		function w = get.WindowID(GLWObj)
			w = GLWObj.PrivateWindowID;
		end
		
		% WindowSize
		function set.WindowSize(GLWObj, desiredWindowSize)
			GLWObj.WindowSize = GLW_ValidateWindowSize(desiredWindowSize);
		end
		
		% WindowPosition
		function set.WindowPosition(GLWObj, desiredWindowPosition)
			GLWObj.PrivateWindowPosition = GLW_ValidateWindowPosition(desiredWindowPosition, GLWObj.DisplayTypeID);
			
			for i = 1:GLWObj.NumWindows
				GLWObj.WindowInfo(i).WindowPosition = GLWObj.PrivateWindowPosition(i,:);
			end
		end
		function p = get.WindowPosition(GLWObj)
			p = GLWObj.PrivateWindowPosition;
		end
	end % Override = methods
	
	% Public static methods.  These are useful functions that can be called
	% by anyone without having to create a GLWindow instance.
	methods (Static)
		% Gets the identity gamma specific to this computer.
		identityGamma = getIdentityGamma
		
		% Calculates frustum calculations for OpenGLs projection matrix.
		[frustum, projectionMatrix] = calculateFrustum(screenDistance, screenDimensions, horizontalOffset);
		
		% Converts a display type ID into the human readable name.
		displayTypeName = displayTypeIDToName(displayTypeID)
		
		% Tesselates a polygon.
		tessVerts = tessellatePolygon(polyVerts)
		
		% Test routine.  Really just a scratchpad for testing functions
		% out.
		test
	end
	
	% Private methods
	methods (Access = private)
		% Initializes the framebuffer object for a given window, i.e.
		% warping.
		initFrameBufferObject(GLWObj, winfoID)
		
		% Create a texture for a given object ID.
		makeTexture(GLWObj, objectID)
		
		% Deletes a texture associated with an object ID.
		deleteTexture(GLWObj, objectID)
		
		% Adds and object to the render queue.
		addObjectToQueue(GLWObj, obj)
		
		% Adds the color(s) of an object to the auto gamma.
		obj = addAutoGammaColor(GLWObj, obj);
	end % Private methods
end % classdef
