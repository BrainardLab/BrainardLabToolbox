function DemoPathConfigurator()
    
    % Restore system to default path settings
    PathConfigurator.restoreDefaultPath();
    
    % Find path dependencies for some functions
    % PTB's 'Screen.m'
    PathConfigurator.findToolboxDependencies('Screen')
    
    
    % isetbio's validation script 'PTB_vs_ISETBIO_Colorimetry.m'
    PathConfigurator.findToolboxDependencies('PTB_vs_ISETBIO_Colorimetry')
    
    % isetbio's 'oiCreate.m'
    PathConfigurator.findToolboxDependencies('oiCreate')
    
    
    
    disp('-------- BEFORE --------')
    PathConfigurator.displayCurrentPath();  % Pass 'ALL' to see the long list of paths
    disp('-------- BEFORE --------')
    pause;
    
    % Remove all antive toolboxes but pure MATLAB
    PathConfigurator.removeNativeToolboxes();
    
    
    % Remove custom toolboxes
    PathConfigurator.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes');
    PathConfigurator.removeNonNativeToolboxes('/Users/Shared/Matlab/ToolboxesDistrib');
    PathConfigurator.removeNonNativeToolboxes('/Users/nicolas/Documents/1.Code');
    
    % Refresh caches
    PathConfigurator.rehash();

    disp('----- AFTER --------')
    PathConfigurator.displayCurrentPath('');  % Pass 'ALL' to see the long list of paths
    disp('-----END OF AFTER -----');
    
end