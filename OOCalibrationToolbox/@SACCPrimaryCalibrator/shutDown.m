% Method to shutdown the device
function obj = shutDown(obj)
    if (obj.options.verbosity > 9)
        fprintf('In SACCPrimary.shutDown() method\n');
    end

    % [SEMIN]
    % Here put all the subprimaries back into a fairly normal state.
    % Normal mode, and some reasonable R, G, and B subprimary values.
    
    % Set the projector in a normal mode
    CommandNormalMode = 'vputil rw 0x1c8 0x0 -q quit'; 
    unix(CommandNormalMode)

    % Set the projector default settings when you can get when turning on 
    CurrentDefault = obj.nInputLevels;
    
    % Set Primary1 
    for i=[13,14,15] % SubPrimary
        Datapixx('SetPropixxHSLedCurrent', 0, obj.logicalToPhysical(i), CurrentDefault); 
    end
    
    % Set Primary2
    for i=[1,5,6,7] % SubPrimary
        Datapixx('SetPropixxHSLedCurrent', 1, obj.logicalToPhysical(i), CurrentDefault);
    end
    
    % Set Primary3
    for i=[1,2,3] % SubPrimary 
        Datapixx('SetPropixxHSLedCurrent', 2, obj.logicalToPhysical(i), CurrentDefault); 
    end

    % Close everything. Here we should also reset the PTB verbosity
    sca;
end