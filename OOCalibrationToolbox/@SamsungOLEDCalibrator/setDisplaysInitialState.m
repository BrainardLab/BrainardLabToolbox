function setDisplaysInitialState(obj)

    fprintf('In SamsungOLEDCalibrator.setDisplayInitialState()\n');
    
    % mode for ??
    stereoMode = 2;
    
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
    
        rightHalfScreenID = max(Screen('Screens'));
        leftHalfScreenID  = rightHalfScreenID-1;
    
        % Start PsychImaging for master window
        PsychImaging('PrepareConfiguration');
        [obj.masterWindowPtr, obj.screenRect] = ...
            PsychImaging('OpenWindow', rightHalfScreenID, 255*bgColor, screenRect, pixelSize, [], stereoMode);
        
        SamsungOLEDCalibrator.convertOverUnderParamsToSideBySideParameters(obj.masterWindowPtr);
        LoadIdentityClut(obj.masterWindowPtr);

        % Start PsychImaging for slave window
        PsychImaging('PrepareConfiguration');
        [obj.slaveWindowPtr, ~] = ...
                PsychImaging('OpenWindow', leftHalfScreenID, 255*bgColor, [], pixelSize, [], stereoMode);
            
        SamsungOLEDCalibrator.convertOverUnderParamsToSideBySideParameters(obj.slaveWindowPtr);
        LoadIdentityClut(obj.masterWindowPtr);
        
    catch err    
        % Close everyhting, restore LUTs
        sca;
        rethrow(err);
    end
end

