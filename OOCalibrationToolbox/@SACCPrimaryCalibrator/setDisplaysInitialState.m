function setDisplaysInitialState(obj, userPrompt)

    if (obj.options.verbosity > 9)
        fprintf('In SACCPrimary.setDisplayInitialState()\n');
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

    % Connect to the projector
    isReady = Datapixx('open'); 
    isReady = Datapixx('IsReady');
    
    % Set the initial state as both primary and sub-primary current=0
    for j=1:3 % Primary(0-2)
        for i=1:16 % Sub-primary(0-15)
            Datapixx('SetPropixxHSLedCurrent', j-1, i-1, 0); 
        end
    end
    
    % [SEMIN]
    % Put here any code required to initialize the subprimaries. 
    switch (obj.whichPrimary)
        case 1
            % Turn off subprimaries for primaries 2 and 3, turn on all
            % subprimaries for primary 1.
            current_on=252;
            current_off=0;
            for i=1:16 % Sub-primary
                Datapixx('SetPropixxHSLedCurrent', 0, i-1, current_on); % Primary 1
                Datapixx('SetPropixxHSLedCurrent', 1, i-1, current_off); % Primary 2
                Datapixx('SetPropixxHSLedCurrent', 2, i-1, current_off); % Primary 3
            end
                        
        case 2
            % Turn off subprimaries for primaries 1 and 3, turn on all
            % subprimaries for primary 2.
            current_on=252;
            current_off=0;
            for i=1:16 % Sub-primary
                Datapixx('SetPropixxHSLedCurrent', 0, i-1, current_off); % Primary 1
                Datapixx('SetPropixxHSLedCurrent', 1, i-1, current_on); % Primary 2
                Datapixx('SetPropixxHSLedCurrent', 2, i-1, current_off); % Primary 3
            end
            
        case 3
            % Turn off subprimaries for primaries 1 and 2, turn on all
            % subprimaries for primary 3.
            current_on=252;
            current_off=0;
            for i=1:16 % Sub-primary
                Datapixx('SetPropixxHSLedCurrent', 0, i-1, current_off); % Primary 1
                Datapixx('SetPropixxHSLedCurrent', 1, i-1, current_off); % Primary 2
                Datapixx('SetPropixxHSLedCurrent', 2, i-1, current_on); % Primary 3
            end
            
        otherwise
            error('SACC display has only three primaries');
    end

    % Decide whether LEDs should be in "normal" mode or "steady" mode
    if (obj.normalMode)
        % Put LEDs in normal mode
    else
        % Put LEDs in steady mode

    end

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