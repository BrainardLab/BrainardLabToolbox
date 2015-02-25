function StereoViewToy

    rootDirectory = pwd;

    % Configure the stereo pair struct
    stereoPair = struct(...
    	'stimulusSource', 'matrix', ...
    	'imageData', struct(...  
                    'left',  [], ...
                    'right', [] ...
                    ),...
        'imagePosition', [0 0], ...
    	'imageSize', [48.18 36.13] ...  % change dimensions to appropriate size (this is in pixels)
        );
    
    % Type in the left,right pairs of stimuli you want to examine
    fileSequence = {...
        {'DepthDemo1L-RGB', 'DepthDemo1R-RGB'}, ...  % pair 1
        {'DepthDemo2L-RGB', 'DepthDemo2R-RGB'}, ...  % pair 2
        {'DepthDemo3L-RGB', 'DepthDemo3R-RGB'} ...   % pair 3
        };
    
    % set to first pair
    fileIndex = 1;

    try    
        stereoCalibrationInfo = struct;
        stereoCalibrationInfo.displayPosition           = {'left', 'right'};
        stereoCalibrationInfo.spectralFileNames         = {'StereoLCDLeft', 'StereoLCDRight'};
        stereoCalibrationInfo.warpFileNames             = {'StereoWarp-Radiance-left', 'StereoWarp-Radiance-right'};
        stereoCalibrationInfo.interOcularDistanceInCm   = 6.4;                      % needed to compute the asymmetric OpenGL frustum
        stereoCalibrationInfo.sceneDimensionsInCm       = [51.7988 32.3618 76.4];   % 3rd param is needed to compute the asymmetric OpenGL frus

        % No stringent calibration check
        performStringentCalibrationChecks = false;
        
        stereoView = [];
        stereoView = StereoViewController( 'stereo view tool', ...
                                           stereoCalibrationInfo, ...
                                           performStringentCalibrationChecks, ...
                                           'beVerbose', true);
        
        if (stereoView.isInitialized == false)
            disp('The StereoView object failed to initialize. Exiting now ... ');
            resetEnvironment(rootDirectory);
            return;
        end
        
        % make the cursor visible
        stereoView.setCursorVisibility(true);
        
        % Start listening for key presses, while suppressing any
        % output of keypresses on the command window
        ListenChar(2); FlushEvents; 
        
        exitLoop = false;
        while (~exitLoop) 
            
            % Check for keypresses (only caring about quit button for now)
            key = mglGetKeyEvent;
            
            if (~isempty(key))   
                 switch key.keyCode
                     
                     case 13  % quit - exit loop
                         exitLoop = true; 
                         
                     case 37  % enter
                         
                         % fetch data from the sequence
                         [stereoPair.imageData.left, stereoPair.imageData.right] = ...
                             fetchStereoImageData(fileSequence{fileIndex}{1}, fileSequence{fileIndex}{2});

                         % Show the next stereoPair in the rendering pipeline
                         stereoView.setStereoPair(stereoPair);
                         stereoView.showStimulus();
                         
                         Speak(sprintf('%d', fileIndex));
                         
                         fileIndex = fileIndex + 1;
                         if (fileIndex > numel(fileSequence))
                             fileIndex = 1;
                         end
                 end
            end
        end % while (~exitLoop) 
        
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

function [leftImageData, rightImageData] = fetchStereoImageData(leftImageFileName, rightImageFileName)

    leftImageFile  = fullfile('StereoPairsRepository', leftImageFileName);
    rightImageFile = fullfile('StereoPairsRepository', rightImageFileName);
    d = load(leftImageFile);  leftImageData  = flipdim(d.sensorImageLeftRGB,1);
    d = load(rightImageFile); rightImageData = flipdim(d.sensorImageRightRGB,1);
end

function resetEnvironment(rootDirectory)
    ListenChar(0);
    mglSwitchDisplay(-1);
    mglDisplayCursor(1);
    mglSetMousePosition(512, 512, 1);
    cd(rootDirectory);
end