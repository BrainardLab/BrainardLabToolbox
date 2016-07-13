function WaitForKeyPress
% WaitForKeyPress
% 
% Waits for key press on the game pad

% Initialize the gamepad
gamePad = GamePad();

resume = false;
while (resume == false)
    action = gamePad.read();
    % If a key was pressed, get the key and exit.
    switch (action)
        case gamePad.buttonChange
            resume = true;
    end
end