function exrMakeAll()

    mexFileNames = {'importEXRImage.cpp', 'exportEXRImage.cpp'};
    
    for k = 1:numel(mexFileNames)
        try
            mex(mexFileNames{k});
        catch err
            fprintf('%s failed to compile', mexFileNames{k});
            err
        end
    end
    
end
