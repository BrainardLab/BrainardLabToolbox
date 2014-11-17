function StereoViewControllerDemo
% Demo code to illustrate usage of the StereoViewController class.
%
% 3/26/2013     npc     Wrote it
%

    % Clear everything
    clc; clear all; clear Classes; close all; ClockRandSeed;
    
    % Always use Classes-Dev
    UseClassesDev;
    
    % Set the root directory and add its subdirectories to the path
    rootDirectory = pwd;
    genpath(rootDirectory);
    
     % set feedback voide
    feedbackVoice = 'Alex';
    
    % No stringent calibration check
    performStringentCalibrationChecks = false;
    
    % Configure the stereo calibration struct
    stereoCalibrationInfo = struct;
    stereoCalibrationInfo.displayPosition           = {'left', 'right'};
    stereoCalibrationInfo.spectralFileNames         = {'StereoLCDLeft', 'StereoLCDRight'};
    stereoCalibrationInfo.warpFileNames             = {'StereoWarp-Radiance-left', 'StereoWarp-Radiance-right'};
    stereoCalibrationInfo.interOcularDistanceInCm   = 6.4;                      % needed to compute the asymmetric OpenGL frustum
    stereoCalibrationInfo.sceneDimensionsInCm       = [51.7988 32.3618 76.4];   % 3rd param is needed to compute the asymmetric OpenGL frus
    
    
    userInput = input('Mouse position: [0 = Left Screen]   [1=RightScreen]   [2: Stereo] : ');    
    if (userInput == 0)
        mousePosition = 'LeftMonocular';
    elseif (userInput == 1)
        mousePosition = 'RightMonocular';
    else
        mousePosition = 'Stereo';
    end
    Speak(sprintf('Mouse is %s', mousePosition));
    
    
    
    Speak('TIFF, or presentation mode', feedbackVoice);
    userInput = input('TIFF mode=[0]   Presentation mode=[1] : ');
        
    if (userInput == 0)
        presentationMode = 'TIFF';
    else
        presentationMode = 'StereoDisplay';
    end
            
 
    % Configure a stereo pair stimulus and its targets
    stereoPair  = struct;
    
    % Flag to let the StereoViewController that the images are to be loaded
    % from files. These names must be specified in stereoPair.imageNames
    %stereoPair.stimulusSource       = 'file';
    stereoPair.stimulusSource       = 'matrix';
    
    if (strcmpi(stereoPair.stimulusSource, 'file'))
        stereoPair.imageNames.left      = fullfile('StereoPairsRepository', 'Stimulus-Left.tiff');
        stereoPair.imageNames.right     = fullfile('StereoPairsRepository', 'Stimulus-Right.tiff');
        imageInfo                       = imfinfo(stereoPair.imageNames.left);
    else
        
        Speak('Please select scene.', feedbackVoice);
        userSelection = input('0 for Spheres (Achrom Forced Choice) scene),   1 for Cube scene : ');
        
        if (userSelection == 0)
            demoScene =  'AchromForcedChoice';
        else
            demoScene = 'Cubes';
        end
        
        if (strcmpi(demoScene, 'AchromForcedChoice'))
            stimFname = fullfile('StereoPairsRepository', 'AchromForcedChoiceImageData');
            imageFiles = {'AchromForcedChoiceScene'};
            whichImage = 1;
            load(stimFname);
            imageSize = windowInfo.GLImageSize;
            stereoPair.imageData.left  = flipdim(double(imageData.leftImageRGB)/255,1);
            stereoPair.imageData.right = flipdim(double(imageData.rightImageRGB)/255,1);
            imageInfo.Height = size(imageData.leftImageRGB,1);
            imageInfo.Width  = size(imageData.leftImageRGB,2);
        else 
            imageFiles = {'DepthDemo1', 'DepthDemo2', 'DepthDemo3'};
            whichImage = 1;
            stereoPair.imageNames.left  = fullfile('StereoPairsRepository', [imageFiles{whichImage} 'L-RGB.mat']);
            stereoPair.imageNames.right = fullfile('StereoPairsRepository', [imageFiles{whichImage} 'R-RGB.mat']);    
            
            % Load the left image data
            load(stereoPair.imageNames.left);
            if (whichImage == 1)
                stereoPair.imageData.left  = flipdim(sensorImageLeftRGB,1);
            else
                stereoPair.imageData.left  = flipdim(sensorImageRGB,1);   
            end
            
             % Load the right image data
            load(stereoPair.imageNames.right);
            if (whichImage == 1)
                stereoPair.imageData.right  = flipdim(sensorImageRightRGB,1);
            else
                stereoPair.imageData.right  = flipdim(sensorImageRGB,1); 
            end
            
            % load the image width and height (in pixels)
            imageInfo.Height = size(stereoPair.imageData.left,1);
            imageInfo.Width  = size(stereoPair.imageData.left,2);   
        end
    end
    
    % Load experiment configuration file
    cfgFile = ConfigFile(fullfile('StereoPairsRepository', 'DepthDemo.cfg'));
    expConfigParams = convertToStruct(cfgFile);
    
    % Set the desired position and size (in Cm) for the displayed stereo
    % pair images
    stereoPair.imagePosition  = expConfigParams.imagePositionInCm;
    stereoPair.imageSize      = expConfigParams.imageSizeInCm;
    
    % Specify target positions 
    targets = struct;
    targets.leftScreen.XcoordsPxls = expConfigParams.targetXPosInLeftImagePxls;
    targets.leftScreen.YcoordsPxls = expConfigParams.targetYPosInLeftImagePxls;
    targets.rightScreen.XcoordsPxls = expConfigParams.targetXPosInRightImagePxls;
    targets.rightScreen.YcoordsPxls = expConfigParams.targetYPosInRightImagePxls;
    targets.rightScreen.maximumAcceptableDistancePxls = expConfigParams.maxDistanceInImagePxls;
    targets.leftScreen.maximumAcceptableDistancePxls  = expConfigParams.maxDistanceInImagePxls;
     
    
    % Transform target coords into screen centimeters
    [targets.leftScreen.XcoordsCm, targets.leftScreen.YcoordsCm] = ...
        StereoViewController.imagePixelsToScreenCentiMeters(targets.leftScreen.XcoordsPxls, targets.leftScreen.YcoordsPxls, imageInfo.Width, imageInfo.Height, stereoPair.imageSize(2));
    
     [targets.rightScreen.XcoordsCm, targets.rightScreen.YcoordsCm] = ...
        StereoViewController.imagePixelsToScreenCentiMeters(targets.rightScreen.XcoordsPxls, targets.rightScreen.YcoordsPxls, imageInfo.Width, imageInfo.Height, stereoPair.imageSize(2));
    
    [targets.leftScreen.maximumAcceptableDistanceCm, ~] = ...
        StereoViewController.imagePixelsToScreenCentiMeters(targets.leftScreen.maximumAcceptableDistancePxls, 0,  0, imageInfo.Height, stereoPair.imageSize(2));
    
    [targets.rightScreen.maximumAcceptableDistanceCm, ~] = ...
        StereoViewController.imagePixelsToScreenCentiMeters(targets.rightScreen.maximumAcceptableDistancePxls, 0,  0, imageInfo.Height, stereoPair.imageSize(2));
    
    
    
    % store targets in stereoPair and return
    stereoPair.targets = targets;
          
    % Specify imageRegion struct for initial mouse positions
    % Right image perimeters
    rightImageExcludePerimeterPoints =  [560 153; 256 295; 259 622; 551 838; 815 646; 882 324; 560 153];
    rightImageIncludePerimenterPoints=  [10 84+10; 960-10 84+10; 960-10 877-10; 10 877-10; 10 84+10];
    
    % Left image perimeters (just flip the x-coord of the right image
    % perimeter. Not exactly accurate because the cube is not flipped, but
    % not too bad, either)
    leftImageExcludePerimeterPoints  = rightImageExcludePerimeterPoints ;
    leftImageIncludePerimenterPoints = rightImageIncludePerimenterPoints;
    widthInPixels = size(stereoPair.imageData.right,2);
    leftImageExcludePerimeterPoints(:,1) = widthInPixels - leftImageExcludePerimeterPoints(:,1);
    leftImageIncludePerimenterPoints(:,1) = widthInPixels - leftImageIncludePerimenterPoints(:,1);
    
    imageRegion = struct;
    if strcmpi(mousePosition, 'LeftMonocular')
        imageRegion.parentImageScreenPosition = 'left';
        imageRegion.excludePerimeterPoints    = leftImageExcludePerimeterPoints;  % coords in image pixels
        imageRegion.includePerimeterPoints    = leftImageIncludePerimenterPoints;  % coords in image pixels
        imageRegion.parentImageWidthInPixels  = size(stereoPair.imageData.left,2);
        imageRegion.parentImageHeightInPixels = size(stereoPair.imageData.left,1);
    elseif strcmpi(mousePosition, 'RightMonocular')
        imageRegion.parentImageScreenPosition = 'right';
        imageRegion.excludePerimeterPoints    = rightImageExcludePerimeterPoints;  % coords in image pixels
        imageRegion.includePerimeterPoints    = rightImageIncludePerimenterPoints;  % coords in image pixels
        imageRegion.parentImageWidthInPixels  = size(stereoPair.imageData.right,2);
        imageRegion.parentImageHeightInPixels = size(stereoPair.imageData.right,1);
    else
        % not sure what to do in the stereo mouse for perimeter.
        % choosing right for now
        imageRegion.parentImageScreenPosition = 'right';
        imageRegion.excludePerimeterPoints    = rightImageExcludePerimeterPoints;  % coords in image pixels
        imageRegion.includePerimeterPoints    = rightImageIncludePerimenterPoints;  % coords in image pixels
        imageRegion.parentImageWidthInPixels  = size(stereoPair.imageData.right,2);
        imageRegion.parentImageHeightInPixels = size(stereoPair.imageData.right,1);
    end
    
    imageRegion.parentImageWidthInCm      = stereoPair.imageSize(1);  
    imageRegion.parentImageHeightInCm     = stereoPair.imageSize(2);
    
    
     % Specify the stereo cursor 
    stereoCursor = struct;
    if strcmpi(mousePosition, 'LeftMonocular')
        stereoCursor.type = 'MonocularLeftEye';
    elseif strcmpi(mousePosition, 'RightMonocular')
        stereoCursor.type = 'MonocularRightEye';
    else
        stereoCursor.type           = 'CrossHairs3D';
    end
    
    stereoCursor.center             = [0 0 0.01; 0 0 0.01]; % z-coord must be > 0, otherwise the cursor will be blocked by the stereo-pair image (z = 0)
    stereoCursor.diskDiameter       = 0.3;        % diameter of the inner disk
    stereoCursor.diameter           = 1.6;        % diameter of the overall cursor (cross-hairs)
    stereoCursor.lineThickness      = 2.0;
    stereoCursor.color              = repmat([0 1 0], [2 1]);
    
   
    runMode = 'Data Collection';
    runMode = 'Debug Target Positions';
    %runMode = 'Debug Random Mouse Positions';
    %runMode = 'Radiometric Measurement';
        
    try  
        stereoView = [];
        
        % Construct the StereoView object
        instanceName = 'stereoView';

        
        if (strcmpi(presentationMode, 'TIFF'))
            stereoView = StereoViewController( instanceName, ...
                                           stereoCalibrationInfo, ...
                                           performStringentCalibrationChecks, ...
                                           'beVerbose', true,... 
                                           'noFrameBufferWarping', true);
        else
            stereoView = StereoViewController( instanceName, ...
                                           stereoCalibrationInfo, ...
                                           performStringentCalibrationChecks, ...
                                           'beVerbose', true);
        end
        
        
        if (stereoView.isInitialized == false)
            disp('The StereoView object failed to initialize. Exiting now ... ');
            resetEnvironment(rootDirectory);
            return;
        end
        
        % Obtain the screen configurations
        screenConfig = stereoView.displayConfiguration(imageRegion.parentImageScreenPosition);
 
        
        stereoView.printState;

        
        % Start listening for key presses, while suppressing any
        % output of keypresses on the command window
        ListenChar(2);
        FlushEvents;
        
        trialIndex = 0;
        quitRun = false;
        while(~quitRun) 
            
            % Check for keypresses (only caring about quit button for now)
            key = mglGetKeyEvent;
            if (~isempty(key))   
                 switch key.charCode
                     case 'q'
                         quitRun = true;
                         Speak('User quit the run!', feedbackVoice);
                 end
            end
            
            if (~quitRun)   
                % Add the stereoPair in the rendering pipeline
                stereoView.setStereoPair(stereoPair);
                
                % Add the stereo cursor
                stereoView.setStereoCursor(stereoCursor);
                
                % Export the stimuli in TIFF files if noFrameBufferWarping == true
                if ((trialIndex == 0) && (stereoView.noFrameBufferWarping))
                    stereoView.showStimulus();
                    mglFlush();
                    Speak('Please wait. Exporting left and right scenes to Tiff files', feedbackVoice);  
                    stereoView.exportStimulusToTiffFile(sprintf('%s.tiff',imageFiles{whichImage})); 
                    Speak('Exporting complete', feedbackVoice);
                end
                
                
                %if (strcmpi(runMode, 'Debug Target Positions'))
                     % Show target boxes
                     stereoView.showTargetBoxes();
                %end
                
                % Select response loop method according to runMode
                if (strcmpi(runMode, 'Debug Target Positions') || strcmpi(runMode,  'Data Collection') || strcmpi(runMode, 'Debug Random Mouse Positions'))
                     % Generate a new random initial mouse position
                     mousePositionsToGenerate = 1;
                     [mouseXpos,mouseYpos] = stereoView.generateRandomInitialMousePositionBasedOnImageRegion(imageRegion, screenConfig, mousePositionsToGenerate);
        
                     % Start the experimental loop
                     if (strcmpi(runMode, 'Debug Random Mouse Positions'))
                         displayStimulusAndReturnImediatelyFlag = true;
                     else
                         displayStimulusAndReturnImediatelyFlag = false;
                     end
                     
                     %responseStruct = stereoView.waitForTargetSelection([mouseXpos,mouseYpos], displayStimulusAndReturnImediatelyFlag, imageRegion.parentImageScreenPosition);
                     responseStruct = stereoView.runExperimentalLoopWithCubeScene();
                     
                     % Register the data, if a target was selected
                     if (~isnan(responseStruct.selectedTargetIndex))
                        trialIndex = trialIndex + 1;
                        selectedTarget(trialIndex) = responseStruct.selectedTargetIndex;
                        if (~strcmpi(runMode, 'Debug Random Mouse Positions'))
                            Speak(sprintf('Target %d', selectedTarget(trialIndex)), feedbackVoice);  
                        end
                     else
                        % if we got an empty response, the user quit the run
                        quitRun = true;
                    end
                elseif (strcmpi(runMode, 'Radiometric Measurement'))
                    % position radiometer box on first target
                    x = stereoPair.targets.rightScreen.XcoordsCm(1);
                    y = stereoPair.targets.rightScreen.YcoordsCm(1);
                    radiometerBox.rightScreen.XYZcoordsCm = [x y 0.001];
                    radiometerBox.leftScreen.XYZcoordsCm  = [x y -1000];  % if Z is negative, 
                    radiometerBox.width = 2.5;
                    radiometerBox.lineThickness = 2.0;
                    radiometerBox.colorRGB = [0 0 0];     
                    % Show the radiometer box
                    stereoView.setRadiometerBox(radiometerBox);
                    % Start the loop
                    whichMeterType = 0;
                    isFirstTrial = true;
                    radiometricStruct = stereoView.measureRadiometricDistributionOfScene(whichMeterType, isFirstTrial);
                    quitRun = true;
                end
    
            end  % (~quitRun)
            
        end % while
        
        % All done with the experiment. Exit gracefully.
        stereoView.shutdown;
        resetEnvironment(rootDirectory);
        
    catch e
        if (~isempty(stereoView))
        if (stereoView.isInitialized)
           stereoView.shutdown; 
        end
        end
        resetEnvironment(rootDirectory);
        rethrow(e);
    end
end
 
 
 
function resetEnvironment(rootDirectory)
    ListenChar(0);
    mglSwitchDisplay(-1);
    mglDisplayCursor(1);
    mglSetMousePosition(512, 512, 1);
    cd(rootDirectory);
end

