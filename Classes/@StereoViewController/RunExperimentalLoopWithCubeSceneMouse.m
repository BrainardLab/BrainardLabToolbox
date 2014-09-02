function [responseStruct]= RunExperimentalLoopWithCubeSceneMouse(obj, initialMousePosition)
%   Method that presents a stereo-pair stimulus with a number of selectable targets and returns 
%   a response struct that contains detailed information related to the subject's selection.
%
%   Parameters:
%   obj: The parent StereoViewController object
%
%   History:
%   @code
%   4/09/2013    ar    Modified it based on WaitForTargetSelection method. 
%   4/20/2013    npc   Cleaned up, reorganized, added Doxygen-comments.
%   @endcode
%

    % initialize response structure. 
    responseStruct = struct('mousePositionAndTime', [], ...
                            'minDist', NaN, ...Sho
                            'reactionTime', NaN, ...
                            'distanceToSelectedTarget', NaN, ...
                            'selectedTargetIndex', NaN,...
                            'quitTrial', false);
                        
    responseStruct.mousePositionAndTime = NaN(18000,3); 

    % Obtain the target locations in the right screen
    xpos = obj.stereoPair.targets.rightScreen.XcoordsCm;
    ypos = obj.stereoPair.targets.rightScreen.YcoordsCm;
 
    mglSetMousePosition(initialMousePosition(1), initialMousePosition(2), obj.stereoDisplayConfiguration.screenID.right);          
    
    % Switch to default cursor color
    obj.stereoGLWindow.setObjectProperty('StereoCursor', 'Color', obj.stereoCursor.color);

    % Present stimulus and obtain the timestamp of its onset
    stimulusOnset = obj.showStimulus();

    %obj.showTargetBoxes();
      
    keepMoving = true;
    
    screenRefreshCounter = 0; 
    % Listen for key presses
        ListenChar(2);
        FlushEvents;
        
    while (keepMoving)
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
                    responseStruct.quitTrial = true;
            end % switch
        end  % ~isempty(key)
        
        if (keepMoving)
            
            % Get mouse state
            [mouseXposPixels, mouseYposPixels, mouseButtonState] = obj.mouseDev.getMouseStatePx;
           
            % Get position in cm
            m = obj.mouseDev.px2cm(obj.stereoDisplayConfiguration.screenID.right, obj.stereoDisplayConfiguration.sceneDimensionsInCm);
            
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
                    obj.showStereoCursor();
                end
                
                % Check for a mouse click
                if ((mouseButtonState ~= 0) && (~isempty(m)))
                    
                    % Obtain mouse position at z = 0
                    % positionOnLeftScreen  = obj.stereoGLWindow.Cursor3Dposition.displayXYZposition(1,1:2);
                    positionOnRightScreen = cursor3DpositionInVirtualAndScreenCoords.screenCoords(2,:);
                    
                    % Compute distances to all targets in the right screen.
                    dx = xpos - positionOnRightScreen(1);
                    dy = ypos - positionOnRightScreen(2);
                    dist = sqrt(dx.^2 + dy.^2);

                    % compute min distance over all targets and target with the minimum distance to mouse click
                    [minDist, selectedTargetIndex] = min(dist);
                    
                    % Check if the the click is within the accepted tolerance
                    if (minDist <= obj.stereoPair.targets.rightScreen.maximumAcceptableDistanceCm) 
                        % Compute reaction time
                        responseStruct.reactionTime = mglGetSecs - stimulusOnset; 
                        
                        % All done with the mouse
                        keepMoving = false;
                        
                        % Update responseStruct
                        responseStruct.distanceToSelectedTarget = minDist;
                        responseStruct.selectedTargetIndex      = selectedTargetIndex; 
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
            
            
        end  % if keepMoving
    end % while keepMoving  
    
    obj.hideStereoCursor();
    obj.hideStimulus();
end

     