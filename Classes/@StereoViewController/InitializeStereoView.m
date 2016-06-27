function obj = InitializeStereoView(obj)
% InitializeStereoView
% Method to initialze the StereoViewController by setting a stereo GLWindow
% 
% Syntax:
% obj = obj.InitializeStereoView
%
% 3/15/2013  npc   Wrote it.
%
    error(nargchk(1, 1, nargin));
    
    if (obj.isInitialized == false)
        
        obj.stereoDisplayConfiguration = obj.stereoCalibrationInfo;
    
        % promote to full configuration by adding more display information
        sD = mglDescribeDisplays;
        load('screenNumberAssigment.mat');
        obj.stereoDisplayConfiguration.screenID.left = screens.left;
        obj.stereoDisplayConfiguration.screenID.right = screens.right; 
     
        obj.stereoDisplayConfiguration.screenData{1} = sD(obj.stereoDisplayConfiguration.screenID.left);
        obj.stereoDisplayConfiguration.screenData{1}.displayPosition = obj.stereoCalibrationInfo.displayPosition{1};
        
        obj.stereoDisplayConfiguration.screenData{2} = sD(obj.stereoDisplayConfiguration.screenID.right);
        obj.stereoDisplayConfiguration.screenData{2}.displayPosition = obj.stereoCalibrationInfo.displayPosition{2};
     
        calibrationIsOK = CheckCalibrationFiles(obj);
        if (~calibrationIsOK)
            return;
        end

        % Determine the actual screen coordinates that correspond to node (0,0)
        % These are used to place the mouse at a desired screen location
        for whichScreen = 1:2
            obj.stereoDisplayConfiguration.screenData{whichScreen}.originInCm = DetermineScreenOrigins(obj, whichScreen);
        end
        
        % Stuff we need for the 3D cursor
        % This setups up some OpenGL constants in the Matlab environment.
        global GL;
    
        % Initialize the OpenGL for Matlab wrapper 'mogl'.
        InitializeMatlabOpenGL;
    
        % Construct a stereo GLWindow
        try 
            obj.stereoGLWindow = [];
            
            % Construct our stereo GLWindow
            obj.stereoGLWindow = GLWindow(  'DisplayType',          'Stereo', ...
                                            'Multisampling',        true, ...
                                            'WindowID',             obj.stereoDisplayConfiguration.screenID, ...
                                            'noWarp',               obj.noFrameBufferWarping, ...
                                            'WarpFile',             obj.stereoDisplayConfiguration.warpFileNames, ...
                                            'InterocularDistance',  obj.stereoDisplayConfiguration.interOcularDistanceInCm, ...  
                                            'SceneDimensions',      obj.stereoDisplayConfiguration.sceneDimensionsInCm);         
                
            % Open the stereo GLWindow
            obj.stereoGLWindow.open;
             
            % construct a mouse object (so we can read the mouse coords)
            obj.mouseDev = Mouse();
            
            % Hide the mouse pointer
            mglDisplayCursor(0);
            
        catch e
            rethrow(e);
            if (~isempty(obj.stereoGLWindow))
                obj.stereoGLWindow.close; 
            end
            resetEnvironment();
            obj.isInitialized = false;
            return;
        end
            
        % Make a note that the controller has been initialized.
        obj.isInitialized = true;
    end 
end

function originInCm = DetermineScreenOrigins(obj, whichScreen)
    warpFileName = obj.stereoDisplayConfiguration.warpFileNames{whichScreen};
    cal = LoadCalFile(warpFileName);  
    % find which (row,col) corresponds to node at (0,0)
    xCoords = cal.warpParams(end).nominalGrid(:,:,1);
    yCoords = cal.warpParams(end).nominalGrid(:,:,2);
    [row,col] = find((xCoords == 0) & (yCoords == 0));
    % get the actual grid params for the (0,0) node
    xo = cal.warpParams(end).actualGrid(row,col,1) + cal.warpParams(end).translation(1);
    yo = cal.warpParams(end).actualGrid(row,col,2) + cal.warpParams(end).translation(2);
    originInCm = [xo yo];
end

        
        
function resetEnvironment
    ListenChar(0);
    mglSwitchDisplay(-1);
    mglDisplayCursor(1);
    mglSetMousePosition(512, 512, 1);
end
