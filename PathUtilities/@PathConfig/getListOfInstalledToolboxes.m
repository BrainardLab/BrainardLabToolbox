% Methof that returns a cell array with the directories corresponding to the installed native Matlab toolboxes
function s = getListOfInstalledToolboxes(beVerbose)
    %v = ver;
    %installedNativeToolboxNames = setdiff({v.Name}, {'MATLAB'})';

    % get names of all subdirs in $matlabroot/toolbox
    toolboxLocalDirs = dir(toolboxdir('') );
    
    notRelevantToolboxDirs = {'.', '..', 'matlab', 'local', 'shared', 'hdlcoder'};
    
    s.toolboxNames = {};
    s.tooboxLocalDirs = {};
    includedToolboxes = 0;
    
    if (nargin == 1) && (~isempty(beVerbose)) && (beVerbose == 1)
        fprintf('\nInstalled toolboxes and respective directories:');
    end
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
            if (nargin == 1) && (~isempty(beVerbose)) && (beVerbose == 1)
                fprintf('\n[%2d]. %-40s %s', includedToolboxes, s.toolboxNames{includedToolboxes}, s.tooboxLocalDirs{includedToolboxes})
            end
        end
    end
    
    if (nargin == 1) && (~isempty(beVerbose)) && (beVerbose == 1)
        fprintf('\n');
    end
    
end


function toolboxDirs = OLDgetListOfInstalledToolboxes()

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