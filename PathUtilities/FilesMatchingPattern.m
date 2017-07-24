function theFiles = FilesMatchingPattern(rootDir, patternToMatch)
% theFiles = FilesMatchingPattern(rootDir, patternToMatch)
%
% Description:
%	Find all files under the rootDir, whose name contains the patternToMatch.
%
% Usage:
%   See OperateOnAllFilesWithMatchingPattern
%
% 7/24/1027   npc  Wrote it
%

    pathString = genPathString(rootDir);
    pathDirs = strsplit(pathString, pathsep);
    
    % Remove empty cells
    pathDirs = pathDirs(~cellfun('isempty', pathDirs)) ; 

    % Parse all directories
    theFiles = [];
    pathandfilt = fullfile(pathDirs, patternToMatch);
    for ifolder = 1:length(pathandfilt)
        newFiles = dir(pathandfilt{ifolder});
        if ~isempty(newFiles)
            fullnames = cellfun(@(a) fullfile(pathDirs{ifolder}, a), {newFiles.name}, 'UniformOutput', false); 
            [newFiles.name] = fullnames{:};
            theFiles = cat(1, theFiles, newFiles);
        end
    end

    % Remove . and ..
    if ~isempty(theFiles)
        [~, ~, tail] = cellfun(@fileparts, {theFiles(:).name}, 'UniformOutput', false);
        dottest = cellfun(@(x) isempty(regexp(x, '\.+(\w+$)', 'once')), tail);
        theFiles(dottest & [theFiles(:).isdir]) = [];
    end
end


function [p] = genPathString(d)
    files = dir(d);
    if isempty(files)
      return
    end
    
    % Initialize output
    p = '';  

    % Add d to the path even if it is empty.
    p = [p d pathsep];

    % Set logical vector for subdirectory entries in d
    isdir = logical(cat(1,files.isdir));

    % Select only directory entries from the current listing
    dirs = files(isdir);  

    for i=1:length(dirs)
       dirname = dirs(i).name;
       if  (~strcmp( dirname,'.') && ~strcmp( dirname,'..'))
           % Recursive calling genpath
           p = [p genPathString(fullfile(d,dirname))];  
       end
    end
end
