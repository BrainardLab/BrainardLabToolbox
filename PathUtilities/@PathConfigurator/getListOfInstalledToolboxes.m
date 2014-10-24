% Methof that returns a cell array with the directories corresponding to the installed native Matlab toolboxes
function toolboxDirs = getListOfInstalledToolboxes()

    % Get complete list of installed toolboxes
    % v = ver;
    % Return all except for 'MATLAB'
    % installedNativeToolboxNames = setdiff({v.Name}, {'MATLAB'})';
    
    % get names of all subdirs in $matlabroot/toolbox
    toolboxLocalDirs = dir(toolboxdir('') );
    
    % list of subdirs of $matlabroot/toolbox that should not be removed
    % (needed for the basic MATLAB installation)
    toolboxDirsNotToBeRemoved = {'.', '..', 'matlab', 'local', 'shared', 'hdlcoder'};

    % go through all toolboxLocalDirs and select those not included in the
    % above list
    toolboxDirs = {};
    installedToolboxesNum = 0;
    for k = 1:numel(toolboxLocalDirs)
        if ismember(toolboxLocalDirs(k).name, toolboxDirsNotToBeRemoved)
             fprintf('\tToolbox directory %s/%s will not be removed from the path.\n', matlabroot, toolboxLocalDirs(k).name);
        else
            installedToolboxesNum  = installedToolboxesNum  + 1;
            toolboxDirs{installedToolboxesNum}  = sprintf('%s/toolbox/%s', matlabroot,toolboxLocalDirs(k).name);
        end
    end
    
end