classdef GamePad < handle
% Class to interface with the LogiTech GamePad
%
% Caution: When using a USB hub to connect the Logitech gamepad (and/or) other components
% unpredicted behavior may occur. This would need to be troubleshooted by
% unplugging, one a time, the various components from the hub, or by connecting
% all components directly to the computer.
%
% 6/18/2014   npc   Wrote it
%

    % Read-only properties
    properties (SetAccess = private)
        
        % What type of state change occurred
        noChange                = 0;
        buttonChange            = 1;
        directionalButtonChange = 2;
        joystickChange          = 3;
        
        % State of left knob (5 states: none, east, west, north, south) 
        directionChoice;
        directionNone  = -1;
        directionEast  = 270;
        directionWest  = 90;
        directionNorth = 0;
        directionSouth = 180;
        
        % State of left joystick (integer values in -64 .. +64)
        leftJoyStickDeltaX = 0;      
        leftJoyStickDeltaY = 0;      
        
        % State of right joystick (integer values in -64 .. +64)
        rightJoyStickDeltaX = 0;      
        rightJoyStickDeltaY = 0;      
        
        % State of right (colored) buttons (1 if pressed, zero otherwise)
        buttonX = 0;
        buttonA = 0;
        buttonB = 0;
        buttonY = 0;
            
        % State of trigger buttons (1 if pressed, zero otherwise)
        buttonLeftUpperTrigger  = 0;
        buttonRightUpperTrigger = 0;
        buttonLeftLowerTrigger  = 0;
        buttonRightLowerTrigger = 0;

        % State of buttons labeled 'Start' and 'Back' (top)
        buttonBack  = 0;
        buttonStart = 0;
    end
    
    % Private properties
    properties (Access = private)
        devHandle;      % handle to joystick device
    end  % private properties
    
    % Public methods
    methods
        % Constructor
        function obj = GamePad()
            obj.devHandle = vrjoystick(1);
        end
        
        function [action, time, timeString] = read(obj)
            % Read from the device
            [axes, buttons, povs] = read(obj.devHandle);
            
            % Get Secs
            time = GetSecs;

            % Get time as string
            a = clock();
            timeString = sprintf('%d:%d:%2.4f', a(4), a(5), a(6));
            
            % force axes in [-64, -63, ..., -1, 0, 1, ..., 63, 64]
            % save the sign
            signs = sign(axes);
            axes  = abs(axes);
            % raise to the power of 2 to get better resolution at lower end
            % and normalize to -64 .. 64
            axes = floor(64*(axes .^ 2));
            % add back the sign
            axes = axes .* signs;
            
            % set the anyChange to indicate what type of action occurred
            action = obj.noChange;
            if (any(buttons))
                 action = obj.buttonChange;
            end
            
            if (povs > -1)
                 action = obj.directionalButtonChange;
            end
            
            if (any(axes)) 
                 action = obj.joystickChange;
            end
            
            % State of right (colored) buttons
            obj.buttonX = buttons(1);
            obj.buttonA = buttons(2);
            obj.buttonB = buttons(3);
            obj.buttonY = buttons(4);
            
            % State of trigger buttons
            obj.buttonLeftUpperTrigger  = buttons(5);
            obj.buttonRightUpperTrigger = buttons(6);
            obj.buttonLeftLowerTrigger  = buttons(7);
            obj.buttonRightLowerTrigger = buttons(8);
            
            % State of buttons labeled 'Start' and 'Back'
            obj.buttonBack              = buttons(9);
            obj.buttonStart             = buttons(10);
            
            % State of left knob
            obj.directionChoice     = povs;
            
            % State of left joystick
            obj.leftJoyStickDeltaX  = axes(1);
            obj.leftJoyStickDeltaY  = axes(2);
            
            % State of right joystick
            obj.rightJoyStickDeltaX = axes(3);
            obj.rightJoyStickDeltaY = axes(4);
            
        end
        
        function shutDown(obj)
           close(obj.devHandle);
        end
    end
    
end