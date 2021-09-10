function setDisplaysInitialState(obj, userPrompt)

    if (obj.options.verbosity > 9)
        fprintf('In PsychImaging.setDisplayInitialState()\n');
    end
    
    % Make a local copy of obj.cal so we do not keep calling it and regenerating it
    calStruct = obj.cal;
    
    %  Get identity clut if useBitsPP is enabled
    if ((calStruct.describe.useBitsPP) && (isempty(obj.identityGammaForBitsPP)))
        error('Support for bitsPP has not been implemented in @PsychImagingCalibrator !');
    end % if (calStruct.config.useBitsPP)
    
    
    % Specify stereo mode 10 for synchronized flips between left/right displays
    stereoMode = []; % 10; 
    
    % Following for opening a full-screen window
    screenRect = []; 
    
    % Specify pixelSize (30 for 10-bit color, 24 for 8-bit color)
    pixelSize = 24;
    
    
    % Disable syncing, we do not care for this kind of calibration (regular
    % single screen, not stereo, not Samsung)
    Screen('Preference', 'SkipSyncTests', 1);
    
    % Conserve VideoRam (this is crucial for M1-based Macs)
    Screen('Preference','ConserveVRAM',16384);
    
    % Start PsychImaging
    PsychImaging('PrepareConfiguration');
    
    % Open master display (screen to be calibrated)
    [obj.masterWindowPtr, obj.screenRect] = ...
        PsychImaging('OpenWindow', calStruct.describe.whichScreen-1, 255*calStruct.describe.bgColor, screenRect, pixelSize, [], stereoMode);
    LoadIdentityClut(obj.masterWindowPtr);
    
    % Blank other screen. 
    if calStruct.describe.blankOtherScreen
        
        [obj.slaveWindowPtr, ~] = ...
            PsychImaging('OpenWindow', calStruct.describe.whichBlankScreen-1, 255*calStruct.describe.blankSettings, [], pixelSize, [], stereoMode);
        
        LoadIdentityClut(obj.slaveWindowPtr);
        Screen('Flip', obj.slaveWindowPtr);    
    end  % blackOtherScreen
    
    % white square for user to focus the spectro-radiometer
    targetSettings = [1 1 1];
    obj.updateBackgroundAndTarget(calStruct.describe.bgColor, targetSettings, calStruct.describe.useBitsPP)    
 
    % When doing calibration with the SpectroCAL, turn the laser on
    if strcmp(class(obj.radiometerObj), 'SpectroCALdev')
       obj.radiometerObj.switchLaserState(1); 
    end
    
    % Wait for user
    if (userPrompt)
        fprintf('\nHit enter when ready ...');
        FlushEvents;
        GetChar;
        if strcmp(class(obj.radiometerObj), 'SpectroCALdev')
            obj.radiometerObj.switchLaserState(0);
        end
        fprintf('\n\n-------------------------------------------\n');
        fprintf('\nPausing for %d seconds ...', calStruct.describe.leaveRoomTime);
        WaitSecs(calStruct.describe.leaveRoomTime);
        fprintf(' done\n');
        fprintf('\n-------------------------------------------\n\n');
    end
    
end