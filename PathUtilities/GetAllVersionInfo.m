function [versionInfo,codeDir] = GetAllVersionInfo(programName)
% [versionInfo,codeDir]  = GetAllVersionInfo([programName])
%
% Tuck away version info for program directory and all standard
% Brainard lab toolboxes.  Looks for both SVN and GIT version
% numbers.  Also gets Matlab version info.
%
% If programName is not passed, is empty, or has no info, then
% that part is skipped.

% Also returns the full path to the directory containing the
% program, if it is passed.
%
% Typical usage
%   exp.mFileName = mfilename;
%   [exp.versionInfo,exp.codeDir] = GetAllVersionInfo(exp.mFileName);
%
% 7/12/13  dhb  Wrote it.
% 5/3/2025 NPC  Removed check for SVN.


%% Default
if (nargin < 1)
    programName  = [];
end

%% Grab the subversion/git information about program.
if (~isempty(programName))
    % Get path to program.
    codeDir = fileparts(which(programName));  
    theInfo = GetGITInfo(codeDir);
    if (~isempty(theInfo))
        versionInfo.(sprintf('%sInfo', programName)) = theInfo;
    end
end

%% Get information on all available toolboxes
versionInfo.toolboxInfo = GetBrainardLabStandardToolboxesInfo;

%% Get Matlab version info
versionInfo.matlabInfo = ver;

