function VisualizeUnwarpCalibration(screenID)

    % Access to the GamePadStuff
    addpath(genpath(pwd));
    
    if (nargin < 1)
        screenID = max(Screen('Screens'));
    end
    
    % Filename with calibration struct to visualize
    calFileName = 'StereoHDRWarp-Right';
    [cal,calFileName] = GetCalibrationStructure('Calibration file name to open',calFileName,[]);
    
    % Test image to load
    testImageFileName = '/Users/nicolas/Desktop/P&D1920x1080.jpg';
    
    % Generate a double RGB matrix from it
    imageRGMmatrix = double(imread(testImageFileName));
    % Normalize pixel values in [0 .. 1]
    imageRGMmatrix = imageRGMmatrix / 255;
    
    % Set unified keymappings and normalized color range:
    PsychDefaultSetup(2);
    
    % Disable sync tests for this simple demo to speed up the whole thing:
    Screen('Preference','SkipSyncTests', 2);
    
    % No verbosity
    Screen('Preference', 'Verbosity', 0);
    
    % Get screen configuration: res, bitdepth, and refresh rate
    screenConfig = Screen('Resolution', screenID);
  
    try
        % Prepare pipeline for configuration. This marks the start of a list of
        % requirements/tasks to be met/executed in the pipeline:
        PsychImaging('PrepareConfiguration');
    
        % Ask pipeline to horizontally flip/mirror the output image
        % (mirror optics flip the monitor horizontally, so this undoes
        % the mirror-induced flipping)
        PsychImaging('AddTask', 'AllViews', 'FlipHorizontal');
    
        % apply warping on the final frame buffer right before rendering it
        PsychImaging('AddTask', 'AllViews', 'GeometryCorrection', cal.warpParams);
        
        % Open a fullscreen window, with a green background color:
        backgroundColor = [0.0 1.0 0.0];
        windowPtr = PsychImaging('OpenWindow', screenID, backgroundColor);
     
        % Set up alpha-blending for smooth (anti-aliased) lines
        Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
        % Generate texture from the imageRGMmatrix
        optimizeForDrawAngle = []; specialFlags = []; floatprecision = 2;
        texturePointer = Screen('MakeTexture', windowPtr, imageRGMmatrix, optimizeForDrawAngle, specialFlags, floatprecision);

        % Draw Texture
        sourceRect = []; destRect = []; rotationAngle = 0; filterMode = []; globalAlpha = 1.0;
        Screen('DrawTexture', windowPtr, texturePointer, sourceRect, destRect, rotationAngle, filterMode, globalAlpha);
        
        % Some centered text for illustration...
        textString = '\n\n\n\n< - - -  H e l l o   W o r l d ! - - - > \nI n   W a r p   S p a c e .\nP r e s s   k e y   t o   c o n t i n u e .';
        textColor = [0.0, 0.0, 1.0];
        
        % Set font size
        Screen('TextSize', windowPtr, 96);
        
        % Draw the text
        DrawFormattedText(windowPtr, textString, 'center', 'center', textColor);
    
        % Show unwarped image
        Screen('Flip',  windowPtr, []);
    
        disp('Hit enter to exit');
        pause;
        
        % Close all displays
        sca;
        
    catch err
        % Close all displays
        sca; 
        rethrow(err);
    end   
end

