% Method to remove all non-native Matlab toolboxes from the current path
function removeNonNativeToolboxes(toolboxPath)
    fprintf('\nRemoving non-native toolboxes (%s). Be patient ...', toolboxPath);
    
    % turn off warnings for dirs not found
    warning off MATLAB:rmpath:DirNotFound
    
    % remove paths
    rmpath(genpath(toolboxPath));
    
%     pathAsCellArray = strread(genpath(toolboxPath),'%s','delimiter', pathsep);
%     for k = 1:numel(pathAsCellArray)
%             rmpath(pathAsCellArray{k});
%     end
    
    addpath('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities');
    
    % turn on warnings for dirs not found
    warning on MATLAB:rmpath:DirNotFound
    fprintf(' Done.\n');
end