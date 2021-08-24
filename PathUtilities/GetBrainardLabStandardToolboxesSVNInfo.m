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
% 10/4/17  npc  Look for toolboxes in new directory

% Get a list of all directories in /Users/Shared/Matlab/Toolboxes.  We'll
% consider each of these directories a possible SVN controlled folder.
sysInfo = GetComputerInfo();
if strcmp(sysInfo.userShortName, 'melanopsin')
    toolboxDir = '/Users/melanopsin/Documents/MATLAB/toolboxes';
elseif (strcmp(sysInfo.userShortName, 'colorlab')  && strcmp(sysInfo.localHostName, 'mudpuppy'))
    toolboxDir = '/Users/colorlab/Documents/MATLAB/toolboxes';
else
    toolboxDir = sprintf('/Users/%s/Documents/MATLAB/toolboxes',sysInfo.userShortName);
end

% Linux platform
if (strfind(sysInfo.MatlabPlatform, 'GLNXA64'))
    toolboxDir = sprintf('/home/%s/Documents/MATLAB/toolboxes', sysinfo.userShortName);
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
