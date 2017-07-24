function OperateOnAllFilesWithMatchingPattern(rootDir, patternToMatch, operationName)
% OperateOnAllFilesWithMatchingPattern(rootDir, patternToMatch, operationName)
%
% Description:
%	Performs operation determined by operationName to all files under the
%	rootDir, whose name contains the patternToMatch.
%
% Example usage:
%   operateOnAllFilesWithMatchingPattern('/Volumes/Manta TM HD/Dropbox (Aguirre-Brainard Lab)', '*David Brainard''s conflicted copy*', 'delete');
%
% 7/24/1027   npc  Wrote it
%

    % List of valid operations 
    validOperationNames = {'delete', 'duplicate'};
    assert(ismember(operationName, validOperationNames), 'Not a valid operation');
    
    % Find all files matching the desired pattern
    a = filesMatchingPattern(rootDir, patternToMatch);

    if (numel(a) > 0)
        fprintf('\nThe following list of %d files contain the ''%s'' pattern\n', numel(a), patternToMatch);
        for k = 1:numel(a)
            theSourceFile = a(k).name;
            [dirName, fName, ext] = fileparts(theSourceFile);
            fprintf('[%04d] <strong>%s%s</strong>\n       located in:rootDir%s\n\n', k, fName, ext, strrep(dirName, rootDir, ''));
        end
    else
        fprintf('\nThere were no files containing the ''%s'' pattern under the %s directory.\n\n', patternToMatch, rootDir);
        return;
    end
    
    
    fprintf('Hit enter to perform the ''%s'' operation on the above files\n', operationName);
    pause 
    for k = 1:numel(a)
        theSourceFile = a(k).name;
        theSourceFile = unixizeFileName(theSourceFile);
        switch (operationName)
            case 'delete'
                operationString = sprintf('rm %s %s', theSourceFile);
            case 'duplicate'
                theTargetFile = sprintf('%s-2',theSourceFile);
                operationString = sprintf('cp %s %s', theSourceFile, theTargetFile);
            otherwise
                error('Unknown operation: ''%s''!\n', operationName);
                
        end
        unix(operationString);
    end  
end


function fName = unixizeFileName(fName)
    fName = strrep(fName, '(', '\(');
    fName = strrep(fName, ')', '\)');
    fName = strrep(fName, ' ', '\ ');
    fName = strrep(fName, '''', '\''');
end
