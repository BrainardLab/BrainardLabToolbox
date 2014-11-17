function params = GenerateMondrianColorsCal(params, HDRCal)
% params = GenerateMondrianColorsCal(params)
%
% Description:
% This is a version fo GenerateMondrianColorsCal that is only meant to be used in the calibration routine.
% It generates the Mondrian colors that are going to be used in the
% calibration program for yoked measurements routine. 
%
% Input:
% params (struct) - Params data structure preloaded with values from a
%   config file such as HDRAna's full.cfg or white.cfg.
% HDRCal (struct) - Contains the calibration data for both the front
%	and back screens.
%
% Output:
% params (struct) - Updated params data structure with the generated
%   Mondrian colors.

% 7/12/2010 cgb     Pulled it out from HDRAnaDriver. 
% 7/17/2010  ar     Created a version for the calibration routine. 

% Load in calibration files and initialize
S = [380 4 101];
load('T_xyz1931');
T_sensor = 683*SplineCmf(S_xyz1931, T_xyz1931, S);

HDRCal = InitializeHDRCalStructure(HDRCal,T_sensor,S,params.settingsMethod);

% % Report ambient and max chromaticity and luminance
% minxyY = XYZToxyY(HDRSettingsToSensorAcc(HDRCal, [0 0 0]', [0 0 0]'));
% maxxyY = XYZToxyY(HDRSettingsToSensorAcc(HDRCal, [1 1 1]', [1 1 1]'));


% Produce a set of target values that span the luminance range of
% the display at a specified chromaticity.

% Get XYZ values of the stimulus.
% 
[~, maxLum] = HDRFindMinMaxLumAtChrom(HDRCal, [params.target_x, params.target_y]');
cal.describe.yoked_minLum = 0;
cal.describe.yoked_maxLum = 2*maxLum;
[~, theTargetSensorXYZ] = HDRFindTargetStimuliAtChrom(HDRCal, ...
	[params.target_x, params.target_y], params.nTargets, cal.describe.yoked_minLum,cal.describe.yoked_maxLum,1);


% Find HDR settings using HDRSensorToSettingsAcc function
[params.theBackRGB, params.theFrontRGB] = HDRSensorToSettingsAcc(HDRCal, theTargetSensorXYZ);

% The number of trials per block will be equal to the number of center
% colors we're testing.
params.trialsPerBlock = size(params.theBackRGB, 2);

% Define the Mondrian colors for each particular case.  These colors will
% remained fixed throught the experiment except the middle square which
% will change each trial.
switch params.conditionName
	% Full
    case {'full','full30', 'settingsTestFull', 'fullgray30','fullgray1000', 'fullMeanPlus', 'full30MeanPlus', 'fullgray30MeanPlus'}
% 		indices = [17 10 19 3 4 ...
% 				   5 11 6 21 9 ...
% 				   13 22 1 18 1 ...
% 				   20 12 23 8 7 ...
% 				   24 14 15 2 16];


% New arangement. 
indices = [9 21 7 18 2 ...
			24 10 20 15 8 ...
			23 5 1 19 1 ...
			4 17 6 12 16 ...
			22 3 11 14 13];		

		
	% White
    case {'white', 'settingsTestWhite', 'gray30'}
		indices = [24 24 24 24 24 ...
				   24 24 24 24 24 ...
				   24 24 1 24 24 ...
				   24 24 24 24 24 ...
				   24 24 24 24 24];
		
	% Error if we haven't defined a case for the requested condition.
	otherwise
		error('Invalid condition name "%s".', params.conditionName);
end

% For 'settingsTest' conditions, we use the RGB values specified for the
% surround to make up the Mondrian instead of the set of values for the
% center square.
if ~isempty(strfind(params.conditionName, 'settingsTest'))
	mondrianFront = params.theSurroundFrontRGB(:, indices)';
	mondrianBack = params.theSurroundBackRGB(:, indices)';
else
	mondrianFront = params.theFrontRGB(:, indices)';
	mondrianBack = params.theBackRGB(:, indices)';
end

% Reshape our list of Mondrian colors into a 5x5x3 matrix.
params.backRGBHDR = reshape(mondrianBack, 5, 5, 3);
params.frontRGBHDR = reshape(mondrianFront, 5, 5, 3);
