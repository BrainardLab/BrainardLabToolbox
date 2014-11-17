function SwitchPathConfig

    % Restore default path
    PathConfig.restoreDefaultPath();
    
    fprintf('\nSelect from the following configurations:');
    fprintf('\n\t[0]. Standard Brainad lab config');
    fprintf('\n\t[1]. Matlab-main only');
    fprintf('\n\t[2]. No select native Matlab toolboxes');
    fprintf('\n\t[3]. No native Matlab toolboxes whatsoever');
    fprintf('\n\t[4]. No public BrainardLabToolbox');
    fprintf('\n\t[5]. No private BrainardLabToolbox');
    fprintf('\n\t[6]. No public or private BrainardLabToolbox');
    fprintf('\n\t[7]. No Psychtoolbox');
    fprintf('\n\t[8]. No public or private BrainardLabToolbox, no Psychtoolbox');
    fprintf('\n\t[9]. No ISETBIO');
    
    pathSelection = input('\nSelect a configuration [default = 0]: ');
    if (isempty(pathSelection))
        pathSelection = 0;
    end
    
    switch (pathSelection)
        case 0
           % do nothing PathConfig.restoreDefaultPath();
            
        case 1
            PathConfig.removeNativeToolboxes({});
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes');
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/ToolboxesDistrib');
    
        case 2
            nativeToolboxesDirList = PathConfig.getSelectNativeToolboxesDirList();
            PathConfig.removeNativeToolboxes(nativeToolboxesDirList);
            
        case 3
            PathConfig.removeNativeToolboxes({});
            
        case 4
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox');
          
        case 5
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabPrivateToolbox');
        
        case 6
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox');
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabPrivateToolbox');
        
        case 7
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/Psychtoolbox-3');
            
        case 8
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox');
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/BrainardLabPrivateToolbox');
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/Psychtoolbox-3');
            
        case 9
            PathConfig.removeNonNativeToolboxes('/Users/Shared/Matlab/Toolboxes/isetbio');
            
        otherwise
            % do nothing PathConfig.restoreDefaultPath();
    end
    
    PathConfig.rehash();
    PathConfig.getListOfInstalledToolboxes(1);
    
    checkISETBIOvalidationScripts = false;
    if checkISETBIOvalidationScripts
        % Check whether isetbio validation scripts run to completion
        v_oi
        v_ISETBIO
        PathConfig.rehash();
        PathConfig.getListOfInstalledToolboxes(1);
    end
    
    while (1)
        functionName = input('\nEnter function name for which to check toolbox dependencies: ', 's');
        PathConfig.findToolboxDependencies(functionName)
    end
    
end


