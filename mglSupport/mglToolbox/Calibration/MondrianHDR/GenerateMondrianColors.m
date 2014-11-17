function params = GenerateMondrianColors(params, HDRCal)
% params = GenerateMondrianColors(params)
%
% Description:
% Generates the Mondrian colors used by HDRAna and Ana's HDR calibration
% routines.
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
% 9/21/2010 cgb     Added testWhite condition for checking the white condition with 30:1 range. 
% 11/6/2010 cgb     Added new condition. 
% 11/14/2010 ar     Added new conditions (gray30, white30). 
% 04/18/2011 ar     Added a hack to keep the targets linearly spaced. 

% Load in calibration files and initialize
S = [380 4 101];
load('T_xyz1931');
T_sensor = 683*SplineCmf(S_xyz1931, T_xyz1931, S);

% Load and check calibration
HDRCal = InitializeHDRCalStructure(HDRCal,T_sensor,S,params.settingsMethod);


% % Report ambient and max chromaticity and luminance
% minxyY = XYZToxyY(HDRSettingsToSensorAcc(HDRCal, [0 0 0]', [0 0 0]'));
% maxxyY = XYZToxyY(HDRSettingsToSensorAcc(HDRCal, [1 1 1]', [1 1 1]'));


% Produce a set of target values that span the luminance range of
% the display at a specified chromaticity.

% Get XYZ values of the stimulus.
% turn these on only in calibration.
switch params.conditionName
    case {'full','settingsTestFull','white', 'settingsTestWhite', 'fullMeanPlus'}
        [theTargetSensorxyY, theTargetSensorXYZ] = HDRFindTargetStimuliAtChrom(HDRCal, ...
            [params.target_x, params.target_y], params.nTargets, [], [], params.luminanceHeadroom);
    case {'fullMeanMinus'}
        [theTargetSensorxyY, theTargetSensorXYZ] = HDRFindTargetStimuliAtChromMinus(HDRCal, ...
            [params.target_x, params.target_y], params.nTargets, [], [], params.luminanceHeadroom);
    case {'full30', 'white30', 'full30MeanPlus'}
        [theTargetSensorxyY, theTargetSensorXYZ] = HDRfull30FindTargetStimuliAtChrom(HDRCal, ...
            [params.target_x, params.target_y], params.nTargets, [], [], params.luminanceHeadroom);
    case {'full1000'}
        [theTargetSensorxyY, theTargetSensorXYZ] = HDR1000FindTargetStimuliAtChrom(HDRCal, ...
            [params.target_x, params.target_y], params.nTargets, [], [], params.luminanceHeadroom);
    case {'gray1000'}
        [theTargetSensorxyY, theTargetSensorXYZ] = HDRgray1000FindTargetStimuliAtChrom(HDRCal, ...
            [params.target_x, params.target_y], params.nTargets, [], [], params.luminanceHeadroom);
    case {'gray30', 'fullgray30', 'fullgray30MeanPlus'}
        [theTargetSensorxyY, theTargetSensorXYZ] = HDRgray30FindTargetStimuliAtChrom(HDRCal, ...
            [params.target_x, params.target_y], params.nTargets, [], [], params.luminanceHeadroom);
    case {'fullgray1000'}
        [theTargetSensorxyY, theTargetSensorXYZ] = HDRgray1000FindTargetStimuliAtChrom(HDRCal, ...
            [params.target_x, params.target_y], params.nTargets, [], [], params.luminanceHeadroom);
    otherwise
        error('Invalid condition name "%s".', params.conditionName);
end

% Change, if we are varying the mean. 

% if isfield(params,'varyMean')
%     firstxyY = theTargetSensorxyY;
% 	diffIndex = 1:22;
%     lumDiff = sin(pi*(diffIndex-1)/21);
%     lumDiff = [1 (1+ (0.8)*lumDiff) 1];
%     for i = 1:length(theTargetSensorxyY)
%         theTargetSensorxyY(3,i) = theTargetSensorxyY(3,i)*lumDiff(i);
%     end
%     theTargetSensorXYZ = xyYToXYZ(theTargetSensorxyY);
%     
% %     for i = 1:24
% %         percentIncrease(i) = (theTargetSensorxyY(3,i)'.*100/firstxyY(3,i)');  %#ok<SAGROW>
% %     end
% end

if isfield(params,'varyMean')
    switch (params.varyMean)
        case 1
            lumWeigth = [1 1 7 7 7 7 7 7 7 7 7 7 7 7 7 7 6 4.5 3.5 2.5 1.75 1.25 1 1];
        case 2
            % here I have to hard code the lowest two values to make them
            % equal to the lowest two values in the Plus condition.
            
            lumWeigth = [1 1 0.8 0.8 0.8 0.7 0.7 0.7 0.6 0.5 0.5 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.35 0.35 0.35 1 1];
    end
    for i = 1:length(theTargetSensorxyY)
        targetxyY = theTargetSensorxyY;% just make a copy to modify later. 
        theTargetSensorxyY(3,i) = theTargetSensorxyY(3,i)*lumWeigth(i);
    end
    theTargetSensorXYZ = xyYToXYZ(theTargetSensorxyY);
end



% For the 'settingsTest' conditions, we will specify the front and back RGB
% of surrounding squares instead of generating it based on the calibration
% file.
if ~isempty(strfind(params.conditionName, 'settingsTest'))
	params.theSurroundFrontRGB = [0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704;
		0.1212    0.0795    0.0704]';
	params.theSurroundBackRGB = [ 0.0023    0.0023    0.0023;
		0.0436    0.0436    0.0436;
		0.0723    0.0723    0.0723;
		0.0955    0.0955    0.0955;
		0.1174    0.1174    0.1174;
		0.1394    0.1394    0.1394;
		0.1620    0.1620    0.1620;
		0.1858    0.1858    0.1858;
		0.2111    0.2111    0.2111;
		0.2383    0.2383    0.2383;
		0.2675    0.2675    0.2675;
		0.2992    0.2992    0.2992;
		0.3336    0.3336    0.3336;
		0.3711    0.3711    0.3711;
		0.4119    0.4119    0.4119;
		0.4564    0.4564    0.4564;
		0.5049    0.5049    0.5049;
		0.5577    0.5577    0.5577;
		0.6153    0.6153    0.6153;
		0.6779    0.6779    0.6779;
		0.7460    0.7460    0.7460;
		0.8200    0.8200    0.8200;
		0.9009    0.9009    0.9009;
		0.9938    0.9938    0.9938]';
end

% Find HDR settings using HDRSensorToSettingsAcc function
[params.theBackRGB, params.theFrontRGB] = HDRSensorToSettingsAcc(HDRCal, theTargetSensorXYZ);

% Hack, to keep the target values linear. 

% if strcmp(params.conditionName, 'fullMeanPlus') || strcmp(params.conditionName, 'fullMeanMinus')
%     tests = [10.^linspace(log10(0.1220), log10(232.0872), 22)];
%     targetxyY(3,2:23) = tests;
%     targetXYZ = xyYToXYZ(targetxyY);
%     [params.targetBackRGB, params.targetFrontRGB] = HDRSensorToSettingsAcc(HDRCal, targetXYZ);
% end

% The number of trials per block will be equal to the number of center
% colors we're testing.
switch params.conditionName
	case {'full','full30', 'fullgray30', 'fullgray1000','full1000', 'white30', 'gray30', 'fullgray30MeanPlus', 'full30MeanPlus', 'fullMeanPlus', 'fullMeanMinus'}
		params.trialsPerBlock = size(params.theBackRGB, 2);
		params.trialIndices = 1:params.trialsPerBlock;
	
	case {'white'}
		params.trialsPerBlock = 18;
		params.trialIndices = [1, 8:24];

end

% Define the Mondrian colors for each particular case.  These colors will
% remained fixed throught the experiment except the middle square which
% will change each trial.
switch params.conditionName
	% Full
	case {'full', 'full30', 'full1000', 'fullgray30', 'fullgray1000', 'settingsTestFull', 'fullgray30MeanPlus', 'full30MeanPlus', 'fullMeanPlus', 'fullMeanMinus'}
		
% Old order of indices for ExperimentSet 1 and 2
% 		indices = [7 18 1 19 5 ...
% 			23 6 13 15 9 ...
% 			4 22 1 16 2 ...
% 			10 17 3 8 24 ...
% 			12 21 14 20 11];

% New order of indices for Experiment Set 3
		indices = [9 21 7 18 2 ...
			24 10 20 15 8 ...
			23 5 1 19 1 ...
			4 17 6 12 16 ...
			22 3 11 14 13];		
		
		% White
	case {'white', 'settingsTestWhite', 'white30', 'gray30'}
		indices = [24 24 24 24 24 ...
			24 24 24 24 24 ...
			24 24 1 24 24  ...
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
