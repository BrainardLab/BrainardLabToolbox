% Method to shutdown the device
function obj = shutDown(obj)
    if (obj.options.verbosity > 9)
        fprintf('In SACCPrimary.shutDown() method\n');
    end

    % [SEMIN]
    % Here put all the subprimaries back into a fairly normal state.
    % Normal mode, and some reasonable R, G, and B subprimary values.

    % Close everything. Here we should also reset the PTB verbosity
    sca;
end