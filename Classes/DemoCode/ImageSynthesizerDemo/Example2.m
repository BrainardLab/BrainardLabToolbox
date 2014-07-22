% Function to demonstrate how to use the PartitiveImageSynthesizer class
% which mutates the chromaticity of an image region using partitive image
% mixing of a set of basis images. This function also demonstrates how to
% use the helper classes associated with the PartitiveImageSynthesizer class
% namely the MutationTarget, and the RegionOfInterest class.
%
% 6/13/2013  npc  Wrote it.
%

function Example2

	clc; clear classes; clear all;

	% Directory of LMS cone images
	imageDirectory = '/Users/Shared/Matlab/Toolboxes/Classes-Dev/DemoCode/ImageSynthesizerDemo/BasisImagesRGB';

	% Filenames for left display basis cone images
	basisImageFileNamesForFrontLeftDisplay = { ...
			'Trial1NCT1Basis1L-UncorrRGB.mat', ...
	        'Trial1NCT1Basis2L-UncorrRGB.mat', ...
	        'Trial1NCT1Basis3L-UncorrRGB.mat', ...
	        'Trial1NCT1Basis4L-UncorrRGB.mat'...
	        };

	% Filenames for right display basis cone images
	basisImageFileNamesForFrontRightDisplay = { ...
			'Trial1NCT1Basis1R-UncorrRGB.mat', ...
	        'Trial1NCT1Basis2R-UncorrRGB.mat', ...
	        'Trial1NCT1Basis3R-UncorrRGB.mat', ...
	        'Trial1NCT1Basis4R-UncorrRGB.mat'...
	        };

	% FLicker basis images to check for artifacts, such as luminance shifts, etc.
	% LoadCalibrationFiles();
	% FlickerBasisImages(imageDirectory, basisImageFileNamesForFrontLeftDisplay);

	% Next, lets initialize our PartitiveImageSynthesizer object by passing the
	% directory of the basis images and their filesnames for each display position
	imageSynthesizer = PartitiveImageSynthesizer( 'imageDir',    imageDirectory , ...
							'basisImageFileNamesFrontLeftDisplay',  basisImageFileNamesForFrontLeftDisplay, ...
							'basisImageFileNamesFrontRightDisplay', basisImageFileNamesForFrontRightDisplay ...
							);

	% Generate mutation target for the upper button. 
    % Make sure that each mutation target has a unique name.
    showBordersFlag = true;
    showInsidesFlag = false;
    [imageSynthesizer.imageWidth, imageSynthesizer.imageHeight]
	mutationTarget1 = generateMutationTarget1(imageSynthesizer.imageWidth, imageSynthesizer.imageHeight, 'Upper Button Target', showBordersFlag, showInsidesFlag);
	% If we had more that one mutation targets we generate them hew
	mutationTarget2 = generateMutationTarget2(imageSynthesizer.imageWidth, imageSynthesizer.imageHeight, 'Upper2 Button Target', showBordersFlag, showInsidesFlag);
    
	% Now pass a cell array with all mutation targets to the imageSynthesizer
	imageSynthesizer.mutationTargets = {mutationTarget1, mutationTarget2};

 	% Tests
    sensorActivationMap = containers.Map();
    sensorActivationMap(mutationTarget1.name) = [1 1 1];
    sensorActivationMap(mutationTarget2.name) = [0 1 1];
    mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(sensorActivationMap);
	DisplayImages(mutatedImages);
    Speak('White test.', 'Alex');
    
    pause;
    
	while(1)
		% Set the desired chroma vector for any mutation target we want.
		% In this example, we only have one target.
		sensorActivationMap = containers.Map();
        sensorActivationMap(mutationTarget1.name) = LinearRGBtoLMS(rand(1,3));
        sensorActivationMap(mutationTarget2.name) = [1 1 1];
        tic
		mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(sensorActivationMap);
		fprintf('Image synthesis took %2.2f seconds', toc);
		DisplayImages(mutatedImages);
        Speak('Random test.', 'Alex');
	end

end


function DisplayImages(mutatedImages)
	global SpectralDataStruct

    LoadCalibrationFiles();
    
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


function target = generateMutationTarget1(imageWidth, imageHeight, name, showBordersFlag, showInsidesFlag)
	% Specify the display position with respect to which all mutation Targets are specified
	% Here we are specifying everything in the frontLeftDisplay images
	sourceDisplayPos = MutationTarget.frontLeftDisplay;

	% Define the region over which we will sample chromaticity
	% This below specification is for the upper button
	sourceChromaROI = RegionOfInterest('name', 'chroma ROI for mutation target 1');
	sourceChromaROI.shape  = RegionOfInterest.Elliptical;
	sourceChromaROI.xo 	   = 590;
	sourceChromaROI.yo 	   = 474;
	sourceChromaROI.width  = 35;
	sourceChromaROI.height = 60;
	sourceChromaROI.rotation    = -35;
	sourceChromaROI.imageWidth  = imageWidth;
	sourceChromaROI.imageHeight = imageHeight;

	% Specify the source mask. This again is for the upper button
	sourceMask = RegionOfInterest('name', 'mask for mutation target 1');
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
	destMask_FrontLeftDisplay.name = 'destination mask for mutation target 1 - left screen';


	destMask_FrontRightDisplay = sourceMask;
	destMask_FrontRightDisplay.name = 'destination mask for mutation target 1 - right screen';
	destMask_FrontRightDisplay.xo  	= 400;


	% Now that we have specified the source chroma ROI and the source / destination masks
	% for both screens let's combine all this information in a MutationTarget object
	target = MutationTarget( 'name', name, ...
							'sourceDisplayPos', sourceDisplayPos, ...
	 						'sourceChromaROI',  sourceChromaROI, ...
	 						'sourceMask',  sourceMask, ...
	 						'sourceMaskRampSize', 0, ...
	 						'destMask_FrontLeftDisplay', destMask_FrontLeftDisplay, ...
	 						'destMask_FrontRightDisplay', destMask_FrontRightDisplay, ...
	 						'showBorders', showBordersFlag, ...
                            'showInsides', showInsidesFlag ...
	 						);
end


function target = generateMutationTarget2(imageWidth, imageHeight, name, showBordersFlag, showInsidesFlag)
	% Specify the display position with respect to which all mutation Targets are specified
	% Here we are specifying everything in the frontLeftDisplay images
	sourceDisplayPos = MutationTarget.frontLeftDisplay;

	% Define the region over which we will sample chromaticity
	% This below specification is for the upper button
	sourceChromaROI = RegionOfInterest('name', 'chroma ROI for mutation target 2');
	sourceChromaROI.shape  = RegionOfInterest.Elliptical;
	sourceChromaROI.xo 	   = 590-100;
	sourceChromaROI.yo 	   = 474-200;
	sourceChromaROI.width  = 35;
	sourceChromaROI.height = 60;
	sourceChromaROI.rotation    = -35;
	sourceChromaROI.imageWidth  = imageWidth;
	sourceChromaROI.imageHeight = imageHeight;

	% Specify the source mask. This again is for the upper button
	sourceMask = RegionOfInterest('name', 'mask for mutation target 2');
	sourceMask.shape 	= RegionOfInterest.Rectangular;
	sourceMask.xo  		= 593-100;
	sourceMask.yo  		= 472-200;
	sourceMask.width  	= 200;
	sourceMask.height 	= 200;
	sourceMask.rotation = 0;
	sourceMask.imageWidth  = imageWidth;
	sourceMask.imageHeight = imageHeight;

	% Specify the destination mask in the left and right displays (again for the upper button)
	destMask_FrontLeftDisplay = sourceMask;
	destMask_FrontLeftDisplay.name = 'destination mask for mutation target 2 - left screen';


	destMask_FrontRightDisplay = sourceMask;
	destMask_FrontRightDisplay.name = 'destination mask for mutation target 2 - right screen';
	destMask_FrontRightDisplay.xo  	= 400-100;


	% Now that we have specified the source chroma ROI and the source / destination masks
	% for both screens let's combine all this information in a MutationTarget object
	target = MutationTarget( 'name', name, ...
							'sourceDisplayPos', sourceDisplayPos, ...
	 						'sourceChromaROI',  sourceChromaROI, ...
	 						'sourceMask',  sourceMask, ...
	 						'sourceMaskRampSize', 0, ...
	 						'destMask_FrontLeftDisplay', destMask_FrontLeftDisplay, ...
	 						'destMask_FrontRightDisplay', destMask_FrontRightDisplay, ...
	 						'showBorders', showBordersFlag, ...
                            'showInsides', showInsidesFlag ...
	 						);
end




function LoadCalibrationFiles
	global SpectralDataStruct
	
	% Define spectral sampling to be used throughout
	SpectralDataStruct.S = [380 4 101];

	% Load Stockman-Sharpe 2-deg cone fundamentals
    load T_cones_ss2;
    SpectralDataStruct.T_cones = SplineCmf(S_cones_ss2, T_cones_ss2, SpectralDataStruct.S);
    clear 'T_cones_ss2', 'S_cones_ss2';

    cal = LoadCalFile('StereoLCDLeft');
    SpectralDataStruct.calLeft    = SetGammaMethod(cal, 0);
    SpectralDataStruct.calLeftLMS = SetSensorColorSpace(SpectralDataStruct.calLeft, SpectralDataStruct.T_cones, SpectralDataStruct.S);

	cal = LoadCalFile('StereoLCDRight');
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


