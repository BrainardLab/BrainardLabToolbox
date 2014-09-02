function AlignGrid(screenID)

    % Access to the GamePadStuff
    addpath(genpath(pwd));
    
    if (nargin < 1)
        screenID = max(Screen('Screens'));
        whichScreen = 'Right';
    end
    
    % Generate cal filename
    calFileName = sprintf('StereoHDRWarp-%s', whichScreen);
    
    % Colors setup
    backgroundColor             = [0.0 0.0 0.0];
    gridColor                   = [0.1 0.3 0.9];
    gridDistortionTracesColor   = [0.3 0.6 0.6];
    gridNodesColor              = [0.3 0.8 1.0];
    activeNodeColor             = [1.0 0.0 0.4];

    % Set unified keymappings and normalized color range:
    PsychDefaultSetup(2);
    
    % Disable sync tests for this simple demo to speed up the whole thing:
    oldsynctest = Screen('Preference','SkipSyncTests', 2);
    
    % Get screen configuration: res, bitdepth, and refresh rate
    screenConfig = Screen('Resolution', screenID);
    
    % Generate nominal grid
    nodeSpacingInPixels = 60;
    [Xnominal,Ynominal] = GenerateNominalGrid(nodeSpacingInPixels, screenConfig.width, screenConfig.height);
    
    % Go!
    gamePad = [];
    try   
        % Prepare pipeline for configuration. This marks the start of a list of
        % requirements/tasks to be met/executed in the pipeline:
        PsychImaging('PrepareConfiguration');
    
        % Ask pipeline to horizontally flip/mirror the output image
        % (mirror optics flip the monitor horizontally, so this undoes
        % the mirror-induced flipping)
        %PsychImaging('AddTask', 'AllViews', 'FlipHorizontal');
    
        % apply warping on the final frame buffer right before rendering it
        % PsychImaging('AddTask', 'AllViews', 'GeometryCorrection', calibStruct);
        
        % Open a fullscreen window, with a background color:
        windowPtr = PsychImaging('OpenWindow', screenID, backgroundColor);
     
        % Set up alpha-blending for smooth (anti-aliased) lines
        Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
        % Instantiate a gamePad object for interactive control of grid nodes
        gamePad = GamePad();
    
        % Align grid
        [Xdistorted, Ydistorted] = InteractivelyAlignCalibrationGrid(gamePad, windowPtr, Xnominal, Ynominal, gridColor, gridDistortionTracesColor, gridNodesColor, activeNodeColor);
    
        % Save calibration struct
        GenerateAndSaveUnwarpCalibrationStructure(screenConfig.width, screenConfig.height, Xnominal, Ynominal, Xdistorted, Ydistorted, calFileName);
                            
        % Reenable Matlab's keyboard handling:
        ListenChar(0);
        
        % Close all displays
        sca;
        
        % shutdown the gamePad object
        gamePad.shutDown();
   
        
        fprintf('Run ''VisualizeUnwarpCalibration'' to visualize the warp calibration.\n');
        
    catch err
        % Reenable Matlab's keyboard handling:
        ListenChar(0);
        
        % Close all displays
        sca;
        
        % hutdown the gamePad object (if it was opened)
        if ~isempty(gamePad)
            gamePad.shutDown();
        end
        
        rethrow(err);
    end   
end

