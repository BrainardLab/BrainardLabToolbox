% Method to restore the default path
function restoreDefaultPath()
    % Restore all native toolbox paths
    restoredefaultpath()
    
    % Run the default startup
    pause(0.1);
    matlabrc
    
    run('/Users/Shared/Matlab/Toolboxes/BrainardLabStartup/startup.m');
end
