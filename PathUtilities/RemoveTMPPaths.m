function newPathList = RemoveTMPPaths(pathList,VERBOSE)
% newPathList = RemoveTMPPaths(pathList,VERBOSE)
%
% Removes from path .svn, .git and other Brainard lab temporary paths.
%
% When VERBOSE is true (default is false), prints out what is being removed.
%
% If no pathList is specified, then the program sets pathList to the result of the 'path' command
% before removing.  This function returns a 'pathsep' delimited list of paths omitting the unwanted
% paths.
%
% History:
% 27.07.09 Wrote from RemoveSVNPaths
% 25.01.10 Remove "xOld" as well.
% 08.04.10 Remove "xSource" as well.
% 06.01.12 Remove "xOmniDriver" as well.
% 07.12.13 Remove .svn and .git as well.
%          Factorize to use RemoveMatchtingPaths.

% If no pathList was passed to the function we'll just grab the one from
% Matlab.
if (nargin < 1 || isempty(pathList))
    % Grab the path list.
    pathList = path;
end
if (nargin < 2 || isempty(VERBOSE))
    VERBOSE = false;
end

try
    % We do the path removal in a try-catch block, because some of the
    % functions used inside this block are not available in Matlab-5 and
    % GNU/Octave. Our catch - block provides fail-safe behaviour for that
    % case.
    
    % Break the path list into individual path elements.
    pathElements = strread(pathList, '%s', 'delimiter', pathsep);

    pathStrsToRemove = {[filesep '.svn'], [filesep '.git'], 'xOld', 'xTests', 'zOld', [filesep 'tmp'] [filesep 'temp'], ...
                'xSource', 'xOmniDriver', 'xOneLightSDK', 'xOneLightDriver', 'xTunerSource' 'xCalibrationData', 'xCalibrateOmni', ...
                'OLDemos', ['OneLightToolbox' filesep 'Source'], ['OneLightToolbox' filesep 'Documentation'],  ...
                'Plots'};
    for i = 1:length(pathStrsToRemove)
        if (VERBOSE)
            fprintf('Removing ...%s... from Matlab path\n',pathStrsToRemove{i});
        end
        pathList = RemoveMatchingPaths(pathList,pathStrsToRemove{i});
    end
    newPathList = pathList;
    
catch
    % Fallback behaviour: We fail-safe by simply returning the unmodified
    % pathList. No paths removed, but the whole beast is still
    % functional.
    newPathList = pathList;
end
