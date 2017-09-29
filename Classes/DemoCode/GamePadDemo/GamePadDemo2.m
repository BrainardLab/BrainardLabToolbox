function GamePadDemo2

    % Instantiate a gamePad object
    gamePad = GamePad();
    
    keepGoing = true;
    pass = 0;
    maxPasses = 100000;

    % Only respond when one of these buttons is pressed
    monitoredButtons = {'south', 'north', 'rightLowerTrigger', 'leftLowerTrigger'};
    
    while (keepGoing) && (pass < maxPasses)
        pass = pass + 1;
        % Read the gamePad
        [action, time, timeString, state] = gamePad.read();
        
        if (action ~= gamePad.noChange)
            activeButtons = keys(state);
            for k = 1:numel(activeButtons)
                if (ismember(activeButtons{k}, monitoredButtons))
                    fprintf('[%s (%f)] %s: %d\n', timeString, pass/maxPasses, activeButtons{k}, state(activeButtons{k}));
                end
            end
        end
    end % while keepGoing
    
    % Close the gamePage object
    gamePad.shutDown();
end

