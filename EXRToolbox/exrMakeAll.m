function exrMakeAll()

    % Save current dir
    saveDir = pwd;
    % Get root dir abd cd to it
    [rootDir, ~] = fileparts(which(mfilename));
    cd(rootDir);
    
    mexFileNames = {'importEXRImage.cpp', 'exportEXRImage.cpp'};
    
    for k = 1:numel(mexFileNames)
        try
            fprintf('\nCompiling mex file %s ...', mexFileNames{k});
            mex(mexFileNames{k});
        catch err
            fprintf('%s failed to compile', mexFileNames{k});
            err
        end
    end
    
    % Change to old dir
    cd(saveDir);
end
