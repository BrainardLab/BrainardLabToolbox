function DoxyDoc(whichClass)
%
%  4/17/2013   npc    Wrote it
%
%   
    inputIsGood = false;
    try
        % Check validity of input
        p = inputParser;
        addRequired(p,'whichClass',@ischar);
        parse(p, whichClass);
    
        inputIsGood = true;
        if (whichClass == '.')
            sourceDir = pwd;
            openingPage = 'files.html';
        else
            directory = which(whichClass);
            if (isempty(directory)) 
                fprintf('\nCould not locate class %s\n', whichClass);
                return
            end
            k = findstr(directory, '/');
            lastIndex = k(end);
            sourceDir = directory(1:lastIndex-1);
            openingPage = 'annotated.html';
        end
        
        % Generate the documentation
        GenerateDoxygenDocumentation(sourceDir, openingPage);
    catch e
        if (inputIsGood == false)
           fprintf('\n');
           fprintf('Please provide the class name as a string (in quotes)!\n'); 
           fprintf('For example: DoxyDoc(''GLWindow'')\n\n');
        end
        
        rethrow(e);
    end
    
end
