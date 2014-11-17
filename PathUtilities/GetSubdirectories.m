function subDirs = GetSubdirectories(basePath, exclusions)
% subDirs = GetSubdirectories([basePath], [exclusions])
%
% Description:
% Gets a list of all subdirectories immediately below "basePath".  By
% default, this function excludes '.', '..', and '.svn' folders from the
% results, but the list of exclusions can be overriden.
%
% Optional Input:
% basePath (string) - Specifies which folder to look under.  Defaults to
%   '.', i.e. the current working directory.
% exclusions (cell array|string) - List of folder exclusions.  Defaults to 
%   {'.', '..', '.svn'}.
%
% Output:
% subDirs (cell array) - Cell array of strings with each string being the
%   name of a subdirectory.  Returns empty if no subdirectories were found.

% Setup variable defaults.
if ~exist('basePath', 'var') || isempty(basePath)
	basePath = '.';
end
if ~exist('exclusions', 'var') || isempty(exclusions)
	exclusions = {'.', '..', '.svn'};
end

% Validate the input.
if ~ischar(basePath)
	error('"basePath" must be a string.');
end
if ~iscell(exclusions) && ~ischar(exclusions)
	error('"exclusions" must be a cell array or string.');
end

% Make sure that "basePath" exists.
if ~exist(basePath, 'dir')
	error('"basePath" of "%s" does not exist.', basePath);
end

subDirs = {};

% Get the directory contents.
dirContents = dir(basePath);

% Select only the items that are directories.
dirContents = dirContents([dirContents.isdir]);

% Loop through the folder list and pull non excluded folders.
for i = 1:length(dirContents)
	if ~any(strcmp(dirContents(i).name, exclusions))
		subDirs{end+1} = dirContents(i).name; %#ok<AGROW>
	end
end
