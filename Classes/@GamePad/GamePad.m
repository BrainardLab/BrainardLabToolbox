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
        directionEast  = 90;
        directionWest  = 270;
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
        
        lastKeyCharCode; % last char key code entered
    end
    
    % Private properties
    properties (Access = private)
        devHandle;      % handle to joystick device
        lastSecs;       % last results of mglGetSecs
       
    end  % private properties
    
    properties (Constant)
        availableCharCodes = {...
            'GP:Back' ...
            'GP:Start' ...
            'GP:X' ...
            'GP:Y' ...
            'GP:A' ...
            'GP:B' ...
            'GP:East' ...
            'GP:West' ...
            'GP:North' ...
            'GP:South' ...
            'GP:UpperLeftTrigger' ...
            'GP:UpperRightTrigger' ...
            'GP:LowerLeftTrigger' ...
            'GP:LowerRightTrigger' ...
            'GP:LeftJoystick' ...
            'GP:RightJoystick'
            };
    end
    
    
    properties (Constant, Access = private)
        backButtonStruct = struct(...
            'charCode', 'GP:Back', ...
            'keyCode', 1000 + 1);
        
        startButtonStruct = struct(...
            'charCode', 'GP:Start', ...
            'keyCode', 1000 + 2);

        XbuttonStruct = struct(...
            'charCode', 'GP:X', ...
            'keyCode', 1000 + 3);
        
        YbuttonStruct = struct(...
            'charCode', 'GP:Y', ...
            'keyCode', 1000 + 4);
        
        AbuttonStruct = struct(...
            'charCode', 'GP:A', ...
            'keyCode', 1000 + 5);
        
        BbuttonStruct = struct(...
            'charCode', 'GP:B', ...
            'keyCode', 1000 + 6);
        
        EastDirectionStruct = struct(...
            'charCode', 'GP:East', ...
            'keyCode', 2000 + 1);
        
        WestDirectionStruct = struct(...
            'charCode', 'GP:West', ...
            'keyCode', 2000 + 2);
        
        NorthDirectionStruct = struct(...
            'charCode', 'GP:North', ...
            'keyCode', 2000 + 3);
        
        SouthDirectionStruct = struct(...
            'charCode', 'GP:South', ...
            'keyCode', 2000 + 4);
        
        
        UpperLeftTriggerStruct = struct(...
            'charCode', 'GP:UpperLeftTrigger', ...
            'keyCode', 3000 + 1);
        
        UpperRightTriggerStruct = struct(...
            'charCode', 'GP:UpperRightTrigger', ...
            'keyCode', 3000 + 2);
        
        LowerLeftTriggerStruct = struct(...
            'charCode', 'GP:LowerLeftTrigger', ...
            'keyCode', 3000 + 3);
        
        LowerRightTriggerStruct = struct(...
            'charCode', 'GP:LowerRightTrigger', ...
            'keyCode', 3000 + 4);
        
        LeftJoystickStruct = struct(...
            'charCode', 'GP:LeftJoystick', ...
            'keyCode', 10000 + 1);
        
        RightJoystickStruct = struct(...
            'charCode', 'GP:RightJoystick', ...
            'keyCode', 10000 + 2);
        
    end
    
    % Public methods
    methods
        % Constructor
        function obj = GamePad()
            obj.devHandle = vrjoystick(1);
            obj.lastSecs = mglGetSecs;
            obj.lastKeyCharCode = '';
        end
        
        function time = getTime(obj)
            time = GetSecs;
        end
        
        function key = getKeyEvent(obj)
            % Do not report buttons pressed too often
            
            currentSecs = mglGetSecs;
            minInterKeyDelaySecs = 0.1;

            [action, time, timeString] = read(obj);
            if (action ~= obj.noChange)
                key = obj.setKeyEvent(action, time);
            else
                key = [];
                return;
            end
            
            if isempty(key)
                return;
            end
            
            obj.lastKeyCharCode = key.charCode;
            latency = currentSecs-obj.lastSecs;
            obj.lastSecs = currentSecs;
            
            if (strcmp(key.charCode, 'GP:LeftJoystick')) || (strcmp(key.charCode, 'GP:RightJoystick'))
                % no min delay requirement here
                return;
            end
            
            if (latency < minInterKeyDelaySecs) && strcmp(obj.lastKeyCharCode,key.charCode)
               key = [];
               return;
            end
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
    
    methods (Access = private)
                
        function key = setKeyEvent(obj, action, time)
            key = [];
            switch (action)
                case obj.noChange       % do nothing
                    
                case obj.buttonChange   % see which button was pressed 
                    % Control buttons
                    if (obj.buttonBack)
                        key = obj.backButtonStruct;
                        key.when = time;
                    elseif (obj.buttonStart)
                        key = obj.startButtonStruct;
                        key.when = time;
                        
                    % Colored buttons (on the right)
                    elseif (obj.buttonX)
                        key = obj.XbuttonStruct;
                        key.when = time;
                    elseif (obj.buttonY)
                        key = obj.YbuttonStruct;
                        key.when = time;
                    elseif (obj.buttonA)
                        key = obj.AbuttonStruct;
                        key.when = time;
                    elseif (obj.buttonB)
                        key = obj.BbuttonStruct;
                        key.when = time;   
                
                    % Trigger buttons
                    elseif (obj.buttonLeftUpperTrigger)
                        key = obj.UpperLeftTriggerStruct;
                        key.when = time;
                    elseif (obj.buttonRightUpperTrigger)
                        key = obj.UpperRightTriggerStruct;
                        key.when = time;  
                    elseif (obj.buttonLeftLowerTrigger)
                        key = obj.LowerLeftTriggerStruct;
                        key.when = time;
                    elseif (obj.buttonRightLowerTrigger)
                        key = obj.LowerRightTriggerStruct;
                        key.when = time;
                    end
                
            case obj.directionalButtonChange  % see which direction was selected
                switch (obj.directionChoice)
                    case obj.directionEast
                        key = obj.EastDirectionStruct;
                        key.when = time;  
                    case obj.directionWest
                        key = obj.WestDirectionStruct;
                        key.when = time;
                    case obj.directionNorth
                        key = obj.NorthDirectionStruct;
                        key.when = time;
                    case obj.directionSouth
                        key = obj.SouthDirectionStruct;
                        key.when = time;
                    case obj.directionNone
                        key = [];
                end  % switch (obj.directionChoice)
                
            case obj.joystickChange % see which analog joystick was changed
                if (obj.leftJoyStickDeltaX ~= 0)
                    key = obj.LeftJoystickStruct;
                    key.when = time;
                    key.deltaX = obj.leftJoyStickDeltaX;
                    key.deltaY = obj.leftJoyStickDeltaY;
                elseif (obj.leftJoyStickDeltaY ~= 0)
                    key = obj.LeftJoystickStruct;
                    key.when = time;
                    key.deltaX = obj.leftJoyStickDeltaX;
                    key.deltaY = obj.leftJoyStickDeltaY;
                elseif (obj.rightJoyStickDeltaX ~= 0)
                    key = obj.RightJoystickStruct;
                    key.when = time;
                    key.deltaX = obj.rightJoyStickDeltaX;
                    key.deltaY = obj.rightJoyStickDeltaY;
                elseif (obj.rightJoyStickDeltaY ~= 0)
                    key = obj.RightJoystickStruct;
                    key.when = time;
                    key.deltaX = obj.rightJoyStickDeltaX;
                    key.deltaY = obj.rightJoyStickDeltaY;
                end    
            end % switch action
        end
        
    end
end