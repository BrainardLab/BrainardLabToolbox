function responseStruct = WaitForTargetSelectionOLD(obj)
%   responseStruct = WaitForTargetSelection(obj)
%
%   Description:
%   Method that presents a stereo-pair stimulus with a number of selectable targets and returns 
%   detailed information related to the subject's selection. This is a testbed method for test different options. 
%   Options that we like, get adopted and implemented in the runExperimentalLoopWithCubeScene method.
%
%   Parameters:
%   obj: The parent StereoViewController object
%
%   Output:
%   responseStruct -- a struct containing detauled information related to
%   the subject's selection.
%
%   History:
%   @code
%   3/11/2013    npc    Wrote it 
%   4/24/2013    npc    Modified it to return the full responseStruct. 
%   @endcode

    % initialize response structure. 
    responseStruct = struct('mousePositionAndTime', [], ...
                            'minDist', NaN, ...
                            'reactionTime', NaN, ...
                            'distanceToSelectedTarget', NaN, ...
                            'selectedTargetIndex', NaN);
                        
    responseStruct.mousePositionAndTime = NaN(18000,3); 

    % Present stimulus and obtain the timestamp of its onset
    stimulusOnset = obj.showStimulus();
    %obj.showTargetBoxes();
    
    % Obtain the target locations in the right screen
    xpos = obj.stereoPair.targets.rightScreen.XcoordsCm;
    ypos = obj.stereoPair.targets.rightScreen.YcoordsCm;

    if (strcmpi(obj.stereoCursor.type, 'MonocularRightEye'))
        % compute a random position, excluding the center portion of the cube stimulus
        [xMousePixels, yMousePixels] = GenerateRandomInitialMousePositionOutsideOfCubeArea(obj, 'right');
        % Set the mouse to the computed random position
        mglSetMousePosition(xMousePixels, yMousePixels, obj.stereoDisplayConfiguration.screenID.right);
    else
        % compute a random position, excluding the center portion of the cube stimulus
        [xMousePixels, yMousePixels] = GenerateRandomInitialMousePositionOutsideOfCubeArea(obj, 'left');
        % Set the mouse to the computed random position
        mglSetMousePosition(xMousePixels, yMousePixels, obj.stereoDisplayConfiguration.screenID.left);
    end
    
    
    % Switch to default cursor color
    obj.stereoGLWindow.setObjectProperty('StereoCursor', 'Color', obj.stereoCursor.color);
                    
    % render scene
    obj.stereoGLWindow.draw;
                
    keepMoving = true;
    screenRefreshCounter = 0; 
    
    while (keepMoving)
        
        giveFeedback = false;
        
        % Check for quit button press
        key = mglGetKeyEvent;
        if (~isempty(key))   
            switch key.charCode

                 case 'n'
                      obj.stereoCursor.center(:,3) =  obj.stereoCursor.center(:,3) + 1;

                 case 'f'
                     obj.stereoCursor.center(:,3) =  obj.stereoCursor.center(:,3) - 1;

                case 't'
                     if (strcmpi(obj.stereoCursor.type,'CrossHairs3D'))
                         obj.stereoCursor.type = 'Simple3D';
                     elseif (strcmpi(obj.stereoCursor.type,'Simple3D'))
                         obj.stereoCursor.type = 'MonocularRightEye';
                     elseif (strcmpi(obj.stereoCursor.type,'MonocularRightEye'))
                         obj.stereoCursor.type = 'MonocularLeftEye';
                     elseif (strcmpi(obj.stereoCursor.type,'MonocularLeftEye'))
                         obj.stereoCursor.type = 'CrossHairs3D';
                     end
                     obj.setStereoCursor(obj.stereoCursor);
                     obj.showStereoCursor();
                case 'q'
                    keepMoving = false;
                    giveFeedback = true;
                    feedbackString = 'Run quitted!';
            end % switch
        end  % ~isempty(key)
        
        if (keepMoving)
            
            % Get mouse state
            [mouseXposPixels, mouseYposPixels, mouseButtonState] = obj.mouseDev.getMouseStatePx;
            
            % Get position in cm
            m = obj.mouseDev.px2cm(obj.stereoDisplayConfiguration.screenID.left, obj.stereoDisplayConfiguration.sceneDimensionsInCm);
            

            if ((~isempty(m)) || (mouseButtonState > 0)) 

                % Check for mouse movement 
                if (~isempty(m))
                    % update stereo cursor position according to new mouse position
                    if (strcmpi(obj.stereoCursor.type, 'MonocularRightEye'))
                        obj.stereoGLWindow.Cursor3Dposition = [m.x m.y -1000; m.x m.y obj.stereoCursor.center(2,3)];
                    elseif (strcmpi(obj.stereoCursor.type, 'MonocularLeftEye'))
                        obj.stereoGLWindow.Cursor3Dposition = [m.x m.y obj.stereoCursor.center(1,3); m.x m.y -1000];
                    else
                       obj.stereoGLWindow.Cursor3Dposition = [m.x m.y obj.stereoCursor.center(1,3); m.x m.y obj.stereoCursor.center(2,3)]; 
                    end
                    
                    cursor3DpositionInVirtualAndScreenCoords = obj.stereoGLWindow.Cursor3Dposition;
                end
                
                % Check for a mouse click
                if ((mouseButtonState > 0) && (~isempty(m)))
                    
                    % Obtain mouse position at z = 0
                    % positionOnLeftScreen  = obj.stereoGLWindow.Cursor3Dposition.displayXYZposition(1,1:2);
                    positionOnRightScreen = cursor3DpositionInVirtualAndScreenCoords.screenCoords(2,:);
                    
                    % Compute distances to all targets in the right screen.
                    dx = xpos - positionOnRightScreen(1);
                    dy = ypos - positionOnRightScreen(2);
                    dist = sqrt(dx.^2 + dy.^2);

                    % compute min distance over all targets and target with the minimum distance to mouse click
                    [minDist, selectedTargetIndex] = min(dist);
                    
                    fprintf('\n--------------------\n');
                    fprintf('Mouse coords in cm: %2.2f %2.2f\n', m.x, m.y);
                    fprintf('Cursor virtual coords on right screen: %2.2f, %2.2f (z:%2.2f)\n',  cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(2,1), cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(2,2), cursor3DpositionInVirtualAndScreenCoords.virtualXYZposition(2,3));
                    fprintf('Cursor screenCoords on right screen: %2.2f %2.2f\n', positionOnRightScreen(1), positionOnRightScreen(2));
                    fprintf('Target(1) ScreenCoords on right screen:%2.2f %2.2f\n', obj.stereoPair.targets.rightScreen.XcoordsCm(1), obj.stereoPair.targets.rightScreen.YcoordsCm(1));
                    fprintf('minDist: %f (max acceptable: %2.2f), selected target: %d\n', minDist, obj.stereoPair.targets.rightScreen.maximumAcceptableDistanceCm, selectedTargetIndex);
                    fprintf('--------------------\n');
          
                    
                    % Check if the the click is within the accepted tolerance
                    if (minDist <= obj.stereoPair.targets.rightScreen.maximumAcceptableDistanceCm) 
                        % Compute reaction time
                        responseStruct.reactionTime = mglGetSecs - stimulusOnset; 
                        
                        % All done with the mouse
                        keepMoving = false;
                        
                        % Update responseStruct
                        responseStruct.distanceToSelectedTarget = minDist;
                        responseStruct.selectedTargetIndex      = selectedTargetIndex; 
                    else
                        giveFeedback = true;
                        feedbackString = 'Try again';
                    end
                    
                end % (mouseButtonState ~= 0)  
            end  % mouse motion, or click
            
            
            if (~isempty(m))
                
                % render scene again
                obj.stereoGLWindow.draw;
                
                % Increment the screenRefreshCounter
                screenRefreshCounter = screenRefreshCounter + 1; 
            
                % Update mousePositionAndTime
                responseStruct.mousePositionAndTime(screenRefreshCounter, :) = [m.x, m.y, mglGetSecs];
            end
            
            
            if (giveFeedback)
                Speak(feedbackString, 'alex'); 
                giveFeedback = false;
            end     
           
        end  % if keepMoving
        
        if (giveFeedback)
            Speak(feedbackString, 'alex'); 
            giveFeedback = false;
        end   
        
    end % while keepMoving  
end
