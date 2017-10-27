function GamePadDemo2

    % Instantiate a gamePad object
    gamePad = GamePad();
    
    keepGoing = true;
    fprintf('\n\nStart pressing different game pad buttons. Enter ''q'' to quit.\n\n');
    
    time0 = gamePad.getTime();
    
    while (keepGoing)
        % Read the gamePad
        gamePadKey = gamePad.getKeyEvent();
        if (~isempty(gamePadKey))
            gamePadKey
            fprintf('User pressed a button at %g\n', gamePadKey.when-time0)
        end
        
        % Read the keyboard
        keyboardKey = mglGetKeyEvent();
        
        if (~isempty(keyboardKey))&&(keyboardKey.charCode == 'q')
            keepGoing = false;
            fprintf('User entered ''q''. Exiting loop.\n');
        end
        
    end % while keepGoing
    
    % Close the gamePad object
    gamePad.shutDown();
end

