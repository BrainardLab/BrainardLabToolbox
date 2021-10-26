function updateBackgroundAndTarget(obj, bgSettings, targetSettings, useBitsPP)
    % If the user sets useBitsPP to true, something has gone wrong.
    if (useBitsPP)
        error('The PsychImaging calibrator does not support bits++ yet');
    end
    
    % Set and check that the number of subprimaries is right
    if (length(targetSettings) ~= obj.nSubprimaries)
        error(sprintf('Wrong number %d of targetSettings entries, should be %d',length(targetSettings),obj.nSubprimaries));
    end
    
    % Subprimary values should be between 0 and 1.  We evenually
    % multiply by 252 round to integer values.
    if (any(targetSettings < 0 | targetSettings > 1))
        error('Entries of targetSettings should be between 0 and 252');
    end
    
    try
        % [SEMIN]
        % Ingore the bgSettings, not meaningful for the subprimary
        % calibration.
        %
        % Set the subprimaries of whichever primary we're using to the
        % values in targetSettings.
        %
        % Set other two primaries to the arbitraryBlack setting, to get 
        % ambient measurement out of the mud.
        
        
        switch (obj.whichPrimary)
            case 1 % Adjust subprimaries for primary 1
                % Loop over subprimaries and set each
                for i=1:obj.nSubprimaries 
                    Datapixx('SetPropixxHSLedCurrent', 0, obj.logicalToPhysical(i), round((obj.nInputLevels-1)*targetSettings(i))); % Primary 1
                    Datapixx('SetPropixxHSLedCurrent', 1, obj.logicalToPhysical(i), round((obj.nInputLevels-1)*obj.arbitraryBlack)); % Primary 2
                    Datapixx('SetPropixxHSLedCurrent', 2, obj.logicalToPhysical(i), round((obj.nInputLevels-1)*obj.arbitraryBlack)); % Primary 3
                end 
                
            case 2 % Adjust subprimaries for primary 2
                % Loop over subprimaries and set each
                for i=1:obj.nSubprimaries 
                    Datapixx('SetPropixxHSLedCurrent', 0, obj.logicalToPhysical(i), round((obj.nInputLevels-1)*obj.arbitraryBlack)); % Primary 1
                    Datapixx('SetPropixxHSLedCurrent', 1, obj.logicalToPhysical(i), round((obj.nInputLevels-1)*targetSettings(i))); % Primary 2
                    Datapixx('SetPropixxHSLedCurrent', 2, obj.logicalToPhysical(i), round((obj.nInputLevels-1)*obj.arbitraryBlack)); % Primary 3
                end 
                
            case 3 % Adjust subprimaries for primary 3
                % Loop over subprimaries and set each
                for i=1:obj.nSubprimaries 
                    Datapixx('SetPropixxHSLedCurrent', 0, obj.logicalToPhysical(i), round((obj.nInputLevels-1)*obj.arbitraryBlack)); % Primary 1
                    Datapixx('SetPropixxHSLedCurrent', 1, obj.logicalToPhysical(i), round((obj.nInputLevels-1)*obj.arbitraryBlack)); % Primary 2
                    Datapixx('SetPropixxHSLedCurrent', 2, obj.logicalToPhysical(i), round((obj.nInputLevels-1)*targetSettings(i))); % Primary 3
                end 
                
            otherwise
                error('SACC display has only three primaries');
        end
        

    catch err
        sca;
        rethrow(err);
    end
    
end
