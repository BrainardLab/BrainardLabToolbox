function info = GetBrainardLabStandardToolboxesSVNInfo
% GetBrainardLabStandardSVNInfo - Gets SVN info for installed toolboxes.
%
% Syntax:
% info = GetBrainardLabStandardSVNInfo
%
% Description:
% Gets the subversion information for any toolboxes found in
% /Users/Shared/Matlab/Toolboxes, which is the standard location for the
% Brainard lab.
%
% Output:
% info.svnInfo (struct array) - Each element of the array is a structure
%    containing the subversion information for a particular toolbox.
% info.matlabInfo - The matlabInfo field is what is returned by Matlab's ver command.
% 
% 8/16/10  dhb  Add Psychtoolbox to the list
% 8/16/10  dhb  Also return Matlab version info
% 12/18/12 dhb  Fix bug that skipped iset.

% Get a list of all directories in /Users/Shared/Matlab/Toolboxes.  We'll
% consider each of these directories a possible SVN controlled folder.
[~, user] = unix('whoami'); 
if strcmp(user, 'melanopsin')
    toolboxDir = '/Users/melanopsin/Documents/MATLAB/toolboxes';
else
    toolboxDir = '/Users/Shared/Matlab/Toolboxes';
end
toolboxList = GetSubdirectories(toolboxDir);
numToolboxes = length(toolboxList);

svnInfoIndex = 0;

for i = 1:numToolboxes
	toolboxPath = fullfile(toolboxDir, toolboxList{i});
    
    % Some things that might be on path make this fail, and
    % we don't need that info.
    if (isempty(strfind(toolboxPath,'iset')))
        try
            si = GetSVNInfo(toolboxPath);
            
            if ~isempty(si)
                svnInfoIndex = svnInfoIndex + 1;
                svnInfo(svnInfoIndex) = si; %#ok<AGROW>
            end
        catch e
            if ~strcmp(e.message, 'GetSVNInfo: "svn info" failed to run.')
                rethrow(e);
            end
        end
    end
end

% Tuck svnInfo into info structure, and also put Matlab info there.
if exist('svnInfo', 'var')
	info.svnInfo = svnInfo;
else
	info.svnInfo = [];
end
info.matlabInfo = ver;
