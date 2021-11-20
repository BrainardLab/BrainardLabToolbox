function [settingsCal] = SettingsFromPointCloud(ptCloud,inputCal,ptCldSettingsCal,options)
% Use point cloud to convert from input to settings.
%
% Synopsis:
%    [[settingsCal] = SettingsFromPointCloud(ptCloud,ptCldSettingsCal,inputCal)
%
% Description:
%     Use precomputed point cloud to convert input in cal format to settings, by
%     exhaustive search through the point cloud.
%
%     The semantics of what gets converted depends on how the point cloud
%     was set up.  A typical usage is to set up the point cloud with
%     contrasts corresponding to all possible settings, in which case this
%     routine gets the settings from contrast.
% Inputs:
%
% Outputs:
%
% Optional key/value pairs:
%    'verbose' -                  Boolean. Default true.  Controls the printout.
%
% See also: SetupContrastPointCloud

% History:
%  11/19/21  dhb, smo  Pulled out as its own function.

arguments
    ptCloud
    inputCal
    ptCldSettingsCal
    options.verbose (1,1) = true
end

% Say hello
if (options.verbose)
    tic;
    fprintf('Point cloud unique contrast method, finding image settings\n');
end

%% Get image settings, fast way
%
% Only look up each unique cone contrast once, and then fill into the
% settings image. Slick!
%
% Find the unique cone contrasts in the image
[uniqueInputCal,~,uniqueIC] = unique(inputCal','rows','stable');
uniqueInputCal = uniqueInputCal';

% For each unique contrast, find the right settings and then plug into
% output image.
uniqueSettingsCal = zeros(3,size(uniqueInputCal,2));
for ll = 1:size(uniqueInputCal,2)
    minIndex = findNearestNeighbors(ptCloud,uniqueInputCal(:,ll)',1);
    uniqueSettingsCal(:,ll) = ptCldSettingsCal(:,minIndex);
end
settingsCal = uniqueSettingsCal(:,uniqueIC);

% Say goodbye
if (options.verbose)
    toc
end