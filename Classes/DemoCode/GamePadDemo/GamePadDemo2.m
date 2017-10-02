function GamePadDemo2

    % Instantiate a gamePad object
    gamePad = GamePad();
    
    keepGoing = true;
    fprintf('\n\nStart pressing different game pad buttons. Enter ''q'' to quit.\n\n');
    
    while (keepGoing)
        % Read the gamePad
        gamePadKey = gamePad.getKeyEvent();
        if (~isempty(gamePadKey))
            gamePadKey
        end
        
        % Read the keyboard
        keyboardKey = mglGetKeyEvent();
        
        if (~isempty(keyboardKey))&&(keyboardKey.charCode == 'q')
            keepGoing = false;
            fprintf('User entered ''q''. Exiting loop.\n');
        end
        
    end % while keepGoing
    
    % Close the gamePage object
    gamePad.shutDown();
end

