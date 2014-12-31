function isetbioDependencyChecker

    % Restore default path
    PathConfig.restoreDefaultPath();
    
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

    PathConfig.rehash();
    PathConfig.getListOfInstalledToolboxes(1);
    
    validateFullAll();
end

