classdef StereoViewController < handle
% 
%   @mainpage
% 
%   @b Description: 
%   The StereoViewController is a class that is used to display stereo-pair stimuli and to 
%   obtain the subject's response. The class also includes additional
%   functionality that allows the user to debug and calibrate the employed stimuli. 
% 
%   History:
%   @code
%   3/11/2013   npc     Wrote it.
%   4/26/2013   npc     Cleaned up, added Doxygen comments
%   @endcode
%

    % Publically viewable and settable properties.
    properties (Access = public)  
        % Boolean indicating whether to display information at different execution stages (optional, defaulting to false).
        beVerbose = false;

        % Boolean indicating whether to render stimuli without warping.
        % This is useful for debuggin stereo aspects of the stimuli
        noFrameBufferWarping = false;
        
        % Boolean indicating whether to display messages in modal windows, in addition to the console. (optional, defaulting to false).
        % This can be useful to capture the attention of the user in case
        % of a problem that needs to be addressed (for example calibration files been too old).
        useModalWindowForMessages = false;
    end
    
    % Properties that aren't settable, but the user can see.
    properties (SetAccess = private)  
        % Boolean indicating whether the experiment controller has been sucessfully initialized.
		isInitialized = false;
        
        % Struct containing all the information related to the stereo pair
        % stimulus to be displayed. See @ref setStereoPair for more
        % information.
        stereoPair;
        
        % Struct containing all the information related to the stereo
        % cursor. See @ref setStereoCursor for more information.
        stereoCursor;
        
        % mouse object
        mouseDev;
        
        % The name of the current instance of class StereoViewController.
        instanceName;
        
        % Struct containing the spectral and warp calibration files for the displays.
        % See @ref StereoViewController snippet for more information.
        stereoCalibrationInfo;
        
        % Boolean indicating whether to check the calibration age and
        % monitor compatibility with the calibration files
        stringentCalibrationChecks;
        
        % The GLWindow controlling the stereo display
        stereoGLWindow;
        
    end

    % Properties internal to the class hidden from the user
	properties (Access = private)
        % Struct generated during initialization from the passed StereoCalibrationInfo
        stereoDisplayConfiguration;
        
    end
    
    % Class constructor
    methods
        
        % Class constructor. Initializes the StereoViewController object
        % according to the required input arguments and the ensuing optional key/value pairs.
        %
        % Parameters:
        % instanceName: -- string containing the name of the @ref
        % StereoViewController object (must be provided at initialization
        % time)
        % stereoCalibrationInfo: -- struct containing various calibration files and data (must be provided at initialization
        % time). See attached code snippet for more information.
        % stringentCalibrationChecks:  -- boolean indicating whether to do
        % a stringent calibration check (must be provided at initialization time)
        %
        %
        % @note
        % The following code snippet displays how one could instantiate a
        % StereoViewController object.
        %
        % @code
        % ## Specify scene dimensions
        % virtualSceneWidthInCm      = 51.7988;
        % virtualSceneHeightInCm     = 32.3618;
        % virtualSceneZdistanceInCm  = 76.4;  
        % 
        % ## Specify stereo calibration structure
        % stereoCalibrationInfo = struct;
        % stereoCalibrationInfo.displayPosition           = {'left', 'right'};
        % stereoCalibrationInfo.spectralFileNames         = {'StereoLCDLeft', 'StereoLCDRight'};
        % stereoCalibrationInfo.warpFileNames             = {'StereoWarp-Radiance-left', 'StereoWarp-Radiance-right'};
        % stereoCalibrationInfo.interOcularDistanceInCm   = 6.4;                        
        % stereoCalibrationInfo.sceneDimensionsInCm       = [virtualSceneWidthInCm   virtualSceneHeightInCm   virtualSceneZdistanceInCm]; 
        % 
        % ## Perform a stringent calibration check if the subject name is not test  
        % if (strcmpi(subjectName, 'test'))
        %     performStringentCalibrationChecks = false;
        % else
        %     performStringentCalibrationChecks = true;
        % end
        % 
        % ##  Let's name our StereoViewController object as 'my_stereo_view_controller' 
        % instanceName = 'my_stereo_view_controller';
        % 
        % ##  Generate the StereoViewController object  
        % stereoViewCntr = StereoViewController( instanceName, ...
        %                                        stereoCalibrationInfo, ...
        %                                        performStringentCalibrationChecks, ...
        %                                        'beVerbose', true);
        %
        % ##  Set an optional attrinute of stereoViewCntr   
        % stereoViewCntr.useModalWindowForMessages = true;
        % 
        % ##  Print current state of stereoViewContr  
        % stereoViewCntr.printState;
        %
        % ##
        % @endcode
        function obj = StereoViewController(instanceName, stereoCalibrationInfo, stringentCalibrationChecks, varargin)
            
            % check that we have the right number of arguments
            minNumOfInputs = 3;
            maxNumOfInputs = Inf;
            error(nargchk(minNumOfInputs, maxNumOfInputs, nargin));
         
            %%% Unload the required input argument
            obj.instanceName                = instanceName;
            obj.stereoCalibrationInfo       = stereoCalibrationInfo;
            obj.stringentCalibrationChecks  = stringentCalibrationChecks;
            
            % Configure an inputParser to examine whether the options passed to us are valid
            parser = inputParser;
            parser.addParamValue('beVerbose', obj.beVerbose);
            parser.addParamValue('noFrameBufferWarping', obj.noFrameBufferWarping);
            parser.addParamValue('useModalWindowForMessages', obj.useModalWindowForMessages);
            
            % Execute the parser to make sure input is good
			parser.parse(varargin{:});
            
            % Create a standard Matlab structure from the parser results.
			parserResults = parser.Results;
            
            % Copy the parse parameters to the StereoViewController object
            pNames = fieldnames(parserResults);
            for k = 1:length(pNames)
               obj.(pNames{k}) = parserResults.(pNames{k}); 
            end
            
            % Initialize the controller
            obj = obj.InitializeStereoView;
        end  %Constructor of StereoViewController

    end 

    methods (Access = private)
        % Method to check the spectral and warp files
        calibrationIsOK = CheckCalibrationFiles(obj);
        
        % Method to set the screen assignment test objects. Called by checkScreenAssignment
        function setScreenAssignmentTests(obj)
            N = 1024;
            leftScreenTest.imageData.left   = ones(N,N,3);
            leftScreenTest.imageData.right  = zeros(N,N,3);
            leftScreenTest.imagePosition    = [0 0];
            leftScreenTest.imageSize        = [N N];
            rightScreenTest.imageData.left  = leftScreenTest.imageData.right;
            rightScreenTest.imageData.right = leftScreenTest.imageData.left;
            rightScreenTest.imagePosition   = [0 0];
            rightScreenTest.imageSize       = [N N];
    
            obj.stereoGLWindow.addImage(leftScreenTest.imagePosition, leftScreenTest.imageSize, leftScreenTest.imageData, 'Name', 'LeftScreenAssignmentTest');
            obj.stereoGLWindow.disableObject('LeftScreenAssignmentTest');
            obj.stereoGLWindow.addImage(rightScreenTest.imagePosition, rightScreenTest.imageSize, rightScreenTest.imageData, 'Name', 'RightScreenAssignmentTest');
            obj.stereoGLWindow.disableObject('RightScreenAssignmentTest');
        end
        
    end
    
    % Action methods
    methods (Access = public)
        
        % Method to check the stereo screen assignment (left, right) before running an
        % experiment. 
        %
        % It has been observed that on occasion, OSX may switch the left and right displays.
        % By calling this method at the beginning of the experiment, the
        % user can check whether the screens have been assigned correctly.
        %
        function checkScreenAssignment(obj, screenName)
            
            fprintf('\nHit enter to flicker %s screen. Hit ''q'' to stop flickering.\n\n', screenName);
            pause;
        
            % Obtain state of StereoPair object
            stereoPairWasEnabled = obj.stereoGLWindow.getObjectProperty('StereoPair','Enabled');
            % Disable Stereo Pair
            if (stereoPairWasEnabled)
                obj.stereoGLWindow.disableObject('StereoPair');
            end
            
            obj.setScreenAssignmentTests();
            
            quitRun = false;
            on = true;
            while(~quitRun) 
                key = mglGetKeyEvent;
                if (~isempty(key))   
                    switch key.charCode
                        case 'q'
                         quitRun = true;
                    end
                end
                if (~quitRun) 
                    if (strcmpi(screenName, 'left'))
                        obj.stereoGLWindow.disableObject('RightScreenAssignmentTest');
                        if (on)
                            obj.stereoGLWindow.enableObject('LeftScreenAssignmentTest');
                        else
                           obj.stereoGLWindow.disableObject('LeftScreenAssignmentTest');
                        end
                    else
                        obj.stereoGLWindow.disableObject('LeftScreenAssignmentTest');
                        if (on)
                            obj.stereoGLWindow.enableObject('RightScreenAssignmentTest');
                        else
                            obj.stereoGLWindow.disableObject('RightScreenAssignmentTest');
                        end
                    end
                    on = ~on;
                    obj.stereoGLWindow.draw;
                else
                     obj.stereoGLWindow.disableObject('RightScreenAssignmentTest');
                     obj.stereoGLWindow.disableObject('LeftScreenAssignmentTest');
                     obj.stereoGLWindow.draw;
                end
            end % while
            
            % restore state of stereoPair
            if (stereoPairWasEnabled)
                obj.stereoGLWindow.enableObject('StereoPair');
                obj.stereoGLWindow.draw;
            end
        end  
        
        
        % Method that prints the state of the StereoViewController
        % object.
        function printState(obj)
            if ((obj.isInitialized) && (obj.beVerbose))
                CodeDevHelper.DisplayHierarchicalViewOfObjectProperties(obj, obj.instanceName);
            end
        end
        
        % Method that returns the display configuration for a particular screen
        function displayConfig = displayConfiguration(obj,whichScreen)
            if (strcmpi(whichScreen, 'left'))
                displayConfig = obj.stereoDisplayConfiguration.screenData{1};
            else
                displayConfig = obj.stereoDisplayConfiguration.screenData{2};
            end
            
        end
        
        
        % Method that exports the stimulus to a tiff file
        function exportStimulusToTiffFile(obj, tiffFileName) 
            if (~obj.noFrameBufferWarping)
                CodeDevHelper.DisplayModalMessageBox('The exported stimulus includes the screen warping transformation. To see the actual stimulus as it appears on the virtual screen, turn the noFrameBufferWarping flag on', 'Warning');
            end
            images = obj.stereoGLWindow.dumpSceneToTiff(tiffFileName);
        end
        
        
        function setCursorVisibility(obj, state)
            mglDisplayCursor(double(state));
        end
        
        
        % Method that adds a @ref stereoPair element to the drawing pipeline. 
        % 
        %
        function setStereoPair(obj,stereoPair)
            
            if (strcmpi(stereoPair.stimulusSource, 'file'))
                % add the stereo pair images
                obj.stereoGLWindow.addImageFromFile(stereoPair.imagePosition, stereoPair.imageSize, stereoPair.imageNames, 'Name', 'StereoPair');
                obj.stereoGLWindow.disableObject('StereoPair');
            else
                % add the stereo pair images
                obj.stereoGLWindow.addImage(stereoPair.imagePosition, stereoPair.imageSize, stereoPair.imageData, 'Name', 'StereoPair');
                obj.stereoGLWindow.disableObject('StereoPair');
            end
            if isfield(stereoPair, 'targets')
                % add the target boxes
                targetBoxesNum = length(stereoPair.targets.rightScreen.XcoordsCm);
                % Right screen targets
                for targetBoxIndex = 1:targetBoxesNum
                    colorRGB.left   = [0 0 0];
                    colorRGB.right  = colorRGB.left;
                    pos.left        = [0 0 -1000];  % invisible on the left screen
                    pos.right       = [stereoPair.targets.rightScreen.XcoordsCm(targetBoxIndex) stereoPair.targets.rightScreen.YcoordsCm(targetBoxIndex) 0.001];
                    objectName      = sprintf('RightTargetBox%d',targetBoxIndex);
                    obj.stereoGLWindow.addRectangle(pos, 0.25*[1 1], colorRGB, 'Name', objectName);
                    obj.stereoGLWindow.disableObject(objectName);
                    
                end
                %Left screeen targets
                for targetBoxIndex = 1:targetBoxesNum
                    colorRGB.left   = [0 0 0];
                    colorRGB.right  = colorRGB.left;
                    pos.right       = [0 0 -1000];  % invisible on the right screen
                    if (isfield(stereoPair.targets, 'leftScreen'))
                        pos.left        = [stereoPair.targets.leftScreen.XcoordsCm(targetBoxIndex) stereoPair.targets.leftScreen.YcoordsCm(targetBoxIndex) 0.001];
                    else
                        pos.left        = [stereoPair.targets.rightScreen.XcoordsCm(targetBoxIndex) stereoPair.targets.rightScreen.YcoordsCm(targetBoxIndex) 0.001];
                    end
                    objectName      = sprintf('LeftTargetBox%d',targetBoxIndex);
                    obj.stereoGLWindow.addRectangle(pos, 0.25*[1 1], colorRGB, 'Name', objectName);
                    obj.stereoGLWindow.disableObject(objectName);
                end
            end
            % Set the stereoPair property
            obj.stereoPair = stereoPair;
        end
        
        
        % Method that renders the scene after enabling the @ref stereoPair element.
        %
        % Return values:
        %  stimulusOnset: -- The timestamp of the stimulus first rendering
        %
        function stimulusOnset = showStimulus(obj)
            obj.stereoGLWindow.enableObject('StereoPair');
            stimulusOnset = obj.stereoGLWindow.draw;
        end
        
        % Method that renders the scene after disabling the @ref stereoPair object.
        %
        function hideStimulus(obj)
            obj.stereoGLWindow.disableObject('StereoPair');
            obj.stereoGLWindow.draw;
        end
        
        % Method that renders the scene after enabling the target elements.
        %
        % This is helpful during Debug Mode to make sure that the target selection areas are placed at the right locations
        %
        function showTargetBoxes(obj)
            targetBoxesNum = length(obj.stereoPair.targets.rightScreen.XcoordsCm);
            for targetBoxIndex = 1:targetBoxesNum
                objectName = sprintf('LeftTargetBox%d',targetBoxIndex);
                obj.stereoGLWindow.enableObject(objectName);
                objectName = sprintf('RightTargetBox%d',targetBoxIndex);
                obj.stereoGLWindow.enableObject(objectName);
            end
            obj.stereoGLWindow.enableObject('StereoPair');
            obj.stereoGLWindow.draw;
        end
        
        % Method that renders the scene after disabling the target elements.
        %
        function hideTargetBoxes(obj)
            targetBoxesNum = length(obj.stereoPair.targets.rightScreen.XcoordsCm);
            for targetBoxIndex = 1:targetBoxesNum
                objectName = sprintf('LeftTargetBox%d',targetBoxIndex);
                obj.stereoGLWindow.disableObject(objectName);
                objectName = sprintf('RightTargetBox%d',targetBoxIndex);
                obj.stereoGLWindow.disableObject(objectName);
            end
            obj.stereoGLWindow.disableObject('StereoPair');
            obj.stereoGLWindow.draw;
        end
        
        
        % Method that adds a hollow box (indicating the radiometer target position) to the drawing pipeline. 
        %
        % This is helpful during Debug Mode to guide the aiming of the radiometer at various targets.
        %
        % Parameters:
        %  radiometerBox: -- a truct with various specifications for the box
        function setRadiometerBox(obj, radiometerBox)
            colorRGB.left    = radiometerBox.colorRGB;
            colorRGB.right   = colorRGB.left;
            center(1,:)      = radiometerBox.leftScreen.XYZcoordsCm;
            center(2,:)      = radiometerBox.rightScreen.XYZcoordsCm;
            size             = radiometerBox.width;
            lineThickness    = radiometerBox.lineThickness;
            objectName       = 'RadiometerBox';
            obj.stereoGLWindow.addHollowRectangle(center, size, size, lineThickness, colorRGB, 'Name', objectName);
            obj.stereoGLWindow.disableObject(objectName);
                
        end
        
        % Method that renders the scene after enabling the radiometer box.
        %
        function showRadiometerBox(obj)
            obj.stereoGLWindow.enableObject('RadiometerBox');
            obj.stereoGLWindow.draw;
        end
        
        % Method that renders the scene after disabling the radiometer box.
        %
        function hideRadiometerBox(obj)
            obj.stereoGLWindow.disableObject('RadiometerBox');
            obj.stereoGLWindow.draw;
        end
        
        
        % Method that adds an instructional message to the drawing pipeline. 
        %
        % This is helpful to instruct the user or the subject regarding what is about to hapen.
        %
        % Parameters:
        %  message : -- a truct with various specifications for the message
        function showMessage(obj, message)      
            % check whether we already have an element named 'Message'
            if (obj.stereoGLWindow.findObjectIndex('Message') ~= -1)
                obj.stereoGLWindow.deleteObject('Message');
            end
            % Add a new 'Message' element to the drawing pipeline
            obj.stereoGLWindow.addText(message.text, 'Center', message.center, 'Color', message.colorRGB, 'FontSize', message.fontSize, 'Name', 'Message');
            obj.stereoGLWindow.enableObject('Message');
            obj.stereoGLWindow.draw;
        end
        
        % Method that renders the scene after disabling the instructional message.
        %
        function hideMessage(obj)
            obj.stereoGLWindow.disableObject('Message');
            obj.stereoGLWindow.draw;
        end
        
        % Method that adds a @ref stereoCursor element to the drawing pipeline.
        %
        % The @ref stereoCursor element is set to a disabled state (invisible).
        %
        % Parameters:
        %  stereoCursor:
        function setStereoCursor(obj, stereoCursor)
            if (strcmpi(stereoCursor.type, 'CrossHairs3D'))
                obj.stereoGLWindow.addCrossHairsCursor3D(stereoCursor.diameter, stereoCursor.diskDiameter, stereoCursor.lineThickness, stereoCursor.color, 'Name', 'StereoCursor');
            elseif (strcmpi(stereoCursor.type, 'Simple3D'))
                obj.stereoGLWindow.addSimpleCursor3D(stereoCursor.diskDiameter, stereoCursor.lineThickness, stereoCursor.color, 'Name', 'StereoCursor');
            elseif ((strcmpi(stereoCursor.type, 'MonocularLeftEye')) || (strcmpi(stereoCursor.type, 'MonocularRightEye')))
                obj.stereoGLWindow.addMonocularCursor(stereoCursor.diskDiameter, stereoCursor.lineThickness, stereoCursor.color, 'Name', 'StereoCursor');
            end
            
            obj.stereoGLWindow.Cursor3Dposition = stereoCursor.center;
            obj.stereoGLWindow.disableObject('StereoCursor');
            
            obj.stereoCursor = stereoCursor;
        end
        
        % Method that renders the scene after enabling the @ref stereoCursor element.
        %
        function showStereoCursor(obj)
            obj.stereoGLWindow.enableObject('StereoCursor');
            obj.stereoGLWindow.draw;
        end
        
        % Method that renders the scene after disabling the @ref stereoCursor element.
        %
        function hideStereoCursor(obj)
            obj.stereoGLWindow.disableObject('StereoCursor');
            obj.stereoGLWindow.draw;
        end 
        
        % Method that presents a stereo-pair stimulus with a number of selectable targets and returns 
        % the index of the target selected by the subject.
        %
        % This is a testbed method for test different options. Options that we like, get adopted and implemented in the 
        % runExperimentalLoopWithCubeScene method. See @ref WaitForTargetSelection.m for more information. 
        %
        % Return Values:
        % responseStruct: -- struct with information related to the subject's selection.
        %
        function responseStruct = waitForTargetSelection(obj, initialMousePositon, displayStimulusAndReturnImediatelyFlag, whichScreen)
            responseStruct = WaitForTargetSelection(obj, initialMousePositon, displayStimulusAndReturnImediatelyFlag, whichScreen);
        end
        
        
        % Method that presents a stereo-pair stimulus with a number of selectable targets and returns 
        % a response struct that contains detailed information related to the subject's selection.
        %
        % Return values:
        % responseStruct: -- struct with information related to the subject's selection.
        %
        % See @ref RunExperimentalLoopWithCubeScene.m for more information.
        function responseStruct = runExperimentalLoopWithCubeScene(obj)
            responseStruct = RunExperimentalLoopWithCubeScene(obj);
        end
        
        % Method that presents a stereo-pair stimulus with a number of selectable targets and returns 
        % a response struct that contains detailed information related to the subject's selection.
        % This method is identical to the one above except it uses the
        % mouse for target selection. 
        % Return values:
        % responseStruct: -- struct with information related to the subject's selection.
        %
        % See @ref RunExperimentalLoopWithCubeSceneMouse.m for more information.
        function responseStruct = runExperimentalLoopWithCubeSceneMouse(obj, initialMousePositon)
            responseStruct = RunExperimentalLoopWithCubeSceneMouse(obj, initialMousePositon);
        end
        
        % See @ref RunExperimentalLoopWithCubeSceneMouse.m for more information.
        function responseStruct = runExperimentalLoopWithSliderSLC(obj, params)
            responseStruct = RunExperimentalLoopWithSliderSLC(obj, params);
        end
        
        % Method that measures the radiometric distribution at a scene location (debug mode only). 
        %
        % This method is usefull to check whether the rendered stimuli have the
        % desired spectral characteristics.
        %
        % Parameters:
        %   isFirstTrial: -- Boolean indicating whether this is the first time
        % we are calling this function.
        %
        % Return values:
        %  radiometricStruct: A struct containing ...
        function radiometricStruct = measureRadiometricDistributionOfScene(obj, whichMeterType, isFirstTrial)
            radiometricStruct = MeasureRadiometricDistributionOfScene(obj, whichMeterType, isFirstTrial);
        end
        
        % Method that generates a randomized initial mouse position with
        % a specified image region
        function [xMousePixels, yMousePixels] = generateRandomInitialMousePositionBasedOnImageRegion(obj, region, screenConfig, mousePositionsToGenerate)
           [xMousePixels, yMousePixels] = GenerateRandomInitialMousePositionBasedOnImageRegion(obj, region, screenConfig, mousePositionsToGenerate);
        end
        
        
        % Method that shuts down the current @ref StereoViewController and closes the screens.
        %
        function shutdown(obj)
           obj.stereoGLWindow.close;
           mglSwitchDisplay(-1);
        end
        
    end
   
    methods (Static = true)
        
        % Function to convert image coords in pixels (0 -- ImageWidthPixels) , (0 -- ImageHeightPixels) to
        % screen coords in centimeters (-imageWidthInCm/2 -- imageWidthInCm/2) , (-imageHeightInCm/2 -- imageHeightInCm/2)
        function [screenXcentimeters, screenYcentimeters] = imagePixelsToScreenCentiMeters(imageXPixels, imageYPixels, imageWidthPixels, imageHeightPixels, desiredImageHeightInCm)     
            
            % Flip the y-coordinate. On the image, the smallest ycoord is at the top.
            % On the screen the smallest ycoord is at the bottom.
            imageYPixels = imageHeightPixels - imageYPixels; 
            
            % Translate to origin
            imageXPixels = imageXPixels - imageWidthPixels/2;
            imageYPixels = imageYPixels - imageHeightPixels/2;
            
            % Scaling factor from image pixels to screen centimeters
            pxlsToCm = desiredImageHeightInCm / imageHeightPixels;
            
            % Transform to screen centimeters
            screenXcentimeters = imageXPixels * pxlsToCm;
            screenYcentimeters = imageYPixels * pxlsToCm;
        end
        
        % Function to convert virtual X,Y,Z coordinates to positions on the projection of the left and right screen onto the vergence plane.
        % If the system magnification is 1, as it is in the stereo rig,then the actual screen x-coordinates are sign-reversed versions of
        % their projections on the vergence plane, whereas the actual screen y-coordiates are identical to their projections on the
        % vergence plane. The units of all variables are centimeters
        function [xLeftScreen, yLeftScreen, xRightScreen, yRightScreen] = virtualXYZpositionToScreenCoords(Xi, Yi, Zi, zDistanceOfVergencePlaneFromViewer, interPupillarySeparation)
            yLeftScreen  = Yi * zDistanceOfVergencePlaneFromViewer / Zi;
            yRightScreen = yLeftScreen;
                        
            xLeftScreen  = (zDistanceOfVergencePlaneFromViewer*Xi + 0.5*interPupillarySeparation*(zDistanceOfVergencePlaneFromViewer - Zi)) / Zi;
            xRightScreen = (zDistanceOfVergencePlaneFromViewer*Xi - 0.5*interPupillarySeparation*(zDistanceOfVergencePlaneFromViewer - Zi)) / Zi;           
        end
        
        % Function to covert screen coordinates on the vergence plane onto virtual X,Y,Z coordinates.
        % The units of all variables are centimeters
        function [Xi, Yi, Zi] = screenCoordsToVirtualXYZposition( xLeftScreen, yLeftScreen, xRightScreen, yRightScreen, zDistanceOfVergencePlaneFromViewer, interPupillarySeparation)
            screenDisparity = xRightScreen - xLeftScreen;
            Xi = 0.5 * (xRightScreen + xLeftScreen) * interPupillarySeparation / (interPupillarySeparation - screenDisparity);
            Yi = 0.5 * (yRightScreen + yLeftScreen) * interPupillarySeparation / (interPupillarySeparation - screenDisparity);
            Zi = zDistanceOfVergencePlaneFromViewer * interPupillarySeparation / (interPupillarySeparation - screenDisparity);
        end
        
        
    end  % (Static methods)
    
end

