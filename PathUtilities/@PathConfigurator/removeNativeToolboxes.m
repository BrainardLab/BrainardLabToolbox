% Method to remove all native Matlab toolboxes from the current path
function removeNativeToolboxes()

    % Get list of installed native toolboxes
    s = PathConfigurator.getListOfInstalledToolboxes();
    
    fprintf('\nRemoving MATLAB native toolboxes. Be patient ...');
    
    % turn off warnings for dirs not found
    warning off MATLAB:rmpath:DirNotFound
    
    % Remove paths to all installed native toolboxes
    for k = 1:numel(s)
        rmpath(genpath(s{k}));
    end
    
    % turn back on warnings for dirs not found
    warning on MATLAB:rmpath:DirNotFound
    
    fprintf(' Done.\n');
end
