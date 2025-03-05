function info = GetBrainardLabStandardToolboxesInfo
% GetBrainardLabStandardInfo - Gets SVN/GIT info for installed toolboxes.
%
% Syntax:
% info = GetBrainardLabStandardGITInfo
%
% Description:
% Gets the subversion information for any toolboxes found in
% /Users/Shared/Matlab/Toolboxes, which is the standard location for the
% Brainard lab.
%
% Output:
% info (struct) - Contains the version info.
%    
% 8/16/10   dhb  Add Psychtoolbox to the list
% 8/16/10   dhb  Also return Matlab version info
% 12/18/12  dhb  Fix bug that skipped iset
% 3/15/2025 NPC  Removed SVN checks

% Get a list of all directories in /Users/Shared/Matlab/Toolboxes.  We'll
% consider each of these directories a possible GIT controlled folder.
toolboxDir = '/Users/Shared/Matlab/Toolboxes';
toolboxList = GetSubdirectories(toolboxDir);
numToolboxes = length(toolboxList);

gitInfoIndex = 0;

for i = 1:numToolboxes
    toolboxPath = fullfile(toolboxDir, toolboxList{i});
    si = GetGITInfo(toolboxPath);
    if ~isempty(si)
        gitInfoIndex = gitInfoIndex + 1;
        theGitInfo(gitInfoIndex) = si;
    end
end

% Tuck gitInfo into info structure, and also put Matlab info there.
info = [];
if (exist('theGitInfo','var'))
	info.git = theGitInfo;
end
info.svn = [];