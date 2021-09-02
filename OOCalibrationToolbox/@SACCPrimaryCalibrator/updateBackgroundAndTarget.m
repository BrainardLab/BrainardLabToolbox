function updateBackgroundAndTarget(obj, bgSettings, targetSettings, useBitsPP)
    % If the user sets useBitsPP to true, something has gone wrong.
    if (useBitsPP)
        error('The PsychImaging calibrator does not support bits++ yet');
    end
    
    % Set and check that the number of subprimaries is right
    nSubprimaries = 16;
    if (length(targetSetttings) ~= nSubprimaries)
        error(sprintf('Wrong number %d of targetSettings entries, should be %d',length(targetSettings),nSubprimaries));
    end
    
    % Subprimary values should be between 0 and 252.  We evenually
    % round to integer values.
    if (any(targetSettings < 0 | targetSettings > 252))
        error('Entries of targetSettings should be between 0 and 252');
    end
    
    try
        % [SEMIN]
        % Ingore the bgSettings, not meaningful for the subprimary
        % calibration.
        %
        % Set the subprimaries of whichever primary we're using to the
        % values in targetSettings.
        switch (obj.whichPrimary)
            case 1 % Adjust subprimaries for primary 1
                % Loop over subprimaries and set each
                for i=1:nSubprimaries 
                    Datapixx('SetPropixxHSLedCurrent', 0, i-1, round(targetSettings(i))); % Primary 1
                    Datapixx('SetPropixxHSLedCurrent', 1, i-1, 0); % Primary 2
                    Datapixx('SetPropixxHSLedCurrent', 2, i-1, 0); % Primary 3
                end 
                
            case 2 % Adjust subprimaries for primary 2
                % Loop over subprimaries and set each
                for i=1:nSubprimaries 
                    Datapixx('SetPropixxHSLedCurrent', 0, i-1, 0); % Primary 1
                    Datapixx('SetPropixxHSLedCurrent', 1, i-1, round(targetSettings(i))); % Primary 2
                    Datapixx('SetPropixxHSLedCurrent', 2, i-1, 0); % Primary 3
                end 
                
            case 3 % Adjust subprimaries for primary 3
                % Loop over subprimaries and set each
                for i=1:nSubprimaries 
                    Datapixx('SetPropixxHSLedCurrent', 0, i-1, 0); % Primary 1
                    Datapixx('SetPropixxHSLedCurrent', 1, i-1, 0); % Primary 2
                    Datapixx('SetPropixxHSLedCurrent', 2, i-1, round(targetSettings(i))); % Primary 3
                end 
                
            otherwise
                error('SACC display has only three primaries');
        end
        

    catch err
        sca;
        rethrow(err);
    end
    
end
