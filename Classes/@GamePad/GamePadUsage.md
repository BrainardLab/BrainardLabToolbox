You can interface with the gamepad from MATLAB using the `@gamePad` class.  The codes for the different buttons of the gamepad are shown in the schematic below.

![GamePad](/Users/nicolas/Documents/MATLAB/toolboxes/BrainardLabToolbox/Classes/@GamePad/GamePad.png)

Example code is shown below. Also see `MovingDotsDemo.m` and  `GamePadDemo2.m`

```MATLAB
% Instantiate a gamePad object
gamePad = GamePad();
% Get reference time
time0 = gamePad.getTime();
% Loop
keepGoing = true;
while (keepGoing)
	% query the gamepad to see if the user pressed on a button
	key = gamePad.getKeyEvent();
	if (~isempty(key))
		% We got an non-empty key, so act on it
		switch (key.charCode)
    	case 'GP:Y'
        	fprintf('Y pressed %g seconds since To.\n', key.when-time0);
    	case 'GP:A'
        	fprintf('A pressed %g seconds since To.\n', key.when-time0);
    	case 'GP:X' 
        	fprintf('X pressed %g seconds since To.\n', key.when-time0);
    	case 'GP:B'
        	fprintf('B pressed %g seconds since To.\n', key.when-time0);
        case 'GP:Back' 
        	keepGoing = false;
        case 'GP:Start'
        	% ignore
        case 'GP:East'  
        	% ignore
        case 'GP:West'    
        	% ignore
        case 'GP:North'    
        	% ignore
        case 'GP:South'
        	% ignore
        case 'GP:UpperLeftTrigger'
        	% ignore
        case 'GP:UpperRightTrigger'
        	% ignore
        case 'GP:LowerLeftTrigger'
        	% ignore
        case 'GP:LowerRightTrigger'
        	% ignore
        case 'GP:LeftJoystick'
        	fprintf('L-Joystick:[%g,%g]\n',key.deltaX,key.deltaY);
        case 'GP:RightJoystick'
        	fprintf('R-Joystick:[%g,%g]\n',key.deltaX,key.deltaY);
		end % switch
	end % if (~isempty(gamePadKey))
end % while keepGPing
% Close the gamePad object
gamePad.shutDown();
```

