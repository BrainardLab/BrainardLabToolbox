% Method that returns a cell array with the directories of a user-selected list of native toolboxes

function nativeToolboxesDirList = getSelectNativeToolboxesDirList()
    v = ver;
    installedNativeToolboxNames = setdiff({v.Name}, {'MATLAB'})';

    % get names of all subdirs in $matlabroot/toolbox
    toolboxLocalDirs = dir(toolboxdir('') );
    
    notRelevantToolboxDirs = {'.', '..', 'matlab', 'local', 'shared', 'hdlcoder'};
    
    s.toolboxNames = {};
    s.tooboxLocalDirs = {};
    includedToolboxes = 0;
    
    for k = 1:numel(toolboxLocalDirs)
        if isempty(toolboxLocalDirs(k)) || ismember(toolboxLocalDirs(k).name, notRelevantToolboxDirs)
            continue;
        end
        if isfield(toolboxLocalDirs(k), 'name')
            toolboxInfo = ver(toolboxLocalDirs(k).name);
            if isempty(toolboxInfo)
               continue; 
            end
            includedToolboxes = includedToolboxes + 1;
            s.toolboxNames{includedToolboxes} = toolboxInfo.Name;
            s.tooboxLocalDirs{includedToolboxes} = sprintf('%s/%s', toolboxdir(''), toolboxLocalDirs(k).name);
            %fprintf('%-40s %s\n', s.toolboxNames{includedToolboxes}, s.tooboxLocalDirs{includedToolboxes})
        end
    end
    
    fprintf('\nInstalled native toolboxes:');
    for k = 1:includedToolboxes
       fprintf('\n\t [%2d]. %s', k, s.toolboxNames{k});
    end
    
    indicesForRemoval = input('\nEnter toolboxes to remove as an array (e.g., [1 4 23]) : ');
    
    nativeToolboxesDirList = {};
    for k = 1:numel(indicesForRemoval)
        nativeToolboxesDirList{k} = s.tooboxLocalDirs{indicesForRemoval(k)};
    end
    
end