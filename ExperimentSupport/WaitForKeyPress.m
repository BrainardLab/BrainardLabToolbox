function WaitForKeyPress
% WaitForKeyPress
% 
% Waits for key press on the game pad.  If no game pad is attached
% to the computer, then it waits for a key presss on the keyboard.
%
% This routine is unfortunately named, since the name doesn't provide
% even a hint that it is aimed at a game pad.

% 6/18/17  dhb  Provided conditional for keypress.

% Initialize the gamepad, if there is one.
useGamePad = true;
try
    gamePad = GamePad();
catch
    gamePad = [];
    useGamePad = false;
end

% Wait for a key press, one way or another
%
% Game pad branch
if (useGamePad)
    resume = false;
    while (resume == false)
        action = gamePad.read();
        switch (action)
            case gamePad.buttonChange
                resume = true;
        end
    end
% Keyboard branch
else
    % Waits for keyboard input 
    GetKbChar;
end