function swapTimes = draw(GLWObj, clearPreviousScene)
% swapTimes = draw(GLWObj, [clearPreviousScene])
%
% Description:
% Draws all objects queued.
%
% Required Input:
% GLWObj (GLWindow) - Object containing objects to be drawn.
%
% Optional Input:
% clearPreviousScene (logical) - If true, the previously drawn scene will
%     be cleared before drawing the new one.  Default: true.
%
% Output:
% swapTimes (1xN) - Returns the time in seconds when the buffer
%	swap occurred.  Returns 2 values in HDR mode: [frontTime, backTime]
%	and stereo mode: [left, right].
%
% 5/1/2013   NPC    Added option to do the WarpTranslation component of the
%                   warp transformation, when NoWarp is set to true. This
%                   is useful in combination with the dumpToTiff method, so
%                   that we can obtain images of the openGL displays as
%                   they should appear to the observer. Using the left and 
%                   right images of corresponding features, we can then 
%                   compute the depths of these features.

global MGL GL

if nargin < 1
	error('Usage: draw(GLWObj, [clearPreviousScene])');
end

if nargin == 1
	clearPreviousScene = true;
end

for wIndex = 1:GLWObj.NumWindows
	% Set our OpenGL rendering context, i.e. draw to the correct window.
	mglSwitchDisplay(GLWObj.WindowInfo(wIndex).WindowID);
	
	% Begin writing into the framebuffer object if warping is toggled.
	if ~GLWObj.NoWarp && GLWObj.WindowInfo(wIndex).Warp
		mglBindFrameBufferObject(GLWObj.WindowInfo(wIndex).FBObject);
        
        % Use the framebuffer object physical dimensions in place of the
        % actual screen dimensions.
        sceneDims = GLWObj.WindowInfo(wIndex).FBSceneDims;
    else
        sceneDims = GLWObj.SceneDimensions;
	end
	
	% Clear the previous scene if not told to keep it.
	if clearPreviousScene
        if GLWObj.MGLLegacy
            mglClearScreen(GLWObj.WindowInfo(wIndex).BackgroundColor);
        else
            mglClearScreen(GLWObj.WindowInfo(wIndex).BackgroundColor, [1 1 1 1]);
        end
	end
	
	% Setup the projection matrix.
	mglTransform('GL_PROJECTION', 'glLoadIdentity');
	if GLWObj.Is3D
		frustum = GLWindow.calculateFrustum(GLWObj.SceneDimensions(3), ...
			sceneDims(1:2), GLWObj.WindowInfo(wIndex).InterocularOffset);
           
		mglTransform('GL_PROJECTION', 'glFrustum', frustum.left, frustum.right, ...
			frustum.bottom, frustum.top, frustum.near, frustum.far);
		mglTransform('GL_MODELVIEW', 'glLoadIdentity');
		gluLookAt(GLWObj.WindowInfo(wIndex).InterocularOffset, 0, GLWObj.SceneDimensions(3), ... % Eye position
				  GLWObj.WindowInfo(wIndex).InterocularOffset, 0, 0, ...                         % Fixation center
				  0, 1, 0);																		 % Up vector
    
	else
		screenWidth = sceneDims(1);
		screenHeight = sceneDims(2);
		mglTransform('GL_PROJECTION', 'glOrtho', -screenWidth/2.0, screenWidth/2.0, ...
			-screenHeight/2.0, screenHeight/2.0, -1.0, 1.0);
		mglTransform('GL_MODELVIEW', 'glLoadIdentity');
	end
	
	% Do any scaling requested across all windows.
	mglTransform('GL_MODELVIEW', 'glScale', GLWObj.Scale(1), GLWObj.Scale(2), GLWObj.Scale(3));
	
	
	% Do warping translation and scaling if toggled.
	if ~GLWObj.NoWarp && GLWObj.WindowInfo(wIndex).Warp
		mglTransform('GL_MODELVIEW', 'glTranslate', ...
			GLWObj.WindowInfo(wIndex).WarpTranslation(1), ...
 			GLWObj.WindowInfo(wIndex).WarpTranslation(2), 0);
		mglTransform('GL_MODELVIEW', 'glScale', ...
			GLWObj.WindowInfo(wIndex).WarpScale(1), ...
 			GLWObj.WindowInfo(wIndex).WarpScale(2), 1);  
    end
	
    % Do warping translation only in NoWarp is true
    if (GLWObj.NoWarp)
        % This is useful when you want to render a TIFF of the screens as they
        % appear on the vergence plane.
        mglTransform('GL_MODELVIEW', 'glTranslate', GLWObj.WindowInfo(wIndex).InterocularOffset,0, 0);
    end
    
   % Do warping translation
    
        
	% Enable multisampling if toggled.
    if GLWObj.Multisampling
        glEnable(GL.MULTISAMPLE);
    end
	
	% Render all objects in the queue.
	for i = 1:length(GLWObj.Objects)
		% Pull out the object to a smaller variable so we can be lazy typing.
		obj = GLWObj.Objects{i};
		
		% Don't draw this object unless it's enabled.
		if obj.Enabled == false
			continue;
		end
		
		mglTransform('GL_MODELVIEW', 'glPushMatrix');
		
		switch obj.ObjectType
		
			case GLWindow.ObjectTypes.CrossHairsCursor3D
				GLW_DrawCrossHairsCursor(GLWObj.WindowInfo(wIndex).Cursor3Dposition, obj.Diameter, obj.DiskDiameter, obj.LineThickness, obj.Color(wIndex,:));

            case GLWindow.ObjectTypes.SimpleCursor3D
                GLW_DrawSimple3DCursor(GLWObj.WindowInfo(wIndex).Cursor3Dposition, obj.Diameter, obj.LineThickness, obj.Color(wIndex,:));
                
            case GLWindow.ObjectTypes.MonocularCursor2D
                GLW_DrawMonocular2DCursor(GLWObj.WindowInfo(wIndex).Cursor3Dposition, obj.Diameter, obj.LineThickness, obj.Color(wIndex,:));
                
            case GLWindow.ObjectTypes.HollowRectangle
                GLW_DrawHollowRectangle(obj.Center(wIndex,1), obj.Center(wIndex,2), obj.Center(wIndex,3), obj.Width, obj.Height, obj.LineThickness, obj.Color(wIndex,:));
                
            case GLWindow.ObjectTypes.AlignmentGrid
				GLW_DrawAlignmentGrid(squeeze(obj.NodePositions(wIndex,:,:,:)), obj.LineWidth, obj.Color(wIndex,:));
                
			case GLWindow.ObjectTypes.Oval
				mglFillOval(obj.Center(wIndex, 1), obj.Center(wIndex, 2), obj.Dimensions, obj.Color(wIndex,:));
				
			case GLWindow.ObjectTypes.Rect
				mglFillRect3D(obj.Center(wIndex,1), obj.Center(wIndex,2), ...
					obj.Center(wIndex,3), obj.Dimensions, obj.Color(wIndex,:), ...
					obj.Rotation);
			
			case GLWindow.ObjectTypes.Line
				mglLines2(obj.StartPoint(wIndex, 1), obj.StartPoint(wIndex,2), ...
					obj.EndPoint(wIndex,1), obj.EndPoint(wIndex,2), ...
					obj.Thickness, obj.Color(wIndex,:), 1);
				
			case GLWindow.ObjectTypes.Triangle
				glPushMatrix;
				glTranslated(obj.Center(1) - obj.Dimensions(1)/2, ...
					obj.Center(2) - obj.Dimensions(2)/2, 0);
				glColor3dv(obj.Color(wIndex,:));
				glBegin(GL.TRIANGLES);
				glVertex2d(0, 0);
				glVertex2d(obj.Dimensions(1), 0);
				glVertex2d(obj.Dimensions(1)/2, obj.Dimensions(2));
				glEnd;
				glPopMatrix;
				
			case GLWindow.ObjectTypes.Text
                % Translate the text along the z-dimension so it is not
                % occluded by other textures
                glPushMatrix;
                glTranslated(0, 0, 0.1);
				mglBltTexture(obj.Texture(wIndex), [obj.Center(1) obj.Center(2) obj.TextDims(wIndex,1) obj.TextDims(wIndex,2)], 0, 0);
				glPopMatrix;
                
			case {GLWindow.ObjectTypes.Image, GLWindow.ObjectTypes.Grating}
				mglBltTexture(obj.Texture(wIndex), [obj.Center(1) obj.Center(2) obj.Dimensions(1) obj.Dimensions(2)], 0, 0, obj.Rotation);
				
                
			case GLWindow.ObjectTypes.Mondrian
					GLW_DrawMondrian(obj.Verts, obj.Color{wIndex}, obj.PatchDepths, obj.PatchRotations, obj.NumRows, ...
						obj.NumColumns, obj.Center(wIndex,:), obj.Dimensions, ...
						obj.Border, obj.Rotation);
				
			case GLWindow.ObjectTypes.Cross
				% Draw the vertical bar.
				mglFillRect(obj.Center(wIndex,1), obj.Center(wIndex,2), [obj.LineThickness obj.Dimensions(2)], obj.Color(wIndex,:));
				% Draw the horizontal bar.
				mglFillRect(obj.Center(wIndex,1), obj.Center(wIndex,2),  [obj.Dimensions(1) obj.LineThickness], obj.Color(wIndex,:));
				
			case GLWindow.ObjectTypes.DotSet
				mglTransform('GL_MODELVIEW', 'glPushMatrix');
				mglTransform('GL_MODELVIEW', 'glRotate', obj.Rotation(1), ...
					obj.Rotation(2), obj.Rotation(3), obj.Rotation(4));
				
				mglPoints2(obj.DotPositions(:,1), obj.DotPositions(:,2), ...
					obj.DotSize, obj.Color(wIndex,:));
				
				mglTransform('GL_MODELVIEW', 'glPopMatrix');
				
			case GLWindow.ObjectTypes.MultiChromaDotSet
				mglTransform('GL_MODELVIEW', 'glPushMatrix');
				mglTransform('GL_MODELVIEW', 'glRotate', obj.Rotation(1), ...
					obj.Rotation(2), obj.Rotation(3), obj.Rotation(4));
				
				for dotIndex = 1:size(obj.Color, 1)
					mglPoints2(obj.DotPositions(dotIndex,1), obj.DotPositions(dotIndex,2), ...
						obj.DotSize, obj.Color(dotIndex,:));
				end
						
				mglTransform('GL_MODELVIEW', 'glPopMatrix');
				
			case GLWindow.ObjectTypes.Noise
				tic;
				glColor3dv(o.color);
				glPointSize(1);
				glEnableClientState(GL.VERTEX_ARRAY);
				glVertexPointer(2, GL.DOUBLE, 0, g_GLWNoiseData{o.noiseIndex});
				glDrawArrays(GL.POINTS, 0, o.numVertices);
				glDisableClientState(GL.VERTEX_ARRAY);
				toc;
			
			case GLWindow.ObjectTypes.PolygonSet
				mglTransform('GL_MODELVIEW', 'glPushMatrix');
				mglTransform('GL_MODELVIEW', 'glRotate', obj.Rotation(1), ...
					obj.Rotation(2), obj.Rotation(3), obj.Rotation(4));
				
				for ii = 1:length(obj.VertexList)
					v = obj.VertexList{ii};
					
					mglPolygon3D(v(:,1), v(:,2), v(:,3), obj.Color{wIndex}(ii,:));
				end
				
				mglTransform('GL_MODELVIEW', 'glPopMatrix');
				
			case GLWindow.ObjectTypes.Wedge
				mglGluPartialDisk(obj.Center(wIndex, 1), obj.Center(wIndex, 2), ...
					obj.InnerRadius, obj.OuterRadius, -obj.StartAngle+90, -obj.Sweep, ...
					obj.Color(wIndex,:), obj.NumSlices, obj.NumLoops);
				
			otherwise
				error('GLWindow/draw: Unknown object type "%d".', obj.objecttype);
		end
		
		mglTransform('GL_MODELVIEW', 'glPopMatrix');
	end
	
	% If we're using a framebuffer object for rendering, close it, and warp
	% it onto the display.
	if ~GLWObj.NoWarp && GLWObj.WindowInfo(wIndex).Warp
		mglUnbindFrameBufferObject(GLWObj.WindowInfo(wIndex).FBObject);
	
		% Run the post-processing shader if it's enabled.
		if ~isempty(GLWObj.PostProcessingShader)
			% Tell the shader which texture we're going to use.
			texLoc = glGetUniformLocation(GLWObj.Shaders.PostProcessing(wIndex), 'tex');
			glUniform1i(texLoc, 0);
			
			mglShader('useProgram', GLWObj.Shaders.PostProcessing(wIndex));
			glActiveTexture(GL.TEXTURE0);
		end
		
		mglRenderWarpedFrameBufferObject(GLWObj.WindowInfo(wIndex).FBObject.texture, ...
			GLWObj.WindowInfo(wIndex).WarpList, GLWObj.SceneDimensions(1:2));
		
		if ~isempty(GLWObj.PostProcessingShader)
			mglShader('useProgram', 0);
		end
	end
	
	% Draw the Bits++ code at the top of the screen if we're in Bits++
	% mode.
	if GLWObj.WindowInfo(wIndex).BitsPP
		tmpMGL = MGL;
		mglScreenCoordinates;
		
		mglTransform('GL_MODELVIEW', 'glPushMatrix');
		
		% Makes sure the scale is set to normal.
		mglTransform('GL_MODELVIEW', 'glScale', 1, 1, 1);
		
		mglBitsPlusSetClut(GLWObj.WindowInfo(wIndex).Gamma, [], false);
		
		mglTransform('GL_MODELVIEW', 'glPopMatrix');
		MGL = tmpMGL;
	end
end %

% Swap all window IDs at once to minimize delay between vertical syncing
% between the screens.
swapTimes = zeros(1, GLWObj.NumWindows);
for i = 1:GLWObj.NumWindows
	mglSwitchDisplay(GLWObj.WindowInfo(i).WindowID);
	mglFlush;
	swapTimes(i) = mglGetSecs;
end
