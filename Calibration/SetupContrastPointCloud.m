function [ptCld, ptCldSettingsCal, ptCldContrastCal, ptCldExcitationsCal] = ...
    SetupContrastPointCloud(calObj,bgExcitations,options)
% Set up point cloud of contrasts for all possible settings
%
% Synopsis:
%    [ptCld, ptCldSettingsCal, ptCldContrastCal, ptCldExcitationsCal] = ...
%        SetupContrastPointCloud(calObj,bgExcitations)
%
% Description:
%     The method above is subject to imperfect quantization because each primary is
%     quantized individually. Here we'll quantize jointly across the three
%     primaries, using an exhaustive search process.  Amazingly, it is feasible
%     to search all possible quantized settings for each image pixel, and choose
%     the settings that best approximate the desired LMS excitations at that pixel.
%     
%     Compute an array with all possible triplets of screen settings,
%     quantized on the interval [0,1].
%     
%     This method takes all possible screen settings and creates a
%     point cloud of the corresponding cone contrasts. It then finds
%     the settings that come as close as possible to producing the
%     desired cone contrast at each point in the image. It's a little
%     slow but conceptually simple and fast enough to be feasible.
%
% Inputs:
%
% Outputs:
%
% Optional key/value pairs
%    'verbose' -                  Boolean. Default true.  Controls the printout.
%
% See also: SettingsFromPointCloud

% History:
%  11/19/21  dhb, smo  Pulled out as its own function.

%% Set parameters.
arguments
    calObj
    bgExcitations
    options.verbose (1,1) = true
end

if (options.verbose)
    tic;
    fprintf('Point cloud exhaustive method, setting up cone contrast cloud, this takes a while\n')
end

% Get number of screen levels out of calibration object.
screenNInputLevels = length(calObj.get('gammaInput'));

% Compute all possible settings as integers.  
ptCldIntegersCal = zeros(3,screenNInputLevels^3);
idx = 1;
for ii = 0:(screenNInputLevels-1)
    for jj = 0:(screenNInputLevels-1)
        for kk = 0:(screenNInputLevels-1)
            ptCldIntegersCal(:,idx) = [ii jj kk]';
            idx = idx+1;
        end
    end
end

% Convert integers to 0-1 reals, quantized
ptCldSettingsCal = IntegersToSettings(ptCldIntegersCal,'nInputLevels',screenNInputLevels);

% Get LMS excitations for each triplet of screen settings, and build a
% point cloud object from these.
ptCldExcitationsCal = SettingsToSensor(calObj,ptCldSettingsCal);
ptCldContrastCal = ExcitationsToContrast(ptCldExcitationsCal,bgExcitations);
ptCld = pointCloud(ptCldContrastCal');

% Force point cloud setup by finding one nearest neighbor. This is slow,
% but once it is done subsequent calls are considerably faster.
findNearestNeighbors(ptCld,[0 0 0],1);
if (options.verbose)
    toc
end