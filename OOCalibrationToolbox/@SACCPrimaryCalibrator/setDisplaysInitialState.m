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

% Retrieve passed custom params
if (~isempty(obj.options.calibratorTypeSpecificParamsStruct))
    % SACC Subprimary calibration settings
    obj.whichPrimary = obj.options.calibratorTypeSpecificParamsStruct.whichPrimary;   
    obj.nSubprimaries = obj.options.calibratorTypeSpecificParamsStruct.nSubprimaries;
    obj.nInputLevels = obj.options.calibratorTypeSpecificParamsStruct.nInputLevels;
    obj.normalMode = obj.options.calibratorTypeSpecificParamsStruct.normalMode;
    obj.arbitraryBlack = obj.options.calibratorTypeSpecificParamsStruct.arbitraryBlack;
    obj.logicalToPhysical = obj.options.calibratorTypeSpecificParamsStruct.logicalToPhysical;
end

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

% Retrieve passed custom params
if (~isempty(obj.options.calibratorTypeSpecificParamsStruct))
    % Background settings
    backgroundSettings = obj.options.calibratorTypeSpecificParamsStruct.DLPbackgroundSettings;
else
    backgroundSettings = [1 1 1];    
end
    
% Open master display (screen to be calibrated)
[obj.masterWindowPtr, obj.screenRect] = ...
    PsychImaging('OpenWindow', calStruct.describe.whichScreen-1, 255*backgroundSettings, screenRect, pixelSize, [], stereoMode);
LoadIdentityClut(obj.masterWindowPtr);

% Blank other screen.
if calStruct.describe.blankOtherScreen
    
    [obj.slaveWindowPtr, ~] = ...
        PsychImaging('OpenWindow', calStruct.describe.whichBlankScreen-1, 255*calStruct.describe.blankSettings, [], pixelSize, [], stereoMode);
    
    LoadIdentityClut(obj.slaveWindowPtr);
    Screen('Flip', obj.slaveWindowPtr);
end  % blackOtherScreen

% white square for user to focus the spectro-radiometer
%     targetSettings = [1 1 1];
targetSettings = ones(1,obj.nSubprimaries); % Setting for SACC Subprimary calibration (Semin)

obj.updateBackgroundAndTarget(backgroundSettings, targetSettings, calStruct.describe.useBitsPP)

% Connect to the projector
isReady = Datapixx('open');
isReady = Datapixx('IsReady');

% Set the initial state as both primary and sub-primary current=0
for j=1:obj.nPrimaries % Primary(1-3)
    for i=1:obj.nSubprimaries % Sub-primary(0-nSubprimaries)
        Datapixx('SetPropixxHSLedCurrent', j-1, obj.logicalToPhysical(i), 0);
    end
end

% Put here any code required to initialize the subprimaries.
if (length(obj.logicalToPhysical) ~= obj.nSubprimaries)
    error('Mismatch in number of subprimaries specificaiton and logical to physical array');
end
current_on=obj.nInputLevels;
current_off=0;
switch (obj.whichPrimary)
    case 1
        % Turn off subprimaries for primaries 2 and 3, turn on all
        % subprimaries for primary 1.
        
        for i=1:obj.nSubprimaries % Sub-primary
            Datapixx('SetPropixxHSLedCurrent', 0, obj.logicalToPhysical(i), current_on); % Primary 1
            Datapixx('SetPropixxHSLedCurrent', 1, obj.logicalToPhysical(i), current_off); % Primary 2
            Datapixx('SetPropixxHSLedCurrent', 2, obj.logicalToPhysical(i), current_off); % Primary 3
        end
        
    case 2
        % Turn off subprimaries for primaries 1 and 3, turn on all
        % subprimaries for primary 2.
        for i=1:obj.nSubprimaries % Sub-primary
            Datapixx('SetPropixxHSLedCurrent', 0, obj.logicalToPhysical(i), current_off); % Primary 1
            Datapixx('SetPropixxHSLedCurrent', 1, obj.logicalToPhysical(i), current_on); % Primary 2
            Datapixx('SetPropixxHSLedCurrent', 2, obj.logicalToPhysical(i), current_off); % Primary 3
        end
        
    case 3
        % Turn off subprimaries for primaries 1 and 2, turn on all
        % subprimaries for primary 3.
        for i=1:obj.nSubprimaries % Sub-primary
            Datapixx('SetPropixxHSLedCurrent', 0, obj.logicalToPhysical(i), current_off); % Primary 1
            Datapixx('SetPropixxHSLedCurrent', 1, obj.logicalToPhysical(i), current_off); % Primary 2
            Datapixx('SetPropixxHSLedCurrent', 2, obj.logicalToPhysical(i), current_on); % Primary 3
        end
        
    otherwise
        error('SACC display has only three primaries');
end

% Decide whether LEDs should be in "normal" mode or "steady" mode
if (obj.normalMode)
    % Put LEDs in normal mode
    commandNormal = 'vputil rw 0x1c8 0x0 -q quit'; 
    unix(commandNormal)
else
    % Put LEDs in steady mode   
    commandSteady = 'vputil rw 0x1c8 0x7 -q quit'; 
    unix(commandSteady)
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