% Method to remove all native Matlab toolboxes from the current path
function removeNativeToolboxes(list)

    if isempty(list)
        % Get list of installed native toolboxes
        list = PathConfig.getListOfInstalledToolboxes();
    end
    
    fprintf('\nRemoving MATLAB native toolboxes. Be patient ...');
    
    % turn off warnings for dirs not found
    warning off MATLAB:rmpath:DirNotFound
    
    % Remove paths to all installed native toolboxes
    for k = 1:numel(list)
        fprintf('\nRemoving %s.', list{k})
        rmpath(genpath(list{k}));
    end
    
    % turn back on warnings for dirs not found
    warning on MATLAB:rmpath:DirNotFound
    
    fprintf(' Done.\n');
end
