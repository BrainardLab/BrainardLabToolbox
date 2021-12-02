function [settingsCal,indicesCal] = SettingsFromPointCloud(ptCloud,inputCal,ptCldSettingsCal,options)
% Use point cloud to convert from input to settings.
%
% Syntax:
%    [settingsCal,indicesCal] = SettingsFromPointCloud(ptCloud,inputCal,ptCldSettingsCal)
%
% Description:
%     Use precomputed point cloud to convert input in cal format to settings, by
%     exhaustive search through the point cloud.
%
%     The semantics of what gets converted depends on how the point cloud
%     was set up.  A typical usage is to set up the point cloud with
%     contrasts corresponding to all possible settings, in which case this
%     routine gets the settings from contrast.
%
% Inputs:
%    ptCloud -                    Precomputed screen point cloud results.
%    inputCal -                   Desired values in cal format.  It can be
%                                 excitations, contrasts, etc., but we use
%                                 contrasts in SACC project.  Whatever
%                                 these are, the same type of thing should
%                                 be in the point cloud.
%    ptCldSettingsCal -           The settings that correspond to the point cloud.
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
% See also: SetupContrastPointCloud

% History:
%    11/19/21  dhb, smo           Pulled out as its own function.
%    11/20/21  dhb                Function has been moved in the repository BrainardLabToolbox

%% Set parameters.
arguments
    ptCloud
    inputCal
    ptCldSettingsCal
    options.verbose (1,1) = true
end

%% Say hello.
if (options.verbose)
    tic;
    fprintf('Point cloud unique contrast method, finding image settings\n');
end

%% Get image settings, fast way
%
% Only look up each unique cone contrast once, and then fill into the
% settings image. Slick!
%
% Find the unique cone contrasts in the image.
[uniqueInputCal,~,uniqueIC] = unique(inputCal','rows','stable');
uniqueInputCal = uniqueInputCal';

% For each unique contrast, find the right settings and then plug into
% output image.
uniqueIndicesCal = zeros(1,size(uniqueInputCal,2));
for ll = 1:size(uniqueInputCal,2)
    uniqueIndicesCal(ll) = findNearestNeighbors(ptCloud,uniqueInputCal(:,ll)',1);
end
uniqueSettingsCal = ptCldSettingsCal(:,uniqueIndicesCal);
indicesCal = uniqueIndicesCal(uniqueIC);
settingsCal = uniqueSettingsCal(:,uniqueIC);

%% Say goodbye.
if (options.verbose)
    toc;
end

end