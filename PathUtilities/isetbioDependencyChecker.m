function isetbioDependencyChecker

    % Restore default path
    PathConfig.restoreDefaultPath();
    
    listOfNativeToolboxesToAdd = { ...
        'Image Processing' ...
        'Signal Processing' ...
        };

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

