function [settingsCal,indicesCal] = SettingsFromLookup(ptCloudDesiredValuesCal,ptCloudValuesCal,ptCldSettingsCal,options)
% Use point cloud to convert from input to settings.
%
% Syntax:
%    settingsCal,indicesCal] = SettingsFromLookup(ptCloudDesiredValuesCal,ptCloudValuesCal,ptCldSettingsCal)

% Description:
%     Use precomputed values to convert input in cal format to settings, by
%     exhaustive search.
%
%     The semantics of what gets converted depends on how the pased values were
%     set up.  A typical usage is to set up twith
%     contrasts corresponding to all possible settings, in which case this
%     routine gets the settings from contrast.
%
%     If the values being searched are 3D, it is much faster to use the
%     point cloud version of this routine.
%
% Inputs:
%    ptCloudDesiredValuesCal -    Desired values in cal format.  It can be
%                                 excitations, contrasts, etc., but we use
%                                 contrasts in SACC project.  Whatever
%                                 these are, the same type of thing should
%                                 be in the point cloud.
%    ptCloudValuesCal -           The values to search
%    ptCldSettingsCal -           The settings that correspond to the values to search.
%                                 That is, these are in the same order as the values
%                                 passed into the point cloud.  Here they are in
%                                 in a cal format.
%
% Outputs:
%    settingsCal -                Settings acquired from the point cloud search.
%    indicesCal -                 Matching indices with the locations of
%                                 the acquired settings in the point cloud.
%                                 Using these indices into ptCldSettingsCal
%                                 gives the returned settingsCal.  To put
%                                 it another way:
%                                   settingsCal = ptCldSettingsCal(:,indicesCal);
%                                 Note that these values come back in the
%                                 range [1,N] where N is the number of
%                                 vectors in the point cloud.  Subtract 1
%                                 if you want to use these as frame buffer
%                                 values.
%
% Optional key/value pairs:
%    'verbose' -                  Boolean. Default true.  Controls the printout.
%
% See also: SetupContrastPointLookup, SetupContrastPointCloud, SettingsFromPointCloud

% History:
%    11/19/21  dhb, smo           Pulled out as its own function.
%    11/20/21  dhb                Function has been moved in the repository BrainardLabToolbox

%% Set parameters.
arguments
    ptCloudDesiredValuesCal
    ptCloudValuesCal
    ptCldSettingsCal
    options.verbose (1,1) = true
end

%% Say hello.
if (options.verbose)
    tic;
    fprintf('Search lookup table contrast method, finding image settings\n');
end

%% Get image settings, fast way
%
% Only look up each unique cone contrast once, and then fill into the
% settings image. Slick!
%
% Find the unique cone contrasts in the image.
[uniqueInputCal,~,uniqueIC] = unique(ptCloudDesiredValuesCal','rows','stable');
uniqueInputCal = uniqueInputCal';

% For each unique contrast, find the right settings and then plug into
% output image.
uniqueIndicesCal = zeros(1,size(uniqueInputCal,2));
for ll = 1:size(uniqueInputCal,2)
    if (rem(ll,500) == 0)
        fprintf('\tDone %d of %d settings\n')
    end
    allDiffs = ptCloudValuesCal - uniqueInputCal(:,ll);
    sumDiffs = sum(allDiffs.^2,1);
    [~,indices] = min(sumDiffs);
    uniqueIndicesCal(ll) = indices(1);
end
uniqueSettingsCal = ptCldSettingsCal(:,uniqueIndicesCal);
indicesCal = uniqueIndicesCal(uniqueIC);
settingsCal = uniqueSettingsCal(:,uniqueIC);

%% Say goodbye.
if (options.verbose)
    toc;
end

end