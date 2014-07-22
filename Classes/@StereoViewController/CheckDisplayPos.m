function CheckDisplayPos
% Demo code to check display position using the  StereoViewController class.
%
% 7/16/2013     npc     Wrote it
%

    % Clear everything
    clc; clear all; clear Classes; close all; ClockRandSeed;
    
    % Always use Classes-Dev
    UseClassesDev;
    
    % Set the root directory and add its subdirectories to the path
    rootDirectory = pwd;
    genpath(rootDirectory);
    
    
    % No stringent calibration check
    performStringentCalibrationChecks = false;
    
    % Configure the stereo calibration struct
    stereoCalibrationInfo = struct;
    stereoCalibrationInfo.displayPosition           = {'left', 'right'};
    stereoCalibrationInfo.spectralFileNames         = {'StereoLCDLeft', 'StereoLCDRight'};
    stereoCalibrationInfo.warpFileNames             = {'StereoWarp-Radiance-left', 'StereoWarp-Radiance-right'};
    stereoCalibrationInfo.interOcularDistanceInCm   = 6.4;                      % needed to compute the asymmetric OpenGL frustum
    stereoCalibrationInfo.sceneDimensionsInCm       = [51.7988 32.3618 76.4];   % 3rd param is needed to compute the asymmetric OpenGL frus
    
    
 
    % Configure a stereo pair stimulus and its targets
    stereoPair  = struct;
    
    % Flag to let the StereoViewController that the images are to be loaded
    % from files. These names must be specified in stereoPair.imageNames
    stereoPair.stimulusSource       = 'matrix';
    N = 1024;
    stereoPair.imageData.left  = rand(N,N,3);
    stereoPair.imageData.right = rand(N,N,3);
    stereoPair.imagePosition = [0 0];
    stereoPair.imageSize = [N N];  
    
   
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
            resetEnvironment(rootDirectory);
            return;
        end
        
        stereoView.printState;     
             
        % Add the stereoPair in the rendering pipeline
        stereoView.setStereoPair(stereoPair);         
  
        
        stereoView.showStimulus();
        mglFlush();
        
        
        
        stereoView.checkScreenAssignment('left');
        stereoView.checkScreenAssignment('right');

        
        disp('Hit enter to exit');
        pause;
        
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

