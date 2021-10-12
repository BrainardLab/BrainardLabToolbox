% CalFileFromIccProfile.m
%
% Create a calibration file from an icc profile.
% This was created from an icc profile measured by
% David Jones with an X-Rite Hue Pro colorimeter.
% The data seem to be in relative luminance units,
% with the monitor white point having a lumiance
% of 1.
%
% ICC profiles store data in a scaled way that is
% a bit obscure. This routine does not account for
% that, yet.
%
% 08/15/12 dhb  Wrote it.
% 10/03/21 dhb  Added comment about iccprofile storage format.

%% Clear and close
clear; close all;


%% Get profile name
profileName = GetWithDefault('Enter ICC provile name','HueyPro-2012-08-14');
monitorName = GetWithDefault('Name of monitor cal file','HueyProCal');
whichScreen = GetWithDefault('Which screen was calibrated (1 -> main, ...)',1);

%% Get measurements
iccprofile = iccread(profileName);

%% Some checks. This may not be a very general function; let's
% make sure some basic stuff is as in the example file we used
% initially
if (~strcmp(iccprofile.Header.ColorSpace,'RGB'))
    error('Expect color space to be RGB');
end
if (~strcmp(iccprofile.Header.ConnectionSpace,'XYZ'))
    error('Expect connection space to be XYZ');
end

%% Figure out three channel XYZs and black XYZ
redXYZ = iccprofile.MatTRC.RedMatrixColumn';
greenXYZ = iccprofile.MatTRC.GreenMatrixColumn';
blueXYZ = iccprofile.MatTRC.BlueMatrixColumn';
whiteXYZ = iccprofile.MediaWhitePoint';
blackXYZ = iccprofile.MediaBlackPoint';
checkWhiteXYZ = redXYZ + greenXYZ + blueXYZ;
if (any(abs(whiteXYZ-checkWhiteXYZ)> 1e-4))
    error('Do not understand relation between white and channel XYZs in profile');
end

%% We're going to do this by patching up a calibration structure like the
% one we create with the calibration routines.  This takes a bit more
% screwing around than it might to do things directly, but let's us
% take advantage of the calibration routines already in place.
cal.describe.S = [380 4 101];
cal.describe.monitor = monitorName;
cal.describe.comment = 'Calibration derived from ICC profile';
cal.describe.whichScreen = whichScreen;
computerInfo = GetComputerInfo;
cal.describe.caltype = 'monitor';
[nil, host] = unix('hostname');
cal.describe.computer = host;
cal.describe.driver = sprintf('%s %s','unknown_driver','unknown_driver_version');

if (exist('mglDescribeDisplays','file'))
displayDescription = mglDescribeDisplays;
    cal.describe.hz = displayDescription(cal.describe.whichScreen).refreshRate;
    cal.describe.screenSizePixel = displayDescription(cal.describe.whichScreen).screenSizePixel;
    cal.describe.displayDescription = displayDescription(cal.describe.whichScreen);
else
    cal.describe.hz = 0;
    cal.describe.screenSizePixel = [0 0];
    cal.describe.displayDescription = 'Not available';
end

cal.describe.date = sprintf('%s %s',date,datestr(now,14));
cal.describe.who = 'Mr. Nobody';
%cal.describe.dacsize = ScreenDacBits(cal.describe.whichScreen-1);
cal.describe.dacsize = 8;
cal.describe.program = 'CalFIleFromIccProfile';
cal.describe.driver = 'Not Known';

% Fitting parameters
cal.describe.gamma.fitType = 'simplePower';

% Bits++?
cal.usebitspp = 0;

% Other parameters
nGammaLevels = 30;
cal.describe.nAverage = 1;
cal.describe.nMeas = nGammaLevels;
cal.nDevices = 3;
cal.nPrimaryBases = 1;

%% Get color matching functions for XYZ
load T_xyz1931;
S_xyz = cal.describe.S;
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,cal.describe.S);

%% Fill ambient measurements
%
% First image is zeros
cal.S_ambient = cal.describe.S;
cal.T_ambient = T_xyz;
cal.P_ambient = blackXYZ;

%% Fill in phosphor measurements
cal.S_device = cal.describe.S;
cal.T_device = T_xyz;
cal.P_device = [redXYZ greenXYZ blueXYZ];

cal.rawdata.rawGammaTable = double([iccprofile.MatTRC.RedTRC iccprofile.MatTRC.GreenTRC iccprofile.MatTRC.BlueTRC]);
cal.rawdata.rawGammaTable = cal.rawdata.rawGammaTable/max(cal.rawdata.rawGammaTable(:));
if (cal.rawdata.rawGammaTable(end,1) ~= 1 || cal.rawdata.rawGammaTable(end,1) ~= 1 || cal.rawdata.rawGammaTable(end,1) ~= 1)
    error('Do not understand format of iccprofile gamma curves');
end
cal.rawdata.rawGammaInput = linspace(0,1,size(cal.rawdata.rawGammaTable,1))';
cal = CalibrateFitGamma(cal);

%% Save the calibration file in PsychCalLocalData
SaveCalFile(cal,monitorName);

%% Report of some things we might care about.  These
% can be checked against the numbers that were input
% and should match.
%
% The CCT doesn't agree with what SV outputs, however.
% This may be a bug in SV, in cct, or a fact that the
% standard is a bit underspecified.
cal = SetSensorColorSpace(cal,T_xyz,S_xyz);
cal = SetGammaMethod(cal,0);
predictedWhiteXYZ = SettingsToSensor(cal,[1 1 1]');
predicted1960uvY = XYZTouvY(predictedWhiteXYZ,1);
predictedWhitexyY = XYZToxyY(predictedWhiteXYZ);
predictedBlackXYZ = SettingsToSensor(cal,[0 0 0]');
predictedBlackxyY = XYZToxyY(predictedBlackXYZ);
predRedxyY = XYZToxyY(SettingsToSensor(cal,[1 0 0]')-predictedBlackXYZ);
predGreenxyY = XYZToxyY(SettingsToSensor(cal,[0 1 0]')-predictedBlackXYZ);
predBluexyY = XYZToxyY(SettingsToSensor(cal,[0 0 1]')-predictedBlackXYZ);
fprintf('White point xyY: %0.3f %0.3f %0.1f cd/m2\n',predictedWhitexyY(1),predictedWhitexyY(2),predictedWhitexyY(3));
fprintf('Black point Y: %0.2f cd/m2\n',predictedBlackxyY(3));
if (exist('cct','file'))
    predictedWhiteCCT = cct(predicted1960uvY(1:2));
    fprintf('Predicted white CCT %d degrees K\n',round(predictedWhiteCCT));
end
fprintf('Predicted red xyY: %0.3f %0.3f %0.3f cd/m2\n',predRedxyY(1),predRedxyY(2),predRedxyY(3));
fprintf('Predicted green xyY: %0.3f %0.3f %0.3f cd/m2\n',predGreenxyY(1),predGreenxyY(2),predGreenxyY(3));
fprintf('Predicted blue xyY: %0.3f %0.3f %0.3f cd/m2\n',predBluexyY(1),predBluexyY(2),predBluexyY(3));
fprintf('Mean gamma: %0.2f\n',mean(cal.describe.gamma.exponents));
whiteLum = predRedxyY(3) + predGreenxyY(3) + predBluexyY(3);
fprintf('RGB normalized luminances: %0.3f %0.3f %0.3f\n',predRedxyY(3)/whiteLum,predGreenxyY(3)/whiteLum,predBluexyY(3)/whiteLum);

% Plot the gamma curves
CalibratePlotGamma(cal,figure(1));

