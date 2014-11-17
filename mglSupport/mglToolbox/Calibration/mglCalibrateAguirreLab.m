function mglCalibrateAguirreLab
% mglCalibrateAguirreLab
%
% Calling script for Aguirre lab calibrations.  Assumes
% you have CMCheckInit/MeasSpd functions that initialize
% measurement hardware and return a measured spectral
% power distribution respectively.
%
% Meter type definitions
%    0 - Fake meter, for debugging
%    1 - PR-650
%
% 8/23/10  dhb et al.  Broke out a version for Geoff's lab.  Need to fill in details.
% 9/28/12  ms          Updated for HUP6 monitor calibration.

% Clear and close
clear; close all;

% Create calibration structure;
cal = [];

%% Set meter type. This is the default
% but can be overridden by specific cases
% below, which are set up for debugging.
whichMeterType = 1;

% Script parameters
switch whichMeterType
    case {0,1}
        cal.describe.S = [380 4 101];
    case 2
        cal.describe.S = [380 1 401];
    otherwise
        cal.describe.S = [380 4 101];
end
cal.manual.use = 0;

% Determine what type of calibration we're doing.
while true
    defaultCalibrationType = 'HUP6';
    fprintf('Calibration types supported\n');
    fprintf('\tGlenoldenWithND - Glenolden MRI projector with the screw on ND filter\n');
    fprintf('\tHUP6 - HUP6 MRI project\n');
    fprintf('\tHUP6noND - HUP6 MRI project (no ND)\n');
    fprintf('\tMGLPTBValidate - Validate MGL calibration with PTB calibration\n');
    fprintf('\tNBC - Calibration for NBC projector setup\n');
    
    calibrationType = input(sprintf('What type of calibration are doing? [%s]: ', ...
        defaultCalibrationType),'s');
    
    % Make sure it's a valid calibration type.
    switch calibrationType
        case {'Generic', 'FrontRoomLex', 'FrontRoomClass', 'StereoRigRightAchrom', 'StereoRigLeftAchrom', 'HDRBackRGB', 'FrontRoomObjColor', 'StereoRigLeftClass', 'StereoRigRightClass', 'Dummy', 'DummyBits', 'GlenoldenWithND', 'HUP6', 'HUP6noND', 'MGLPTBValidate', 'NBC'}
            break;
        otherwise
            fprintf('*** Invalid calibration type, try again\n\n');
    end
end
cal.describe.calibrationType = calibrationType;

% Depending on the calibration type we'll set default background
% differently.
switch calibrationType
    case 'GlenoldenWithND'
        whichScreen = 2
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.44 ; 0.36 ; 0.36]';
        cal.fgColor = [0.5 ; 0.5 ; 0.5]';
        cal.describe.meterDistance = 0.5;
        cal.describe.monitor = 'Glenolden projector with ND filter';
        cal.describe.comment = 'Glenolden projector with ND filter';
        newFileName = 'glenoldenmriwithnd';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1024 768];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 1;
        
        % Other parameters
		cal.describe.boxOffsetX = 0;
        cal.describe.boxOffsetY = 0;
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 150;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1; %#ok<*NASGU>
    case 'HUP6'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.745 ; 0.745 ; 0.745]';
        cal.fgColor = [0.745 ; 0.745 ; 0.745]';
        cal.describe.meterDistance = 8;

        cal.describe.monitor = 'HUP6 MRI projector';
        cal.describe.comment = 'HUP6 MRI projector';
        newFileName = 'HUP6';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1024 768];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters
        cal.describe.boxOffsetX = 0;
        cal.describe.boxOffsetY = 0;
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 400;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1; %#ok<*NASGU>
        
    case 'HUP6noND'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.745 ; 0.745 ; 0.745]';
        cal.fgColor = [0.745 ; 0.745 ; 0.745]';
        cal.describe.meterDistance = 8;

        cal.describe.monitor = 'HUP6 MRI projector (no ND)';
        cal.describe.comment = 'HUP6 MRI projector (no ND)';
        newFileName = 'HUP6noND';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1024 768];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters
        cal.describe.boxOffsetX = 0;
        cal.describe.boxOffsetY = 0;
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 400;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1; %#ok<*NASGU>
                
    case 'NBC'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.745 ; 0.745 ; 0.745]';
        cal.fgColor = [0.745 ; 0.745 ; 0.745]';
        cal.describe.meterDistance = 8;

        cal.describe.monitor = 'NBC projector';
        cal.describe.comment = 'NBC projector';
        newFileName = 'NBC';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1280 800];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters
        cal.describe.boxOffsetX = 0;
        cal.describe.boxOffsetY = 0;
        cal.describe.leaveRoomTime = 10;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 400;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1; %#ok<*NASGU>
        
    case 'MGLPTBValidate'
        whichScreen = 2;
        cal.describe.whichScreen = whichScreen;
        cal.describe.blankOtherScreen = 0;
        cal.describe.blankSettings = [0 0 0];
        
        cal.bgColor = [0.745 ; 0.745 ; 0.745]';
        cal.fgColor = [0.745 ; 0.745 ; 0.745]';
        cal.describe.meterDistance = 8;
        cal.describe.monitor = 'ViewSonic LCD';
        cal.describe.comment = 'ViewSonic LCD';
        newFileName = 'MGLPTBValidate';
        
        % Properties we think this monitor should have at
        % calibration time.
        desired.hz = 60;
        desired.screenSizePixel = [1920 1080];
        
        % Fitting parameters
        cal.describe.gamma.fitType = 'crtPolyLinear';
        cal.describe.gamma.contrastThresh = 0.001;
        cal.describe.gamma.fitBreakThresh = 0.02;
        
        % Bits++?
        cal.usebitspp = 0;
        
        % Other parameters
        cal.describe.boxOffsetX = 0;
        cal.describe.boxOffsetY = 0;
        cal.describe.leaveRoomTime = 20;
        cal.describe.nAverage = 1;
        cal.describe.nMeas = 25;
        cal.describe.boxSize = 400;
        cal.nDevices = 3;
        cal.nPrimaryBases = 1;
        beepWhenDone = 1; %#ok<*NASGU>
end
        
%% Settings for measurements that allow a basic linearity check
cal.basicmeas.settings = [ [1 1 1] ; [1 0 0] ; [0 1 0] ; [0 0 1] ; ...                     
                      [0.75 0.75 0.75] ; [0.75 0 0] ; [0 0.75 0] ; [0 0 0.75] ; ...
                      [0.5 0.5 0.5] ; [0.5 0 0] ; [0 0.5 0] ; [0 0 0.5] ; ...
                      [0.25 0.25 0.25] ; [0.25 0 0] ; [0 0.25 0] ; [0 0 0.25] ; ...
                      [0 0 0] ]';
                  
%% Settings for measurements that allow a check of dependence on background
cal.bgmeas.bgSettings = [ [1 1 1] ; [0 0 0]]';
                      
cal.bgmeas.settings = [ [0.5 0.5 0.5] ]'; 
                      
                  

%% Call common driver
if (~isfield(cal.describe,'HDRProjector'))
    cal.describe.HDRProjector = 0;
end
cal.describe.promptforname = 1;
cal.describe.whichMeterType = whichMeterType;
USERPROMPT = 1; %#ok<NASGU>
mglCalibrateMonCommon;
     
