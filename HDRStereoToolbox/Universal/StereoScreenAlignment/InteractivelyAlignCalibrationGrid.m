function [Xdistorted, Ydistorted] = InteractivelyAlignCalibrationGrid(gamePad, windowPtr, Xoriginal, Yoriginal, gridColor, gridDistortionTracesColor, gridNodesColor, activeNodeColor)

    % Get escape key-code
    KbName('UnifyKeyNames');
    esc   = KbName('ESCAPE');
    space = KbName('space');
    
    % How much to wait betwen switching to new nodes
    nodeSelectionUpdateDelay   = 0.1;
    nodeMovementUpdateDelay    = 0.1;
    stepAdjustementUpdateDelay = 0.3;
    deltaNodeIncrementInPixels = 5;
    
    % distortions are zero initial
    nodeAdjustmentMatrix = zeros(size(Xoriginal));
    
    % generated the distorted meshgrid. start with identical to the original
    Xdistorted = Xoriginal; 
    Ydistorted = Yoriginal;
    
    % Initialize activeNode
    nodeRowsNum = size(Xoriginal,1);
    nodeColsNum = size(Xoriginal,2);
    activeNodeRow = round(nodeRowsNum/2);
    activeNodeCol = round(nodeColsNum/2);
 
    % Generate feedback text 
    infoText = sprintf('\n JOYSTICK: RIGHT GROUP OF 4 BUTTONS');
    infoText = [infoText sprintf('\n 1. ''X''     : Switch active node (left) ')];
    infoText = [infoText sprintf('\n 2. ''B''     : Switch active node (right) ')];
    infoText = [infoText sprintf('\n 3. ''Y''     : Switch active node (top)  ')];
    infoText = [infoText sprintf('\n 4. ''A''     : Switch active node (bottom)')];
    infoText = [infoText sprintf('\n\n JOYSTICK: LEFT GROUP OF 4 BUTTONS')];
    infoText = [infoText sprintf('\n 5. ''East''  : Move active node leftwards ')];
    infoText = [infoText sprintf('\n 6. ''West''  : Move active node rightwards')];
    infoText = [infoText sprintf('\n 7. ''North'' : Move active node upwards')];
    infoText = [infoText sprintf('\n 8. ''South'' : Move active node downwards')];
    infoText = [infoText sprintf('\n\n JOYSTICK: UPPER TRIGGER BUTTONS')];
    infoText = [infoText sprintf('\n 9. ''Left''  : Decrease adjustment step')];
    infoText = [infoText sprintf('\n 10.''Right'' : Increase adjustment step')];
    infoText = [infoText sprintf('\n\n JOYSTICK: LOWER TRIGGER BUTTONS')];
    infoText = [infoText sprintf('\n 11. ''L/R''  : Estimate projective xform')];
    infoText = [infoText sprintf('\n\n KEYBOARD:')];
    infoText = [infoText sprintf('\n 12.''ESC''   : Exits alignment loop')];
    infoText = [infoText sprintf('\n 13.''Space'' : Toggle menu display on SONY \n')];
    
    adjustedNodeIndices = find(nodeAdjustmentMatrix(:) > 0);
    adjustedNodesNum = length(adjustedNodeIndices);
    displayString = [infoText sprintf('\n-----------------------------------------')];
    displayString = [displayString sprintf('\n Adjustement step: %d', deltaNodeIncrementInPixels)];
    displayString = [displayString sprintf('\n Adjusted nodes #: %d', adjustedNodesNum)];
    
    % Display info text on control screen. This is also displayed on the currently-calibrated display
    fprintf('\n --------------------------------------------------');
    fprintf('\n%s',infoText);
    fprintf('\n --------------------------------------------------\n');
    
    % Render the calibration grid deformed according to the distorted grid
    RenderCalibrationGrid(windowPtr, Xdistorted, Ydistorted, Xoriginal, Yoriginal, ...
        activeNodeRow, activeNodeCol, displayString, gridColor, gridDistortionTracesColor, ...
        gridNodesColor, activeNodeColor);
    
    % Prevent keypresses from spilling into Matlab window:
    ListenChar(2);

    try
        % Go in alignment loop
        keepGoing = true;
        while (keepGoing)

            % Flag indicating whether we need to re-render the grid
            gridNeedsUpdating = false;
            pauseDelay = 0;
            
            % Check keyboard for escape
            [isdown secs keycode] = KbCheck;

            if keycode(esc)
                keepGoing = false;
                continue;
            elseif keycode(space)
                if (isempty(displayString))
                   displayString = infoText;
                else
                   displayString = ''; 
                end
                gridNeedsUpdating = true;
                pauseDelay = 0.2;
            end

            % Read the gamePage
            [action, time] = gamePad.read();

            % And react accordingly
            switch (action)
                case gamePad.noChange       % do nothing

                case gamePad.buttonChange   % see which button was pressed
                    % Control buttons
                    if (gamePad.buttonBack)
                        fprintf('[%s]: Back button\n', time);

                    elseif (gamePad.buttonStart)
                        if (isempty(displayString))
                           displayString = infoText;
                        else
                           displayString = ''; 
                        end
                        gridNeedsUpdating = true;
                        pauseDelay = 0.2;

                    % Colored buttons (on the right)
                    elseif (gamePad.buttonX)
                        activeNodeCol = activeNodeCol - 1;
                        if (activeNodeCol < 1)
                            activeNodeCol = nodeColsNum;
                        end
                        % Pause a little longer so we do not go crazy switching
                        % from node to node
                        pauseDelay = nodeSelectionUpdateDelay;
                        gridNeedsUpdating = true;

                    elseif (gamePad.buttonB)  
                        activeNodeCol = activeNodeCol + 1;
                        if (activeNodeCol > nodeColsNum)
                            activeNodeCol = 1;
                        end
                        % Pause a little longer so we do not go crazy switching
                        % from node to node
                        pauseDelay = nodeSelectionUpdateDelay;
                        gridNeedsUpdating = true;

                   elseif (gamePad.buttonY)
                        activeNodeRow = activeNodeRow - 1;
                        if (activeNodeRow < 1)
                            activeNodeRow = nodeRowsNum;
                        end
                        % Pause a little longer so we do not go crazy switching
                        % from node to node
                        pauseDelay = nodeSelectionUpdateDelay;
                        gridNeedsUpdating = true;

                    elseif (gamePad.buttonA)
                        activeNodeRow = activeNodeRow + 1;
                        if (activeNodeRow > nodeRowsNum)
                            activeNodeRow = 1;
                        end
                        % Pause a little longer so we do not go crazy switching
                        % from node to node
                        pauseDelay = nodeSelectionUpdateDelay;
                        gridNeedsUpdating = true;

                    % Trigger buttons
                    elseif (gamePad.buttonLeftUpperTrigger)
                        deltaNodeIncrementInPixels = deltaNodeIncrementInPixels - 1;
                        if (deltaNodeIncrementInPixels < 1)
                            deltaNodeIncrementInPixels = 1;
                        end
                        gridNeedsUpdating = true;
                        pauseDelay = stepAdjustementUpdateDelay;
                        
                    elseif (gamePad.buttonRightUpperTrigger)
                        deltaNodeIncrementInPixels = deltaNodeIncrementInPixels + 1;
                        if (deltaNodeIncrementInPixels > 10)
                            deltaNodeIncrementInPixels = 10;
                        end
                        gridNeedsUpdating = true;
                        pauseDelay = stepAdjustementUpdateDelay;
                        
                    elseif ((gamePad.buttonLeftLowerTrigger) || (gamePad.buttonRightLowerTrigger))
                        adjustedNodeIndices = find(nodeAdjustmentMatrix(:) > 0);
                        sampledXdistorted = Xdistorted(adjustedNodeIndices); 
                        sampledYdistorted = Ydistorted(adjustedNodeIndices); 
                        sampledXoriginal  = Xoriginal(adjustedNodeIndices); 
                        sampledYoriginal  = Yoriginal(adjustedNodeIndices); 
                        [Xdistorted, Ydistorted] = EstimateProjectiveTransform(Xoriginal, Yoriginal, sampledXoriginal, sampledYoriginal, sampledXdistorted, sampledYdistorted);
                        gridNeedsUpdating = true;
                        pauseDelay = 0.0;
                    end

                case gamePad.directionalButtonChange  % see which direction was selected
                    switch (gamePad.directionChoice)
                        case gamePad.directionEast
                            nodeAdjustmentMatrix(activeNodeRow, activeNodeCol) = true;
                            Xdistorted(activeNodeRow, activeNodeCol) = Xdistorted(activeNodeRow, activeNodeCol) - deltaNodeIncrementInPixels;
                            pauseDelay = nodeMovementUpdateDelay;
                            gridNeedsUpdating = true;
                        case gamePad.directionWest
                            nodeAdjustmentMatrix(activeNodeRow, activeNodeCol) = true;
                            Xdistorted(activeNodeRow, activeNodeCol) = Xdistorted(activeNodeRow, activeNodeCol) + deltaNodeIncrementInPixels;
                            pauseDelay = nodeMovementUpdateDelay;
                            gridNeedsUpdating = true;
                        case gamePad.directionNorth
                            nodeAdjustmentMatrix(activeNodeRow, activeNodeCol) = true;
                            Ydistorted(activeNodeRow, activeNodeCol) = Ydistorted(activeNodeRow, activeNodeCol) - deltaNodeIncrementInPixels;
                            pauseDelay = nodeMovementUpdateDelay;
                            gridNeedsUpdating = true;
                        case gamePad.directionSouth
                            nodeAdjustmentMatrix(activeNodeRow, activeNodeCol) = true;
                            Ydistorted(activeNodeRow, activeNodeCol) = Ydistorted(activeNodeRow, activeNodeCol) + deltaNodeIncrementInPixels;
                            pauseDelay = nodeMovementUpdateDelay;
                            gridNeedsUpdating = true;
                        case gamePad.directionNone
                            fprintf('[%s]: No direction\n', time);
                    end  % switch (gamePad.directionChoice)

                case gamePad.joystickChange % see which analog joystick was changed
                    if (gamePad.leftJoyStickDeltaX ~= 0)
                        fprintf('[%s]: Left Joystick delta-X: %d\n', time, gamePad.leftJoyStickDeltaX); 
                    elseif (gamePad.leftJoyStickDeltaY ~= 0)
                        fprintf('[%s]: Left Joystick delta-Y: %d\n', time, gamePad.leftJoyStickDeltaY); 
                    elseif (gamePad.rightJoyStickDeltaX ~= 0)
                        fprintf('[%s]: Right Joystick delta-X: %d\n', time, gamePad.rightJoyStickDeltaX);
                    elseif (gamePad.rightJoyStickDeltaY ~= 0)
                        fprintf('[%s]: Right Joystick delta-Y: %d\n', time, gamePad.rightJoyStickDeltaY);
                    end
            end  % switch(action)

            if (gridNeedsUpdating)
                adjustedNodeIndices = find(nodeAdjustmentMatrix(:) > 0);
                adjustedNodesNum = length(adjustedNodeIndices);
                displayString = [infoText sprintf('\n-----------------------------------------')];
                displayString = [displayString sprintf('\n Adjustement step: %d', deltaNodeIncrementInPixels)];
                displayString = [displayString sprintf('\n Adjusted nodes #: %d', adjustedNodesNum)];
                % Render the calibration grid deformed according to the distorted grid
                RenderCalibrationGrid(windowPtr, Xdistorted, Ydistorted, Xoriginal, Yoriginal, ...
                    activeNodeRow, activeNodeCol, displayString, gridColor, gridDistortionTracesColor, ...
                    gridNodesColor, activeNodeColor);
                pause(pauseDelay);
            end          
        end % while keepGoing

        % Reenable Matlab's keyboard handling:
        ListenChar(0);
        
    catch err
        
        % Reenable Matlab's keyboard handling:
        ListenChar(0);
        
        % Close all displays
        sca;
        
        rethrow(err);
    end    
end