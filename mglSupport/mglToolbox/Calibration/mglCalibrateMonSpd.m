function mglCalibrateMonSpd
% mglCalibrateMonSpd
%
% Calling script for monitor calibration.  Assumes
% you have CMCheckInit/MeasSpd functions that initialize
% measurement hardware and return a measured spectral
% power distribution respectively.
%
% Meter type definitions
%    0 - Fake meter, for debugging
%    1 - PR-650
%
% 7/7/98  dhb  Wrote from generic.
%         dhb  dacsize/driver filled in by hand, Screen fails to return it.
% 4/7/99  dhb  NINEBIT -> NBITS.
%         dhb  Wrote version for Radius 10 bit cards.
% 4/23/99 dhb  Change wavelength sampling to 380 4 101, PR-650 native.
% 9/22/99 dhb, mdr  Define boxSize.
% 8/11/00 dhb  Save mon in rawdata.
% 8/18/00 dhb  More descriptive information saved.
% 8/20/00 dhb  Automatic check for RADIUS and number of DAC bits.
% 9/10/00 pbe  Added option to blank another screen while measuring.
% 2/27/02 dhb  Various small fixes, including Radeon support.
%         dhb  Change noMeterAvail to whichMeterType.
% 11/08/06 cgb, dhb  OS/X.
% 11/25/09 dhb Allow calibration for each gun to happen around an operating point.
% 11/25/09 dhb Rig specific calibration info can be chosen and set without as much prompting
% 11/29/09 dhb Pass usebitspp to called routines.
%          dhb Debug this sucker
% 12/8/09  dhb, tyl  Add line for Thomas's experiment
% 12/11/09 dhb Entries for AchromForcedChoice experiment
% 1/21/10  dhb Beep at end so we know it is done.
% 2/12/10  dhb This just prompts, then calls mglCalibrateMonCommon.
%          dhb blankOtherScreen now part of cal.describe structure.
% 3/5/10   dhb Add HDRBackRGB option.
% 6/8/10   tyl, ek Add line for Erika's experiment (FrontRoomObjColorMatching)
% 8/19/10  tyl Added options for DistribDiscrim4, i.e. StereoRigLeftClass and StereoRigRightClass
% 9/7/10   dhb Add prompt for boxSize in generic thread.  Added a few GetWithDefault()'s to simplify code.
% 9/11/10  dhb Changed the StereoRig... entries to use crtGamma rather than crtPolyLinear, and nAverage = 2.
% 1/10/11  dhb Email notifiation for FrontRoomLex.
% 1/11/11  tyl Added email notification for StereoRigLeftClass,
%			   StereoRigRightClass, and FrontRoomClass
% 2/3/11   dhb Update background/foreground settings for FrontRoomLex
% 5/19/11  tyl Added case for StereoLCDRight
% 6/22/11  dhb, tyl Allow specification of boxOffsetX and Y.  Set to 0 by default if not specified in a particular case.
%              This is useful for checking off-axis monitor properties.
% 6/24/11  dhb Fit stereo LCD calibration gamma using simple power function.
% 11/8/11  tyl Changed StereoLCDLeft to screen 4 and StereoLCDRight to
%              screen 3, to account for adding the slider screen (2) to the setup.
% 6/8/12  ar   Made the new case of the Eye Tracker (EyeTrackerTest) to test
%              the effect of bits++ box being set to zero.
% 10/8/13 ar   Made new case for the SquidNEC display. 
% 10/16/13 ar  Made new case for the new EyeTrackerLCD
% 04/20/16 ar  Made new case for new eye tracking display. 

% We could make this email the user that the calibration is done.
% Apparently the codelet something like the following will do the trick,
% and could be set up with a different email address for address for each
% relevant user.
%     setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
%     setpref('Internet', 'E_Mail', 'radonjic@sas.upenn.edu');
%     sendmail('radonjic@sas.upenn.edu', 'HDR Calibration Complete', 'I am done.');

global g_useIOPort

% On 64 bit Matlab setups, we can't use IOPort because it's only 32 bit.
% This will flag the calibration routines to use SerialComm which has been
% compiled for 64 bit and exists in PTBOverrides.
if strcmp(computer, 'MACI64')
    g_useIOPort = 1;
end

% Clear and close
clear; close all;

% Create calibration structure;
cal = [];

%% Set meter type. This is the default
% but can be overridden by specific cases
% below, which are set up for debugging.
whichMeterType = 1;
fprintf('Available meter types:\n');
fprintf('\t0 - meter emulation, just for testing\n');
fprintf('\t1 - PR-650\n');
fprintf('\t4 - PR-655\n');
fprintf('\t5 - PR-670\n');
whichMeterType = GetWithDefault('Enter meter type',whichMeterType);

% Script parameters
switch whichMeterType
    case {0,1,4}
        cal.describe.S = [380 4 101];
    case 2
        cal.describe.S = [380 1 401];
    case 5
        cal.describe.S = [380 2 201];
    otherwise
        error('Unknown meter type entered');
end
cal.manual.use = 0;

% Determine what type of calibration we're doing.
while true
    defaultCalibrationType = 'Generic';
    fprintf('Calibration types supported\n');
    fprintf('\tViewSonicProbe - Nicolas'' office ViewSonic monitor\n');
    fprintf('\tSamsungOLED240Hz - Samsung OLED 240 Hz panel\n');
    fprintf('\tGeneric - any monitor or device\n');
    fprintf('\tEyeTracker - EyeTracker experiments\n');
    fprintf('\tEyeTrackerTest - EyeTracker: testing the bits++ options\n');
    fprintf('\tSquidNEC - NEC monitor for Lightness V4 experiments \n');
    fprintf('\tEyeTrackerLCD - new NEC monitor for EyeTracker (after Oct 2013) \n');
    fprintf('\tFrontRoomLex - Bits++ lexical/color experiments\n');
    fprintf('\tFrontRoomClass - Bits++ lightness classification experiments\n');
    fprintf('\tStereoRigLeftAchrom - Bits++ left monitor, CRT stereo rig\n');
    fprintf('\tStereoRigRightAchrom - Bits++ right monitor, CRT stereo rig\n');
    fprintf('\tHDRBackRGB - HDR projector, calibration RGB separately\n');
    fprintf('\tFrontRoomObjColor - CRT/Bits++ rig\n');
    fprintf('\tStereoRigLeftClass - Bits++ left monitor, CRT stereo rig, lightness classification experiments\n');
    fprintf('\tStereoRigRightClass - Bits++ right monitor, CRT stereo rig, lightness classification experiments\n');
    fprintf('\tDummy - Dummy calibration file to test program, without meter\n');
    fprintf('\tDummyBits - Dummy calibration file to test program, without meter, with bits++ß\n');
    fprintf('\tStereoLCDRight - right monitor, LCD stereo rig\n');
    fprintf('\tStereoLCDLeft - left monitor, LCD stereo rig\n');
    fprintf('\tBoldDisplay - ColorMaterial exp, HDR room\n');
    fprintf('\tEyeTrackerLCDNew - Illum Discrimination, NEC 24"\n');
    
    calibrationType = input(sprintf('What type of calibration are doing? [%s]: ', ...
        defaultCalibrationType),'s');
    
    % Make sure it's a valid calibration type.
    switch calibrationType
        case {'EyeTrackerLCDNew','BoldDisplay','SamsungOLED240Hz', 'ViewSonicProbe', 'Generic', 'EyeTracker','EyeTrackerTest', 'SquidNEC', 'EyeTrackerLCD', 'FrontRoomLex', 'FrontRoomClass', 'StereoRigRightAchrom', 'StereoRigLeftAchrom', 'HDRBackRGB', 'FrontRoomObjColor', 'StereoRigLeftClass', 'StereoRigRightClass', 'Dummy', 'DummyBits', 'StereoLCDRight','StereoLCDLeft'}
            break;
        otherwise
            fprintf('*** Invalid calibration type, try again\n\n');
    end
end
cal.describe.calibrationType = calibrationType;

% Depending on the calibration type we'll set default background
% differently.
switch calibrationType
    % Lexical experiments, CRT/Bits++ rig
    case 'FrontRoomLex'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.953 0.875 0.834]';
        cal.fgColor = [0.3 ; 0.6 ; 0.5]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'FrontRoomLex';
        cal.describe.comment = 'FrontRoomLex standard';
        newFileName = 'FrontRoomLex';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 85;
        desired.screenSizePixel = [1024 768];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2; %#ok<*NASGU>
        emailToStr = GetWithDefault('Enter email address for done notification','dhb@psych.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        % EyeTracker
    case 'EyeTracker'
        fprintf('Warning! The monitor for eyetracker has changed. This is caling for calibration for the old one!')
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        % this is background for Ana's visual world experiment. Derive from
        % ConstantHue code.
        % this was a yellow background for the Exp1
        % cal.bgColor = [ 0.8347, 0.7735, 0.1266]'; % set to exp background.
        cal.bgColor = [0.6603, 0.5577, 0.4284];
        cal.fgColor = [0.3 ; 0.6 ; 0.5]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'EyeTracker';
        cal.describe.comment = 'EyeTracker';
        newFileName = 'EyeTracker';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 75;
        desired.screenSizePixel = [1280 1024];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 113; % adjusted to the size of the target.
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2; %#ok<*NASGU>
        emailToStr = GetWithDefault('Enter email address for done notification','radonjic@psych.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        % EyeTrackerTest
       case 'EyeTrackerTest'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        % this is background for Ana's visual world experiment. Derive from
        % ConstantHue code.
        % this was a yellow background for the Exp1
        % cal.bgColor = [ 0.8347, 0.7735, 0.1266]'; % set to exp background.
        cal.bgColor = [0.6603, 0.5577, 0.4284];
        cal.fgColor = [0.3 ; 0.6 ; 0.5]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'EyeTracker';
        cal.describe.comment = 'EyeTracker';
        newFileName = 'EyeTrackerTest';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 75;
        desired.screenSizePixel = [1280 1024];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++? This is what we're testing. 
        cal.usebitspp = 0;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 113; % adjusted to the size of the target.
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2; %#ok<*NASGU>
        emailToStr = GetWithDefault('Enter email address for done notification','radonjic@psych.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
   
        
       % V4 lightness NEC
       case 'SquidNEC'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        cal.bgColor = [0.7451, 0.7451, 0.7451];
        cal.fgColor = [0 ; 0 ; 0]';
        cal.describe.meterDistance = 0.8;
        cal.describe.monitor = 'SquidNEC';
        cal.describe.comment = 'NEC SV on Squid, after SV cal (see LightnessV4 notes)';
        newFileName = 'SquidNEC';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [2560 1440];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 1.0000e-03;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++? This is what we're testing. 
        cal.usebitspp = 0;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150; % adjusted to the size of the target.
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2; %#ok<*NASGU>
        emailToStr = GetWithDefault('Enter email address for done notification','radonjic@sas.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
     
        
        % New LCD for eyetracking
        case 'EyeTrackerLCD'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        cal.bgColor = [0.7451, 0.7451, 0.7451];
        cal.fgColor = [0 ; 0 ; 0]';
        cal.describe.meterDistance = 0.8;
        cal.describe.monitor = 'EyeTrackerLCD';
        cal.describe.comment = 'New EyeTrackerLCD (after Oct 2013)';
        newFileName = 'EyeTrackerLCD';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1920 1080];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 1.0000e-03;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++? This is what we're testing. 
        cal.usebitspp = 0;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150; % adjusted to the size of the target.
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2; %#ok<*NASGU>
        emailToStr = GetWithDefault('Enter email address for done notification','radonjic@sas.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        % New LCD for eyetracking
        case 'EyeTrackerLCDNew'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        cal.bgColor = [0.7451, 0.7451, 0.7451];
        cal.fgColor = [0 ; 0 ; 0]';
        cal.describe.meterDistance = 0.8;
        cal.describe.monitor = 'EyeTrackerLCDNew';
        cal.describe.comment = 'New EyeTrackerLCD (April 2016)';
        newFileName = 'EyeTrackerLCDNew';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1920 1200];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 1.0000e-03;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++? This is what we're testing. 
        cal.usebitspp = 0;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150; % adjusted to the size of the target.
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2; %#ok<*NASGU>
        emailToStr = GetWithDefault('Enter email address for done notification','radonjic@sas.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        
        % Lightness classification, CRT/Bits++ rig
         % New LCD for eyetracking
        case 'BoldDisplay'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        cal.bgColor = [0.7451, 0.7451, 0.7451];
        cal.fgColor = [0 ; 0 ; 0]';
        cal.describe.meterDistance = 0.7;
        cal.describe.monitor = 'Bold Display';
        cal.describe.comment = 'BoldDisplay for Color Material exp, set up in HDR room';
        newFileName = 'BoldDisplay';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 120;
        desired.screenSizePixel = [1920 1080];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 1.0000e-03;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++? This is what we're testing. 
        cal.usebitspp = 0;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150; % adjusted to the size of the target.
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2; %#ok<*NASGU>
        emailToStr = GetWithDefault('Enter email address for done notification','radonjic@sas.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        % Lightness classification, CRT/Bits++ rig
    case 'FrontRoomClass'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.2 ; 0.2 ; 0.2]';
        cal.fgColor = [0.7 ; 0.7 ; 0.7]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'FrontRoomClass';
        cal.describe.comment = 'FrontRoomClass standard';
        newFileName = 'FrontRoomClass';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 85;
        desired.screenSizePixel = [1024 768];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2;
        emailToStr = GetWithDefault('Enter email address for done notification','thomyle@psych.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        % Object Color Matching experiment, CRT/Bits++ rig
    case 'FrontRoomObjColor'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0. ; 0. ; 0.]';
        cal.fgColor = [0.5 ; 0.5 ; 0.5]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'FrontRoomObjColor';
        cal.describe.comment = 'FrontRoom object color Matching experiment standard';
        newFileName = 'FrontRoomObjColor';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 85;
        desired.screenSizePixel = [1024 768];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtGamma';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 2;
        cal.describe.nMeas = 32;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1;
        emailToStr = GetWithDefault('Enter email address for done notification','kerika@sas.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        sendmail(emailToStr, 'FrontRoomObjColor Calibration Complete', 'I am done.');
        
    case 'StereoRigLeftAchrom'
        whichScreen = 3;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 1;
        cal.describe.whichBlankScreen = 2;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.25 ; 0.25 ; 0.25]';
        cal.fgColor = [0.45 ; 0.45 ; 0.45]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'StereoRigLeftAchrom';
        cal.describe.comment = 'StereoRigLeftAchrom standard';
        newFileName = 'StereoRigLeftAchrom';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 75;
        desired.screenSizePixel = [1152 870];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtGamma';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 2;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1;
        
    case 'StereoRigRightAchrom'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 1;
        cal.describe.whichBlankScreen = 3;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.25 ; 0.25 ; 0.25]';
        cal.fgColor = [0.45 ; 0.45 ; 0.45]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'StereoRigRightAchrom';
        cal.describe.comment = 'StereoRigRightAchrom standard';
        newFileName = 'StereoRigRightAchrom';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 75;
        desired.screenSizePixel = [1152 870];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtGamma';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 2;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1;
        
    case 'HDRBackRGB'
        cal.describe.whichScreen = 3;
        cal.describe.whichBlankScreen = 2;
        cal.describe.blankOtherScreen = 1;
        cal.describe.blankSettings = [1 1 1];
        
        % Because of the hack we are using with the back
        % projector, yoking r=g=b when we do the settings,
        % need to set fgColor to [0 0 0] here.
        cal.bgColor = [190 190 190]'/255;
        cal.fgColor = [0 ; 0 ; 0]';
        
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'HDRBackRGB';
        cal.describe.comment = 'HDR back (projector) screen standard in RGB mode';
        newFileName = 'HDRBackRGB';
        cal.describe.HDRProjector = 0;
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1280 1024];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 200;
        cal.nDevices = 3;
        cal.nPrimaryBases = 2;
        beepWhenDone = 1;
        
        % Lightness classification, Stereo/Bits++ rig left monitor
    case 'StereoRigLeftClass'
        whichScreen = 3;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 1;
        cal.describe.whichBlankScreen = 2;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.2 ; 0.2 ; 0.2]';
        cal.fgColor = [0.7 ; 0.7 ; 0.7]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'StereoRigLeftClass';
        cal.describe.comment = 'StereoRigLeftClass standard';
        newFileName = 'StereoRigLeftClass';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 75;
        desired.screenSizePixel = [1152 870];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtGamma';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 2;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2;
        emailToStr = GetWithDefault('Enter email address for done notification','thomyle@psych.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        % Lightness classification, Stereo/Bits++ rig right monitor
    case 'StereoRigRightClass'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 1;
        cal.describe.whichBlankScreen = 3;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.2 ; 0.2 ; 0.2]';
        cal.fgColor = [0.7 ; 0.7 ; 0.7]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'StereoRigRightClass';
        cal.describe.comment = 'StereoRigRightClass standard';
        newFileName = 'StereoRigRightClass';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 75;
        desired.screenSizePixel = [1152 870];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtGamma';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 2;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2;
        emailToStr = GetWithDefault('Enter email address for done notification','thomyle@psych.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
    case 'Dummy'
        whichMeterType = 0;
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.whichBlankScreen = [];
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.25 ; 0.25 ; 0.25]';
        cal.fgColor = [0.45 ; 0.45 ; 0.45]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'Dummy';
        cal.describe.comment = 'Dummy test cal, no meter';
        newFileName = 'Dummy';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = [];
        desired.screenSizePixel = [];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 1;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1;
        
    case 'DummyBits'
        whichMeterType = 0;
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.whichBlankScreen = [];
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.25 ; 0.25 ; 0.25]';
        cal.fgColor = [0.45 ; 0.45 ; 0.45]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'DummyBits';
        cal.describe.comment = 'Dummy test cal, no meter';
        newFileName = 'DummyBits';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = [];
        desired.screenSizePixel = [];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters
        cal.describe.leaveRoomTime = 1;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1;
        
    case 'ViewSonicProbe'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.whichBlankScreen = 1;
        cal.describe.blankSettings = [0.3962 0.3787 0.4039];
        
        cal.bgColor = [0.3962 0.3787 0.4039];
        cal.fgColor = cal.bgColor;
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'ViewSonicProbe';
        cal.describe.comment = 'Nicolas office Viewsonic';
        newFileName = 'ViewSonicProbe_OldFormat';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1920 1200];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'simplePower';
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 2;
        cal.describe.nMeas = 15;
        cal.describe.boxSize = 150;
        cal.describe.boxOffsetX = 0;
        cal.describe.boxOffsetY = 0;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2;
        emailToStr = GetWithDefault('Enter email address for done notification','cottaris@sas.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
    case 'SamsungOLED240Hz'
        whichScreen = 1;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.whichBlankScreen = 2;
        cal.describe.blankSettings = [0.25 0.25 0.25];
        
        cal.bgColor = [0.3962 0.3787 0.4039];
        cal.fgColor = cal.bgColor;
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'SamsungOLED240Hz';
        cal.describe.comment = 'SamsungOLED240Hz measured via mglCalibrateMonSpd';
        newFileName = 'SamsungOLED240Hz_via_mlgCalibrateMonSpd';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1920 1200];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'simplePower';
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters
        cal.describe.leaveRoomTime = 2;
        cal.describe.nAverage = 2;
        cal.describe.nMeas = 15;
        cal.describe.boxSize = 150;
        cal.describe.boxOffsetX = 0;
        cal.describe.boxOffsetY = 0;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2;
        emailToStr = GetWithDefault('Enter email address for done notification','cottaris@sas.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        
        % Stereo Rig right LCD monitor
    case 'StereoLCDRight'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 1;
        cal.describe.whichBlankScreen = 3;
        cal.describe.blankSettings = [0.3962 0.3787 0.4039];
        
        cal.bgColor = [0.3962 0.3787 0.4039];
        cal.fgColor = cal.bgColor;
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'StereoLCDRight';
        cal.describe.comment = 'StereoLCDRight standard';
        newFileName = 'StereoLCDRight';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1920 1200];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'simplePower';
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 2;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.describe.boxOffsetX = 0;
        cal.describe.boxOffsetY = 0;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2;
        emailToStr = GetWithDefault('Enter email address for done notification','radonjic@sas.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        % Stereo Rig left LCD monitor
    case 'StereoLCDLeft'
        whichScreen = 3;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 1;
        cal.describe.whichBlankScreen = 2;
        cal.describe.blankSettings = [0.3962 0.3787 0.4039];
        
        cal.bgColor = [0.3962 0.3787 0.4039];
        cal.fgColor = cal.bgColor;
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'StereoLCDLeft';
        cal.describe.comment = 'StereoLCDLeft standard';
        newFileName = 'StereoLCDLeft';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1920 1200];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'simplePower';
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters=
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 2;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 2;
        emailToStr = GetWithDefault('Enter email address for done notification','radonjic@sas.upenn.edu');
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        
        % Generic monitor, prompt for needed info.
    otherwise
        % Enter screen
        whichScreen = length(mglDescribeDisplays);
        defaultScreen = whichScreen;
        whichScreen = input(sprintf('Which screen to calibrate [%g]: ', defaultScreen));
        if isempty(whichScreen)
            whichScreen = defaultScreen;
        end
        cal.describe.whichScreen = whichScreen;
        
        % Blank screen
        defaultBlankOtherScreen = 0;
        cal.describe.blankOtherScreen = input(sprintf('Do you want to blank another screen? (1 for yes, 0 for no) [%g]: ', defaultBlankOtherScreen));
        if isempty(cal.describe.blankOtherScreen)
            cal.describe.blankOtherScreen = defaultBlankOtherScreen;
        end
        if (cal.describe.blankOtherScreen)
            defaultBlankScreen = 2;
            whichBlankScreen = input(sprintf('Which screen to blank [%g]: ', defaultBlankScreen));
            if isempty(whichBlankScreen)
                whichBlankScreen = defaultBlankScreen;
            end
            cal.describe.whichBlankScreen = whichBlankScreen;
            cal.describe.blankSettings = [0 0 0];
        end
        
        % Background RGB
        % The default is a guess as to what produces one-half of maximum
        % output for a typical CRT.
        defBgColor = [190 190 190]'/255;
        thePrompt = sprintf('Enter RGB values for background (range 0-1) as a row vector [%0.3f %0.3f %0.3f]: ',...
            defBgColor(1), defBgColor(2), defBgColor(3));
        while true
            cal.bgColor = input(thePrompt)';
            if isempty(cal.bgColor)
                cal.bgColor = defBgColor;
            end
            [m, n] = size(cal.bgColor);
            if m ~= 3 || n ~= 1
                fprintf('\nMust enter values as a row vector (in brackets).  Try again.\n');
            elseif (any(cal.bgColor > 1) || any(cal.bgColor < 0))
                fprintf('\nValues must be in range (0-1) inclusive.  Try again.\n');
            else
                break;
            end
        end
        
        % Prompt for foreground color, the operating point around which the calibration is peformed.
        defFgColor = [0 0 0]';
        thePrompt = sprintf('Enter RGB values for foreground operating point (range 0-1) as a row vector [%0.3f %0.3f %0.3f]: ',...
            defFgColor(1), defFgColor(2), defFgColor(3));
        while true
            cal.fgColor = input(thePrompt)';
            if isempty(cal.fgColor)
                cal.fgColor = defFgColor;
            end
            [m, n] = size(cal.fgColor);
            if m ~= 3 || n ~= 1
                fprintf('\nMust enter values as a row vector (in brackets).  Try again.\n');
            elseif (any(cal.fgColor > 1) || any(cal.fgColor < 0))
                fprintf('\nValues must be in range (0-1) inclusive.  Try again.\n');
            else
                break;
            end
        end
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = [];
        desired.screenSizePixel = [];
        
        % Get distance from meter to screen.
        cal.describe.meterDistance = GetWithDefault('Enter distance from meter to screen (in meters)',0.8);
        
        % Descriptive information
        cal.describe.monitor = input('Enter monitor name: ','s');
        cal.describe.comment = input('Describe the calibration: ','s');
        
        % Get name
        defaultFileName = 'monitor';
        thePrompt = sprintf('Enter calibration filename [%s]: ',defaultFileName);
        newFileName = input(thePrompt,'s');
        if isempty(newFileName)
            newFileName = defaultFileName;
        end
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = GetWithDefault('Use Bits++ interface (no = 0/yes = 1)',0);
        
        % Other parameters
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = GetWithDefault('Enter size (in pixels) of square on screen to calibrate',400);
        cal.describe.boxOffsetX = GetWithDefault('Enter x offset (in pixels) of square on screen to calibrate',0);
        cal.describe.boxOffsetY = GetWithDefault('Enter y offset (in pixels) of square on screen to calibrate',0);
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        
        % Beep when done?
        beepWhenDone = GetWithDefault('Beep when finished? (no = 0/yes = 1)',1);
end

%% Settings for measurements that allow a basic linearity check
cal.basicmeas.settings = [ [1 1 1] ; [1 0 0] ; [0 1 0] ; [0 0 1] ; ...
    [0.75 0.75 0.75] ; [0.75 0 0] ; [0 0.75 0] ; [0 0 0.75] ; ...
    [0.5 0.5 0.5] ; [0.5 0 0] ; [0 0.5 0] ; [0 0 0.5] ; ...
    [0.25 0.25 0.25] ; [0.25 0 0] ; [0 0.25 0] ; [0 0 0.25] ; ...
    [0.75 cal.fgColor(2) cal.fgColor(3)] ; [0.5 cal.fgColor(2) cal.fgColor(3)] ; [0.25 cal.fgColor(2) cal.fgColor(3)] ; [0 cal.fgColor(2) cal.fgColor(3)] ;
    [cal.fgColor(1) 0.75 cal.fgColor(3)] ; [cal.fgColor(1) 0.5 cal.fgColor(3)] ; [cal.fgColor(1) 0.25 cal.fgColor(3)] ; [cal.fgColor(1) 0 cal.fgColor(3)] ;
    [cal.fgColor(1) cal.fgColor(2) 0.75] ; [cal.fgColor(1) cal.fgColor(2) 0.5] ; [cal.fgColor(1) cal.fgColor(2) 0.25] ; [cal.fgColor(1) cal.fgColor(2) 0] ;
    [0 0 0] ; [0.5378    0.5321    0.5406]; [0.4674    0.4249    0.3573]; [0.4106    0.4399    0.5388]]';

%% Settings for measurements that allow a check of dependence on background
cal.bgmeas.bgSettings = [ [1 1 1] ; [1 0 0] ; [0 1 0] ; [0 0 1] ; ...
    [0.5 0.5 0.5] ; [0.5 0 0] ; [0 0.5 0] ; [0 0 0.5] ; ...
    [0 0 0] ]';
cal.bgmeas.settings = [ [1 1 1] ; [0.5 0.5 0.5] ; [0.5 0.0 0.0] ; [0.0 0.5 0.0] ; [0.0 0.0 0.5] ; [0 0 0] ]';


%% Handle case where offset is not specified, because
% we are too lazy to go enter it as 0 in all the forks
% above.
if (~isfield(cal.describe,'boxOffsetX'))
    cal.describe.boxOffsetX = 0;
end
if (~isfield(cal.describe,'boxOffsetY'))
    cal.describe.boxOffsetY = 0;
end

%% Call common driver
if (~isfield(cal.describe,'HDRProjector'))
    cal.describe.HDRProjector = 0;
end
cal.describe.promptforname = 1;
cal.describe.whichMeterType = whichMeterType;
USERPROMPT = 1; %#ok<NASGU>

try
    mglCalibrateMonCommon;
catch e
    if beepWhenDone == 2
        sendmail(emailToStr, 'Calibration Failed', 'Sorry, baby this isn''t working out.');
    end
    rethrow(e);
end
