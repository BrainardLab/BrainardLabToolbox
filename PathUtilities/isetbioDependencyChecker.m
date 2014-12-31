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
        isetbioRootPath() ...
        };

    % Get list of currently installed toolboxes
    s = PathConfig.getListOfInstalledToolboxes;

    % Remove everything
    restoredefaultpath();
    PathConfig.removeNativeToolboxes({});
            
    % Add what we want.
    PathConfig.addNativeToolboxes(s, listOfNativeToolboxesToAdd);
    PathConfig.addNonNativeToolboxes(listOfNonNativeToolboxesToAdd);

    PathConfig.rehash();
    PathConfig.getListOfInstalledToolboxes(1);
    
    validateFullAll();
end

