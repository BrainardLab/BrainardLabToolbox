% Method to display the path as a cell array

function displayCurrentPath(varargin)
    pathAsCellArray = strread(path,'%s','delimiter', pathsep);
    fprintf('\n');
    if (nargin > 0) && ischar(varargin{1}) && strcmp(varargin{1},'ALL')
        pathAsCellArray
    end
    fprintf('Total number of paths: %d\n', size(pathAsCellArray,1));
end
