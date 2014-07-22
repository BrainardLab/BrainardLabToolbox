function params = CubeAdjustmentDriver(exp)
% function params = CubeAdjustmentDriver(exp)
% Experimental code for adjustment condition.

% 06/17/2013    ar Adapted it from the selection code and using new class

% Initialize GLWindows;
clear Classes; UseClassesDev;
ClockRandSeed;

% get the config file for no change condition
cfgFile = ConfigFile(exp.configFileName);
params = convertToStruct(cfgFile);
imageDirectory = '/Users1/Matlab/Experiments/CubeConstancy/BasisImagesPrimaries';
% compute some common values for image presentation
widthToHeightRatio     = params.imageSizePx(1)/params.imageSizePx(2);
params.imageSizeCm(1)  = NaN;
params.imageSizeCm(2)  = ImageSizeFromAngle(params.fov, params.cubeDistance); % this is image height
params.imageSizeCm(1)  = params.imageSizeCm(2)*widthToHeightRatio;

stereoCalibrationInfo = specifyStereoCalibration;

if strcmp(exp.subject, 'test')
    performStringentCalibrationChecks = false;
else
    performStringentCalibrationChecks = true;
end

%% InitilizeCalibration
% Load color matching functions.
load T_cones_ss2
load T_xyz1931
S = [400, 10, 31];
T_sensorXYZ = 683*SplineCmf(S_xyz1931,T_xyz1931,S);

% set the calibration file for converting left image (via LMS)
calLeft = LoadCalFile('StereoLCDLeft');
calLeft = SetGammaMethod(calLeft, 0);
calLeftLMS = SetSensorColorSpace(calLeft, T_cones_ss2,  S_cones_ss2);
calLeftXYZ = SetSensorColorSpace(calLeft, T_sensorXYZ,  S);

% set the calibration file for converting right image (via LMS)
calRight = LoadCalFile('StereoLCDRight');
calRight = SetGammaMethod(calRight, 0);
calRightLMS = SetSensorColorSpace(calRight, T_cones_ss2,  S_cones_ss2);
calRightXYZ = SetSensorColorSpace(calRight, T_sensorXYZ,  S);

%% this should work: which block is the observer running (withouth
% explicitly specifying).

params.whichBlock = 1;

showBordersFlag = true;
[params.imageSizePx(1) params.imageSizePx(2)]

try
    stereoView = [];
    % Construct the StereoView object
    instanceName = 'stereoView';
    stereoView = StereoViewController( instanceName, ...
        stereoCalibrationInfo, ...
        performStringentCalibrationChecks, ...
        'beVerbose', true);
    if (stereoView.isInitialized == false)
        disp('The StereoView object failed to initialize. Exiting now ... ');
        resetEnvironment(exp.baseDir);
        return;
    end
    
    % specify the conditions for this experiment.
    if params.conditionCode == 1
        trialList = {'NCT1', 'NCT2', 'NCT3', 'NCT4'};
    elseif params.conditionCode == 2
        trialList = {'CYT1', 'CYT2', 'CYT3', 'CYT4', 'CBT1', 'CBT2', 'CBT3', 'CBT4'};
    end
    
    nTrials = length(trialList);
    
    %params.orderIndices = Shuffle(1:nTrials);
     
    params.orderIndices = (1:nTrials);
     
    for trialIndex = 1 %:length(params.orderIndices);
            
            % configure stereo pair.
            thisTrialIndex = params.orderIndices(trialIndex); % read our the real trial number
            stimulusNameRoot = trialList{thisTrialIndex}; % I need this. 
            
            % Filenames for left display basis cone images
            basisImageFileNamesForFrontLeftDisplay = { ...
                ['Trial' num2str(params.whichBlock) stimulusNameRoot 'Basis1L-UncorrRGB.mat'], ...
                ['Trial' num2str(params.whichBlock) stimulusNameRoot 'Basis2L-UncorrRGB.mat'], ...
                ['Trial' num2str(params.whichBlock) stimulusNameRoot 'Basis3L-UncorrRGB.mat'], ...
                ['Trial' num2str(params.whichBlock) stimulusNameRoot 'Basis4L-UncorrRGB.mat']...
                };
            
            % Filenames for right display basis cone images
            basisImageFileNamesForFrontRightDisplay = { ...
                ['Trial' num2str(params.whichBlock) stimulusNameRoot 'Basis1R-UncorrRGB.mat'], ...
                ['Trial' num2str(params.whichBlock) stimulusNameRoot 'Basis2R-UncorrRGB.mat'], ...
                ['Trial' num2str(params.whichBlock) stimulusNameRoot 'Basis3R-UncorrRGB.mat'], ...
                ['Trial' num2str(params.whichBlock) stimulusNameRoot 'Basis4R-UncorrRGB.mat']...
                };
            
            
            % Next, lets initialize our PartitiveImageSynthesizer object by passing the
            % directory of the basis images and their filesnames for each display position
            imageSynthesizer = PartitiveImageSynthesizer( 'imageDir',    imageDirectory , ...
                'basisImageFileNamesFrontLeftDisplay',  basisImageFileNamesForFrontLeftDisplay, ...
                'basisImageFileNamesFrontRightDisplay', basisImageFileNamesForFrontRightDisplay ...
                );
            upperButtonMutationTarget = generateMutationTargetForUpperButton(imageSynthesizer.imageWidth, imageSynthesizer.imageHeight, 'Upper Button Target', false);
            %lowerButtonMutationTarget = generateMutationTargetForLowerButton(imageSynthesizer.imageWidth, imageSynthesizer.imageHeight, 'Lower Button Target', showBordersFlag);
            
            upperButton = true;
            % figure out which button.
            % Set the mutation target, true/false.
            if (upperButton)
                imageSynthesizer.mutationTargets = {upperButtonMutationTarget};
            else
                imageSynthesizer.mutationTargets = {lowerButtonMutationTarget};
            end
            
            
            % Set button color to white or black
            desiredSensor = containers.Map();
            
            randomStartPoint = round(rand(1)); 
            params.trial(thisTrialIndex).startPoint = randomStartPoint; 
            
            if randomStartPoint == 0
                desiredSensor(imageSynthesizer.mutationTargets{1}.name) = [1.0 0.1 0.1];
            elseif randomStartPoint == 1
                desiredSensor(imageSynthesizer.mutationTargets{1}.name) = [1.0 0.1 0.1];
            end
            mutatedImages = imageSynthesizer.setMutationTargetSensorActivations(desiredSensor);
            leftImage  = mutatedImages{MutationTarget.frontLeftDisplay}.imageData;
            rightImage = mutatedImages{MutationTarget.frontRightDisplay}.imageData;
            rightImage(rightImage<0)=0; 
            % truncate and correct the leftImage and the right image
            leftImage(leftImage<0)=0; 
            leftImage(leftImage>1)=1; 
            leftImage = sqrt(leftImage); 
            %[min(min(min(leftImage))) max(max(max(leftImage)))] 
            
            
            rightImage(rightImage>1)=1; 
            rightImage = sqrt(rightImage); 
            
            
            % fix this
            stereoPair = configureStereoPairStimulus(leftImage, rightImage, params);
            stereoView.setStereoPair(stereoPair);
            stereoView.showStimulus();
            pause; 
%             while (obeserve__adjustingcolor)
%                 % observer sets button color
%                 chromaMap = containers.Map();
%                 chromaMap(mutationTarget.name) = LinearRGBtoLMS([color from observer]);
%                 % get images back
%                 mutatedImages = imageSynthesizer.setMutationTargetChroma(chromaMap);
%                 leftImage  = mutatedImages{MutationTarget.frontLeftDisplay}.imageData;
%                 rightImage = mutatedImages{MutationTarget.frontRightDisplay}.imageData;
%                 
%                 settingsLeftImage = RGBlinear to settings (leftImage)
%                 settingsRighttImage = RGBlinear to settings (righttImage)
%                 
%                 % probably fix this. 
%                 stereoPair = configureStereoPairStimulus(stimulusNameRoot, params);
%                 stereoView.setStereoPair(stereoPair);
%             end
            
        end
    
    % Run the experiment
    % End experiment.
    stereoView.shutdown;
    resetEnvironment(exp.baseDir);
catch e
    if (~isempty(stereoView))
        if (stereoView.isInitialized)
            stereoView.shutdown;
        end
    end
    resetEnvironment(exp.baseDir);
    %sendmail('radonjic@sas.upenn.edu', 'Cube Constancy Problems', 'Some problem with the code.');
    rethrow(e);
end
end


function mutationTargetOBJ = generateMutationTargetForUpperButton(imageWidth, imageHeight, name, showBordersFlag)

% Set the display position with respect to which all mutation Targets are specified
% Here we are specifying everything in the frontLeftDisplay
sourceDisplayPos = MutationTarget.frontLeftDisplay;


% Define the region over which we will sample chromaticity
% The specification below is for the upper button
sourceChromaROI = RegionOfInterest('name', 'chroma ROI for upper button');
sourceChromaROI.shape  = RegionOfInterest.Elliptical;
sourceChromaROI.xo     = 590;
sourceChromaROI.yo     = 474;
sourceChromaROI.width  = 35;
sourceChromaROI.height = 60;
sourceChromaROI.rotation    = -35;
sourceChromaROI.imageWidth  = imageWidth;
sourceChromaROI.imageHeight = imageHeight;


% Specify the source mask. This again is for the upper button
sourceMask = RegionOfInterest('name', 'mask for upper button');
sourceMask.shape    = RegionOfInterest.Rectangular;
sourceMask.xo       = 593;
sourceMask.yo       = 472;
sourceMask.width    = 200;
sourceMask.height   = 200;
sourceMask.rotation = 0;
sourceMask.imageWidth  = imageWidth;
sourceMask.imageHeight = imageHeight;


% Specify the destination mask in the left display (again for the upper button)
destMask_FrontLeftDisplay = sourceMask;
destMask_FrontLeftDisplay.name = 'destination mask for upper button - left screen';



% Specify the destination mask in the  right display (again for the upper button)
destMask_FrontRightDisplay = sourceMask;
destMask_FrontRightDisplay.name = 'destination mask for upper button - right screen';
destMask_FrontRightDisplay.xo   = 400;




% Now that we have specified the source chroma ROI and the source / destination masks
% for both screens let's combine all this information in a MutationTarget object
mutationTargetOBJ = MutationTarget( 'name', name, ...
    'sourceDisplayPos', sourceDisplayPos, ...
    'sourceChromaROI',  sourceChromaROI, ...
    'sourceMask',  sourceMask, ...
    'sourceMaskRampSize', 0, ...
    'destMask_FrontLeftDisplay', destMask_FrontLeftDisplay, ...
    'destMask_FrontRightDisplay', destMask_FrontRightDisplay, ...
    'showBorders', showBordersFlag ...
    );
end

function mutationTargetOBJ = generateMutationTargetForLowerButton(imageWidth, imageHeight, name, showBordersFlag)

% Set the display position with respect to which all mutation Targets are specified
% Here we are specifying everything in the frontLeftDisplay
sourceDisplayPos = MutationTarget.frontLeftDisplay;


% Define the region over which we will sample chromaticity
% The specification below is for the upper button
sourceChromaROI = RegionOfInterest('name', 'chroma ROI for upper button');
sourceChromaROI.shape  = RegionOfInterest.Elliptical;
sourceChromaROI.xo     = 590;
sourceChromaROI.yo     = 474;
sourceChromaROI.width  = 35;
sourceChromaROI.height = 60;
sourceChromaROI.rotation    = -35;
sourceChromaROI.imageWidth  = imageWidth;
sourceChromaROI.imageHeight = imageHeight;


% Specify the source mask. This again is for the upper button
sourceMask = RegionOfInterest('name', 'mask for upper button');
sourceMask.shape    = RegionOfInterest.Rectangular;
sourceMask.xo       = 593;
sourceMask.yo       = 472;
sourceMask.width    = 200;
sourceMask.height   = 200;
sourceMask.rotation = 0;
sourceMask.imageWidth  = imageWidth;
sourceMask.imageHeight = imageHeight;


% Specify the destination mask in the left display (again for the upper button)
destMask_FrontLeftDisplay = sourceMask;
destMask_FrontLeftDisplay.name = 'destination mask for upper button - left screen';



% Specify the destination mask in the  right display (again for the upper button)
destMask_FrontRightDisplay = sourceMask;
destMask_FrontRightDisplay.name = 'destination mask for upper button - right screen';
destMask_FrontRightDisplay.xo   = 400;




% Now that we have specified the source chroma ROI and the source / destination masks
% for both screens let's combine all this information in a MutationTarget object
mutationTargetOBJ = MutationTarget( 'name', name, ...
    'sourceDisplayPos', sourceDisplayPos, ...
    'sourceChromaROI',  sourceChromaROI, ...
    'sourceMask',  sourceMask, ...
    'sourceMaskRampSize', 0, ...
    'destMask_FrontLeftDisplay', destMask_FrontLeftDisplay, ...
    'destMask_FrontRightDisplay', destMask_FrontRightDisplay, ...
    'showBorders', showBordersFlag ...
    );
end


function stereoPair = configureStereoPairStimulus(leftImage, rightImage, params)
% Configure all aspects of the stereo pair stimulus

stereoPair.stimulusSource = 'matrix';
%stimulusName = {['Trial' num2str() stimulusNameRoot 'L-UncorrRGB.mat'], ['Trial' num2str() stimulusNameRoot 'R-UncorrRGB.mat']};

%load(stimulusName{1}); % left image
stereoPair.imageData.left = flipdim(leftImage,1);

%load(stimulusName{2}); % right image. 
stereoPair.imageData.right = flipdim(rightImage,1);

imageInfo.Width = params.imageSizePx(1);
imageInfo.Height = params.imageSizePx(2);

% move all this to params - config file.
targets.rightScreen.XcoordsPxls = params.targetX;
targets.rightScreen.YcoordsPxls = params.targetY;
targets.rightScreen.maximumAcceptableDistancePxls = params.targetDistance;

stereoPair.imageSize(1)  = params.imageSizeCm(1); % this is image width
stereoPair.imageSize(2)  = params.imageSizeCm(2); 
stereoPair.imagePosition = params.imagePosition; 

% % Transform target coords into screen centimeters
[targets.rightScreen.XcoordsCm, targets.rightScreen.YcoordsCm] = ...
    StereoViewController.imagePixelsToScreenCentiMeters(targets.rightScreen.XcoordsPxls, targets.rightScreen.YcoordsPxls, params.imageSizePx(1), params.imageSizePx(2), params.imageSizeCm(2));

% store targets in stereoPair and return
stereoPair.targets = targets;
end


% Erika's function for adjustment.
% needs to take current target chroma. 
function [] = AdjustTestColor(win, whiteXYZ, cal, stepSize, currentStepSize, adjustLChNo, upDownFlg, targetName)
currRGB = (win.getObjectProperty(targetName, 'Color'))';
currLCh = RGB2LCh(currRGB, whiteXYZ, cal);
tempLCh = currLCh; % save in order to check if the saturation changed at all.
currLCh(adjustLChNo) = currLCh(adjustLChNo) + stepSize(currentStepSize,adjustLChNo)*upDownFlg;
[currRGB, badIndex, lchIndex] = LCh2RGB(currLCh, whiteXYZ, cal);

% If the lightness adjustment forced the color to go out of gamut, reduce colorfulness, then reduce lightness
if ((adjustLChNo == 1) && (badIndex == 1))
    % if (((upDownFlg < 0) && (currLCh(adjustLChNo) > 0)) || ((upDownFlg > 0) && (currLCh(adjustLChNo) < 100)))
    % decided to comment out the above because this should apply to all
    % cases. Cases of L < 0 is already handled above, case L > 100 will not
    % get special treatment.
    count = 1;
    while (((badIndex == 1) && (currLCh(2) > 0)) && (count < 5))
        count = count + 1;
        currLCh(2) = currLCh(2) - stepSize(currentStepSize,2);
        % handle out of gamut lightness case by reducing the chromaticity by one
        % step. Repeat this 5 times, to get the lightness into gamut,
        % as long as chromaticity is larger than 0.
        if (currLCh(2) < 0)
            currLCh(2) = 0;
        end
        [currRGB, badIndex, lchIndex] = LCh2RGB(currLCh, whiteXYZ, cal);
    end
    %end
end
%
% If the color goes out of gamut because of change in chroma
if (adjustLChNo == 2)
    count = 1;
    if ((badIndex == 1) || (lchIndex == 1))
        % first annul the step you made
        currLCh(adjustLChNo) = currLCh(adjustLChNo) - stepSize(currentStepSize,adjustLChNo)*upDownFlg;
    end
    % Reduce the step size to see how much can
    % you change it so it is in gamut. On each step first check if it
    % returns the color in gamut. If it does not, annul the step and try
    % with the smaller change. Do that 5 times.
    while (((badIndex == 1) || (lchIndex == 1)) && (count < 5))
        currLCh(adjustLChNo) = currLCh(adjustLChNo) + stepSize(currentStepSize,adjustLChNo)*upDownFlg/(count*2);
        [currRGB, badIndex, lchIndex] = LCh2RGB(currLCh, whiteXYZ, cal);
        if ((badIndex == 1) || (lchIndex == 1))
            currLCh(adjustLChNo) = currLCh(adjustLChNo) - stepSize(currentStepSize,adjustLChNo)*upDownFlg/(count*2);
            [currRGB, badIndex, lchIndex] = LCh2RGB(currLCh, whiteXYZ, cal);
        end
        count = count + 1;
    end
end

% If the color goes out of gamut because of change in hue
% reduce the saturation by the current step size, then try again.
% Do that 5 times for improvement.
if ((adjustLChNo == 3) && (badIndex == 1))
    count = 1;
    while (((badIndex == 1) && (currLCh(2) > 0)) && (count < 5))
        count = count + 1;
        currLCh(2) = currLCh(2) - stepSize(currentStepSize,2);
        [currRGB, badIndex, ~] = LCh2RGB(currLCh, whiteXYZ, cal);
    end
end

% correction that forces Lch values to go in circle from 0 to 360.
if (currLCh(3) > 2*pi)
    currLCh(3) = currLCh(3) - 2*pi;
    [currRGB, badIndex, ~] = LCh2RGB(currLCh, whiteXYZ, cal);
elseif (currLCh(3) < 0)
    currLCh(3) = currLCh(3) + 2*pi;
    [currRGB, badIndex, ~]= LCh2RGB(currLCh, whiteXYZ, cal);
end

% check if saturation changed at all
diff = abs(tempLCh(2) - currLCh(2));

% check if all settings are within the range
if any(currRGB>1) && any(currRGB<0)
    fprintf('WARNING! WARNING! Settings are not within the range!\n')
end

% if after all the adjustments the bad index is 1 or the saturation has not
% changed.
if ((badIndex == 1) ||((adjustLChNo == 2) && (diff < 0.01)))
    Speak('Can not change color further');
    fprintf('Out of gamut: %0.2f %0.2f %0.2f.\n', currRGB(1), currRGB(2), currRGB(3));
else
    win.setObjectProperty(targetName, 'Color', currRGB');
    % win.draw;
    fprintf('Settings: %0.2f %0.2f %0.2f. ', currRGB(1), currRGB(2), currRGB(3));
    fprintf('currLCh: %0.2f %0.2f %0.2f.\n', currLCh(1), currLCh(2), radtodeg(currLCh(3)));
end
end

% function result = SaveResult(win, cal, whiteXYZ, targetName)
% % saves result "in all forms".
% result.resultRGB = (win.getObjectProperty(targetName, 'Color'))';
% result.resultXYZ = SettingsToSensor(cal, result.resultRGB);
% result.resultXyY = XYZToxyY(result.resultXYZ);
% result.resultLab = XYZToLab(result.resultXYZ, whiteXYZ);
% result.resultLCh = SensorToCyl(result.resultLab);
% fprintf('Settings: %0.2f %0.2f %0.2f. ', result.resultRGB(1), result.resultRGB(2), result.resultRGB(3));
% fprintf('currLCh: %0.2f %0.2f %0.2f.\n', result.resultLCh(1), result.resultLCh(2), radtodeg(result.resultLCh(3)));
% end

function KeyReference(currentStepSize)
switch currentStepSize
    case 1
        Speak('Small');
    case 2
        Speak('Medium');
    case 3
        Speak('Large');
end
if (currentStepSize > 3) || (currentStepSize < 0)
    error('This step size does not exist.');
end
end

function stereoCalibrationInfo = specifyStereoCalibration 
% hardcoded. DO NOT CHANGE. 
stereoCalibrationInfo = struct;
stereoCalibrationInfo.displayPosition           = {'left', 'right'};
stereoCalibrationInfo.spectralFileNames         = {'StereoLCDLeft', 'StereoLCDRight'};
stereoCalibrationInfo.warpFileNames             = {'StereoWarp-Radiance-left', 'StereoWarp-Radiance-right'};
stereoCalibrationInfo.interOcularDistanceInCm   = 6.4;                       % needed to compute the asymmetric OpenGL frustum
stereoCalibrationInfo.sceneDimensionsInCm       = [51.7988 32.3618 76.4];   % 3rd param is needed to compute the asymmetric OpenGL frustum
end


function resetEnvironment(rootDirectory)
ListenChar(0);
mglSwitchDisplay(-1);
mglDisplayCursor(1);
mglSetMousePosition(512, 512, 1);
cd(rootDirectory);
end