function subdir = SelectSubdirectory(parentDir, exclusions, promptTitle, promptMessage, errorMessage)
% SelectSubdirectory - Displays a list of subdirectories and a prompt to select one.
%
% Syntax:
% subdir = SelectSubdirectory(parentDir)
% subdir = SelectSubdirectory(parentDir, exclusions)
% subdir = SelectSubdirectory(parentDir, exclusions, promptTitle)
% subdir = SelectSubdirectory(parentDir, exclusions, promptTitle, promptMessage, errorMessage)
%
% Description:
% This function displays a list of subdirectories of a specified parent
% folder and allows the user to select one of them.  Selections are made by
% inputting the number next to the directory name.  The function will loop
% until a valid selection is made.  Certain folders can be excluded by
% making use of the 'exclusions' parameter.  By default, '.', '..', and
% '.svn' folders are ignored.
%
% Input:
% parentDir (string) - The parent directory to look in.
% exclusions (1xN cell | string) - List of the excluded folders.  If empty,
%     the defaults of '.', '..', and '.svn' are used.
% promptTitle (string) - The title printed above the list of
%     subdirectories.  Default: 'Available directories'
% promptMessage (string) - The prompt after the list of subdirectories.
%     Default: 'Select a directory by number'
%
% Output:
% subdir (string) - The name of the selected subdirectory.

narginchk(1, 5);

% Setup some defaults.
if ~exist('exclusions', 'var')
	exclusions = [];
end
if ~exist('promptTitle', 'var') || isempty(promptTitle)
	promptTitle = 'Available directories';
end
if ~exist('promptMessage', 'var') || isempty(promptMessage)
	promptMessage = 'Select a directory by number';
end
if ~exist('errorMessage', 'var') || isempty(errorMessage)
	errorMessage = 'Could not find any subdirectories';
end

% Get a list of subfolders for the parent directory.
subdirs = GetSubdirectories(parentDir, exclusions);
numSubdirs = length(subdirs);
assert(numSubdirs > 0, 'SelectSubdirectory:NoSubdirs', ...
	[errorMessage ' for "%s".'], parentDir);

% Loop until a valid subdirectory was chosen.
while true
	fprintf('\n=== %s ===\n\n', promptTitle);
	for i = 1:numSubdirs
		fprintf('%d - %s\n', i, subdirs{i});
	end
	fprintf('\n');
	dirIndex = GetInput(promptMessage, 'number');
	
	% Jump out of the loop if the number was valid.
	if dirIndex >= 1 && dirIndex <= numSubdirs
		break;
	else
		fprintf('\n*** Invalid selection, try again. ***\n');
	end
end

% Return the selected subdirectory.
subdir = subdirs{dirIndex};
