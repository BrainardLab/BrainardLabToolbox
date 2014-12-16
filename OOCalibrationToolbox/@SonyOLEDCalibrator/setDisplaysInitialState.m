function setDisplaysInitialState(obj)

    fprintf('In SonyOLEDCalibrator.setDisplayInitialState()\n');
    
    % opening a full-screen window
    screenRect = []; 

    % Specify pixelSize (30 for 10-bit color, 24 for 8-bit color)
    pixelSize = 24;
        
    % Initial background color
    bgColor = [0.25 0.25 0.25];
    
    try
        % Disable syncing, we do not care for this kind of calibration (regular
        % single screen, not stereo, not Samsung)
        Screen('Preference', 'SkipSyncTests', 2);
    
        screenID = max(Screen('Screens'));
    
        % Start PsychImaging for master window
        PsychImaging('PrepareConfiguration');
        [obj.masterWindowPtr, obj.screenRect] = ...
            PsychImaging('OpenWindow', screenID, 255*bgColor, screenRect, pixelSize, [], []);
        
        LoadIdentityClut(obj.masterWindowPtr);

        
    catch err    
        % Close everyhting, restore LUTs
        sca;
        rethrow(err);
    end
end

