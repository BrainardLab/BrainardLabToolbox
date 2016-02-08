% Script to demo the use of the @GamePad class, which allows very fast 
% access to the Logiteck gamepad.
%
% Caution: When using a USB hub to connect the Logitech gamepad (and/or) other components
% unpredicted behavior may occur. This would need to be troubleshooted by
% unplugging, one a time, the various components from the hub, or by connecting
% all components directly to the computer.
%
% 6/18/2014 npc Wrote it.
%

function GamePadDemo

    % Instantiate a gamePad object
    gamePad = GamePad();
    
    keepGoing = true;
    while (keepGoing)
        % Read the gamePage
        [action, time] = gamePad.read();
        
        switch (action)
            case gamePad.noChange       % do nothing
                
            case gamePad.buttonChange   % see which button was pressed
                % Control buttons
                if (gamePad.buttonBack)
                    fprintf('[%s]: Back button\n', time);

                elseif (gamePad.buttonStart)
                    fprintf('[%s]: Start button\n', time);
                    
                % Colored buttons (on the right)
                elseif (gamePad.buttonX)
                    fprintf('[%s]: ''X'' button\n', time);
                elseif (gamePad.buttonY)
                    fprintf('[%s]: ''Y'' button\n', time);
                elseif (gamePad.buttonA)
                    fprintf('[%s]: ''A'' button\n', time);
                elseif (gamePad.buttonB)
                    fprintf('[%s]: ''B'' button\n', time);    
                
                % Trigger buttons
                elseif (gamePad.buttonLeftUpperTrigger)
                    fprintf('[%s]: Left Upper Trigger button\n', time);
                elseif (gamePad.buttonRightUpperTrigger)
                    fprintf('[%s]: Right Upper Trigger button\n', time);
                elseif (gamePad.buttonLeftLowerTrigger)
                    fprintf('[%s]: Left Lower Trigger button\n', time);
                elseif (gamePad.buttonRightLowerTrigger)
                    fprintf('[%s]: Right Lower Trigger button\n', time);
                end
                
            case gamePad.directionalButtonChange  % see which direction was selected
                switch (gamePad.directionChoice)
                    case gamePad.directionEast
                        fprintf('[%s]: East\n', time);
                    case gamePad.directionWest
                        fprintf('[%s]: West\n', time);
                    case gamePad.directionNorth
                        fprintf('[%s]: North\n', time);
                    case gamePad.directionSouth
                        fprintf('[%s]: South\n', time);
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
                
        end
    end  % while keepGoing
    
    % Close the gamePage object
    gamePad.shutDown();
    
end

