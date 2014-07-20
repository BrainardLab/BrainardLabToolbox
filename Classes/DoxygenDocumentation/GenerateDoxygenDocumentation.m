 function GenerateDoxygenDocumentation(sourceDir, openingPage) 
%
%
%  4/17/2013   npc    Wrote it
%
%   
%   

    % save the current directory
    currentFolder = pwd;
    cd(sourceDir);
    
    % Set the directory where Doxygen lives
    doxygenAppDirectory = '/Users/Shared/Matlab/Toolboxes/Classes-Dev/DoxygenDocumentation/Doxygen.app';
    
    % Set the Doxygen documentation folder
    baseFolder = '/Users/Shared/Matlab/Toolboxes/Classes-Dev/DoxygenDocumentation';
    
    % Set the Scripts folder
    scriptsFolder = sprintf('%s/Scripts', baseFolder);

    try 

        doxygenConfigFileName = sprintf('%s/Doxygen.conf', sourceDir);
        doxygenDocsDirectory  = sprintf('%s/DoxygenDoc', sourceDir);
        
        % erase previous documentation for whichClass, if it exists
        if (exist(doxygenDocsDirectory, 'dir')==7)
            rmdir(doxygenDocsDirectory, 's');
        end
        
        if exist(doxygenConfigFileName, 'file')
            
            doxygenCommand = sprintf('%s/Contents/Resources/doxygen %s', doxygenAppDirectory, doxygenConfigFileName);
            fprintf('Running %s command\n', doxygenCommand);
            system(doxygenCommand);

            
            postProcessingCommand = sprintf('%s/mtocpp_post %s', scriptsFolder, doxygenDocsDirectory);
            fprintf('In PostProcessing phase: %s', postProcessingCommand);
            fprintf('\n');
            system(postProcessingCommand);
            
            fprintf('\nHTML documentation saved to %s', doxygenDocsDirectory);
            % View the newly-generated Doxygen documentation
            urlAddress = sprintf('file://%s/%s', doxygenDocsDirectory, openingPage);

            if (verLessThan('matlab', '8.0.0'))
                % open using Safari, the built-in web browser is crappy
                system(sprintf('open /Applications/Safari.App %s', urlAddress));
            else
                % open using the built-in browser, which got good with release 8.1.0 (2012b)
                web(urlAddress);
            end
            
        else
            fprintf('\n');
            fprintf('Did not find a doxygen %s config file. \nPlease generate one.\n', doxygenConfigFileName);
        end
        
       % cd(currentFolder);
        
    catch e
        
        cd(currentFolder);
        rethrow(e);
    end
    
end
