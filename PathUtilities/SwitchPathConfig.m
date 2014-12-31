function SwitchPathConfig

    % Restore default path
    PathConfig.restoreDefaultPath();
    
    fprintf('\nSelect from the following configurations:');
    fprintf('\n\t [0]. Standard Brainad lab config');
    fprintf('\n\t [1]. Matlab-main only');
    fprintf('\n\t [2]. No select native Matlab toolboxes');
    fprintf('\n\t [3]. No native Matlab toolboxes whatsoever');
    fprintf('\n\t [4]. No public BrainardLabToolbox');
    fprintf('\n\t [5]. No private BrainardLabToolbox');
    fprintf('\n\t [6]. No public or private BrainardLabToolbox');
    fprintf('\n\t [7]. No Psychtoolbox');
    fprintf('\n\t [8]. No public or private BrainardLabToolbox, no Psychtoolbox');
    fprintf('\n\t [9]. No ISETBIO');
    fprintf('\n\t[10]. ISETBIO, Matlab, Signal Processing, Image Processing');
    
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
            
        case 10
            
            % Will add the image and signal processing toolboxes
            listOfNativeToolboxesToAdd = { ...
                'Image Processing' ...
                'Signal Processing' ...
                };

            % Will add the isetbio toolbox
            listOfNonNativeToolboxesToAdd = { ...
                {isetbioRootPath(), '-end'} ...
                {'/Volumes/SDXC_64GB/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities/@PathConfig', '-begin'} ...
                };
            
            % Get list of currently installed toolboxes
            s = PathConfig.getListOfInstalledToolboxes;
        
            % Remove everything
            restoredefaultpath();
            
            % add the PathUtilities
            addpath('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities');
    
            PathConfig.removeNativeToolboxes({});
            
            % Add what we want.
            PathConfig.addNativeToolboxes(s, listOfNativeToolboxesToAdd);
            PathConfig.addNonNativeToolboxes(listOfNonNativeToolboxesToAdd);
    
        otherwise
            % do nothing PathConfig.restoreDefaultPath();
    end
    
    PathConfig.rehash();
    PathConfig.getListOfInstalledToolboxes(1);   
    
end


