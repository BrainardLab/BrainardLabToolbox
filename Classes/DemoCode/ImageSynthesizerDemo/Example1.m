% Function to demonstrate how to use the PartitiveImageSynthesizer class
% which mutates the chromaticity of an image region using partitive image
% mixing of a set of basis images. This function also demonstrates how to
% use the helper classes associated with the PartitiveImageSynthesizer class
% namely the MutationTarget, and the RegionOfInterest class.
%
% 6/13/2013  npc  Wrote it.
%

function  Example1

	clc; clear classes; clear all;

	% Directory of LMS cone images
	imageDirectory = 'BasisImagesLMS';

	% Filenames for left display basis cone images
	basisImageFileNamesForFrontLeftDisplay = { ...
			'NCT1BasisRL-LMS.mat', ...
	        'NCT1BasisGL-LMS.mat', ...
	        'NCT1BasisBL-LMS.mat', ...
	        'NCT1BasisWL-LMS.mat'...
	        };

	% Filenames for right display basis cone images
	basisImageFileNamesForFrontRightDisplay = { ...
			'NCT1BasisRR-LMS.mat', ...
	        'NCT1BasisGR-LMS.mat', ...
	        'NCT1BasisBR-LMS.mat', ...
	        'NCT1BasisWR-LMS.mat'...
	        };

	
    calFileNames = {'StereoLCDLeft', 'StereoLCDRight'};
	LoadCalibrationFiles(calFileNames);
    
    % FLicker basis images to check for artifacts, such as luminance shifts, etc.
	%FlickerBasisImages(imageDirectory, basisImageFileNamesForFrontLeftDisplay);

	% Next, lets initialize our PartitiveImageSynthesizer object by passing the
	% directory of the basis images and their filesnames for each display position
    
	imageSynthesizer = PartitiveImageSynthesizer('imageDir',  imageDirectory , ...
							'basisImageFileNamesFrontLeftDisplay',  basisImageFileNamesForFrontLeftDisplay, ...
							'basisImageFileNamesFrontRightDisplay', basisImageFileNamesForFrontRightDisplay ...
							);

	% Generate mutation target for the upper button. 
    % Make sure that each mutation target has a unique name.
    showBordersFlag = true;
	upperButtonMutationTarget = generateMutationTargetForUpperButton(imageSynthesizer.imageWidth, imageSynthesizer.imageHeight, 'Upper Button Target', showBordersFlag);
	% If we had more that one mutation targets we generate them hew
	
	% Now pass a cell array with all mutation targets to the imageSynthesizer
	imageSynthesizer.mutationTargets = {upperButtonMutationTarget};

 	% Tests
    sensorActivationMap = containers.Map();
    sensorActivationMap(upperButtonMutationTarget.name) = LinearRGBtoLMS([1 0 0]);
    %profile on -timer real
    mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(sensorActivationMap);
    %profile viewer
    %pause;
    
	DisplayImages(mutatedImages);
    Speak('Red test.', 'Alex');
    
    sensorActivationMap = containers.Map();
    sensorActivationMap(upperButtonMutationTarget.name) = LinearRGBtoLMS([0 1 0]);
    mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(sensorActivationMap);
	DisplayImages(mutatedImages);
    Speak('Green test.', 'Alex');
    
    sensorActivationMap = containers.Map();
    sensorActivationMap(upperButtonMutationTarget.name) = LinearRGBtoLMS([0 0 1]);
    mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(sensorActivationMap);
	DisplayImages(mutatedImages);
    Speak('Blue test.', 'Alex');
    
    sensorActivationMap = containers.Map();
    sensorActivationMap(upperButtonMutationTarget.name) = LinearRGBtoLMS([0 0 0]);
    mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(sensorActivationMap);
	DisplayImages(mutatedImages);
    Speak('Black test.', 'Alex');
    
    sensorActivationMap = containers.Map();
    sensorActivationMap(upperButtonMutationTarget.name) = LinearRGBtoLMS([1 1 1]);
    mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(sensorActivationMap);
	DisplayImages(mutatedImages);
    Speak('White test.', 'Alex');
    
	while(1)
		% Set the desired chroma vector for any mutation target we want.
		% In this example, we only have one target.
		sensorActivationMap = containers.Map();
        sensorActivationMap(upperButtonMutationTarget.name) = LinearRGBtoLMS(rand(1,3));
        tic
		mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(sensorActivationMap);
		fprintf('Image synthesis took %2.2f seconds', toc);
		DisplayImages(mutatedImages);
        Speak('Random test.', 'Alex');
	end

end


function DisplayImages(mutatedImages)
	global SpectralDataStruct

    leftImage  = mutatedImages{MutationTarget.frontLeftDisplay}.imageData;
	rightImage = mutatedImages{MutationTarget.frontRightDisplay}.imageData;

	[leftImageCalFormat, ncols, mrows]  = ImageToCalFormat(leftImage);
	[rightImageCalFormat, ncols, mrows] = ImageToCalFormat(rightImage);

	% Convert to linear rgb primary representation from LMS representation
    leftImageRGBCalFormat  = SensorToPrimary(SpectralDataStruct.calLeftLMS, leftImageCalFormat);
    rightImageRGBCalFormat = SensorToPrimary(SpectralDataStruct.calRightLMS, rightImageCalFormat);

    % To monitor settings
    leftImageRGBCalFormat   = PrimaryToSettings(SpectralDataStruct.calLeft, leftImageRGBCalFormat);
    rightImageRGBCalFormat  = PrimaryToSettings(SpectralDataStruct.calRight, rightImageRGBCalFormat);

    leftRGB  = CalFormatToImage(leftImageRGBCalFormat, ncols, mrows);
    rightRGB = CalFormatToImage(rightImageRGBCalFormat, ncols, mrows);

    h = figure(100);
	set(h, 'position', [100, 300 2500*0.5 1250*0.5]);
	clf;

	displayIndex = 1;
    subplot('Position', [0.01 + (displayIndex-1)*0.49 0.05  0.488 0.9]);
    imshow(leftRGB)

    displayIndex = 2;
    subplot('Position', [0.01 + (displayIndex-1)*0.49 0.05  0.488 0.9]);
    imshow(rightRGB)
    drawnow;
end


function upperButtonTarget = generateMutationTargetForUpperButton(imageWidth, imageHeight, name, showBordersFlag)
	% Specify the display position with respect to which all mutation Targets are specified
	% Here we are specifying everything in the frontLeftDisplay images
	sourceDisplayPos = MutationTarget.frontLeftDisplay;

	% Define the region over which we will sample chromaticity
	% This below specification is for the upper button
	sourceChromaROI = RegionOfInterest('name', 'chroma ROI for upper button');
	sourceChromaROI.shape  = RegionOfInterest.Elliptical;
	sourceChromaROI.xo 	   = 590;
	sourceChromaROI.yo 	   = 474;
	sourceChromaROI.width  = 35;
	sourceChromaROI.height = 60;
	sourceChromaROI.rotation    = -35;
	sourceChromaROI.imageWidth  = imageWidth;
	sourceChromaROI.imageHeight = imageHeight;

	% Specify the source mask. This again is for the upper button
	sourceMask = RegionOfInterest('name', 'mask for upper button');
	sourceMask.shape 	= RegionOfInterest.Rectangular;
	sourceMask.xo  		= 593;
	sourceMask.yo  		= 472;
	sourceMask.width  	= 200;
	sourceMask.height 	= 200;
	sourceMask.rotation = 0;
	sourceMask.imageWidth  = imageWidth;
	sourceMask.imageHeight = imageHeight;

	% Specify the destination mask in the left and right displays (again for the upper button)
	destMask_FrontLeftDisplay = sourceMask;
	destMask_FrontLeftDisplay.name = 'destination mask for upper button - left screen';


	destMask_FrontRightDisplay = sourceMask;
	destMask_FrontRightDisplay.name = 'destination mask for upper button - right screen';
	destMask_FrontRightDisplay.xo  	= 400;


	% Now that we have specified the source chroma ROI and the source / destination masks
	% for both screens let's combine all this information in a MutationTarget object
	upperButtonTarget = MutationTarget( 'name', name, ...
							'sourceDisplayPos', sourceDisplayPos, ...
	 						'sourceChromaROI',  sourceChromaROI, ...
	 						'sourceMask',  sourceMask, ...
	 						'sourceMaskRampSize', 0, ...
	 						'destMask_FrontLeftDisplay', destMask_FrontLeftDisplay, ...
	 						'destMask_FrontRightDisplay', destMask_FrontRightDisplay, ...
	 						'showBorders', showBordersFlag ...
	 						);
end

    
function LoadCalibrationFiles(calFileNames)
	global SpectralDataStruct
	
	% Define spectral sampling to be used throughout
	SpectralDataStruct.S = [380 4 101];

	% Load Stockman-Sharpe 2-deg cone fundamentals
    load T_cones_ss2;
    SpectralDataStruct.T_cones = SplineCmf(S_cones_ss2, T_cones_ss2, SpectralDataStruct.S);
    clear 'T_cones_ss2', 'S_cones_ss2';

    cal = LoadCalFile(calFileNames{1});
    SpectralDataStruct.calLeft    = SetGammaMethod(cal, 0);
    SpectralDataStruct.calLeftLMS = SetSensorColorSpace(SpectralDataStruct.calLeft, SpectralDataStruct.T_cones, SpectralDataStruct.S);

	cal = LoadCalFile(calFileNames{2});
    SpectralDataStruct.calRight    = SetGammaMethod(cal, 0);
    SpectralDataStruct.calRightLMS = SetSensorColorSpace(SpectralDataStruct.calRight, SpectralDataStruct.T_cones, SpectralDataStruct.S);
end


function LMS = LinearRGBtoLMS(RGB)
	global SpectralDataStruct

    LMS = PrimaryToSensor(SpectralDataStruct.calLeftLMS, reshape(RGB, [3 1]));
end


function FlickerBasisImages(imageDirectory, basisImageFileNames)
	global SpectralDataStruct

    for basisImageIndex = 1:numel(basisImageFileNames)
		filename = fullfile(imageDirectory, basisImageFileNames{basisImageIndex});
		% import sensor image
		sensorImageVariable = whos('-file', filename);
		load(filename);
		eval(sprintf('basisImages{basisImageIndex}.imageData = %s;',sensorImageVariable.name));

		% To cal format for efficient computations
		[calFormatLMS, ncols, mrows]  = ImageToCalFormat(basisImages{basisImageIndex}.imageData);
		% Convert to linear rgb primary representation from LMS representation
    	calFormatRGB  = SensorToPrimary(SpectralDataStruct.calLeftLMS, calFormatLMS);
    	% To monitor settings
    	calFormatRGB  = PrimaryToSettings(SpectralDataStruct.calLeft, calFormatRGB);
    	% Back to image format
    	basisImages{basisImageIndex}.imageData = CalFormatToImage(calFormatRGB, ncols, mrows);
	end

	h = figure(1);
	clf;
	for k = 1:10
		for basisImageIndex = 1:numel(basisImageFileNames)
			imshow(basisImages{basisImageIndex}.imageData);
			drawnow;
		end
	end
	set(h, 'Position', [100 100 1000 760]);
	drawnow;

end


