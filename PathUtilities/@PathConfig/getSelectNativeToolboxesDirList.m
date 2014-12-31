% Method that returns a cell array with the directories of a user-selected list of native toolboxes

function nativeToolboxesDirList = getSelectNativeToolboxesDirList()

    PathConfig.rehash();
    s = PathConfig.getListOfInstalledToolboxes(0);

    fprintf('\nInstalled native toolboxes:');
    for k = 1:numel(s.toolboxNames)
       fprintf('\n\t [%2d]. %s', k, s.toolboxNames{k});
    end
    
    indicesForRemoval = input('\nEnter toolboxes to remove as an array (e.g., [1 4 23]) : ');
    
    nativeToolboxesDirList = {};
    for k = 1:numel(indicesForRemoval)
        nativeToolboxesDirList{k} = s.toolboxLocalDirs{indicesForRemoval(k)};
    end
    
end