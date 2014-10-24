function DemoPathConfig()
    
    % Restore system to default path settings
    PathConfig.restoreDefaultPath();
    
    % Find path dependencies for some functions
    % PTB's 'Screen.m'
    PathConfig.findToolboxDependencies('Screen')
    
    % isetbio's validation script 'PTB_vs_ISETBIO_Colorimetry.m'
    PathConfig.findToolboxDependencies('PTB_vs_ISETBIO_Colorimetry')
    
    % isetbio's 'oiCreate.m'
    PathConfig.findToolboxDependencies('oiCreate')
    
    
    disp('-------- BEFORE --------')
    PathConfig.displayCurrentPath();  % Pass 'ALL' to see the long list of paths
    disp('-------- BEFORE --------')
    
    % Remove all native toolboxes but pure MATLAB
    PathConfig.removeNativeToolboxes({});
    
    
    % Remove custom toolboxes
    PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes');
    PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/ToolboxesDistrib');
    PathConfig.removeNonNativeToolboxes('/Users/nicolas/Documents/1.Code');
    
    % Refresh caches
    PathConfig.rehash();

    disp('----- AFTER --------')
    PathConfig.displayCurrentPath('');  % Pass 'ALL' to see the long list of paths
    disp('-----END OF AFTER -----');
    
end