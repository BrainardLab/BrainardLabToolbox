function [ptCldSettingsCal, ptCldContrastCal, ptCldExcitationsCal] = SetupContrastPointLookup(calObj,bgExcitations,options)
% Set up lookup table values for search
%
% Syntax:
%     [ptCldSettingsCal, ptCldContrastCal, ptCldExcitationsCal] = SetupContrastPointLookup(calObj,bgExcitations,options)
%
% Description:
%     Here we quantize jointly across the three primaries, using an
%     exhaustive search process.  Amazingly, it is feasible to search all
%     possible quantized settings for each image pixel, and choose the
%     settings that best approximate the desired LMS excitations at that
%     pixel.
%
%     Compute an array with all possible triplets of screen settings,
%     quantized on the interval [0,1].
%
%     This method sets up the values we need for the subsequent search.
%
% Inputs:
%    calObj -                     Screen cal object to use to make a point
%                                 cloud. This object defines both device
%                                 properties and the sensor color space in
%                                 which we compute contrast.
%    bgExcitations -              Screen background excitations (aka sensor values)
%                                 for calculation of contrasts.
%
% Outputs:
%    ptCldSettingsCal -           All screen settings for desired contrasts
%                                 in cal format. This cal format strings out the
%                                 values for all pixesl along the columns, easier for
%                                 color space conversions than image format.
%    ptCldContrastCal -           All contrasts in cal format.
%    ptCldExcitationsCal -        All excitations in cal format.
%
% Optional key/value pairs:
%    'verbose' -                  Boolean. Default true.  Controls the printout.
%
% See also: SettingsFromLookup, SetupContrastPointCloud, SettingsFromPointCloud, ImageToCalFormat, CalFormatToImage

% History:
%    11/19/21  dhb, smo           Pulled out as its own function.
%    11/20/21  dhb                Function has been moved in the repository
%                                 BrainardLabToolbox.

%% Set parameters.
arguments
    calObj
    bgExcitations
    options.verbose (1,1) = true
end

%% Start over from here.
%
% You can print out the time spent for the process based on the verbose
% setting.
if (options.verbose)
    tic;
    fprintf('Lookup table exhaustive method, setting up lookup table\n')
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

% Convert integers to 0-1 reals, quantized.
ptCldSettingsCal = IntegersToSettings(ptCldIntegersCal,'nInputLevels',screenNInputLevels);

% Get LMS excitations for each triplet of screen settings, and build a
% point cloud object from these.
ptCldExcitationsCal = SettingsToSensor(calObj,ptCldSettingsCal);
ptCldContrastCal = ExcitationsToContrast(ptCldExcitationsCal,bgExcitations);

% Force point cloud setup by finding one nearest neighbor. This is slow,
% but once it is done subsequent calls are considerably faster.
% findNearestNeighbors(ptCld,[0 0 0],1);
if (options.verbose)
    toc;
end

end