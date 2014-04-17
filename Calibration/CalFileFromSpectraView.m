% CalFileFromSpectraView.m
%
% Create a calibration file from a set of SpectraView measurements.
% 
% This is useful for using the NEC monitors with our general calibration
% software, when it isn't possible to make full spectral measurements.
%
% 08/07/11 dhb  Wrote it.

%% Clear and close
clear; close all;

%% Get monitor name
monitorName = GetWithDefault('Enter monitor name','DHBOfficeSV');

%% Get measurements
readRawMeasurements = GetWithDefault('Read raw measurments? [0 -> enter them; 1 -> read them]',1);
if (readRawMeasurements)
    rawMeas = LoadCalFile([monitorName '_rawmeas']);
else
    rawMeas.redxy = input('Enter red channel xy as a row vector: ');
    rawMeas.greenxy = input('Enter green channel xy as a row vector: ');
    rawMeas.bluexy = input('Enter blue channel xy as a row vector: ');
    rawMeas.whitexy = input('Enter white xy as a row vector: ');
    rawMeas.whiteY = input('Enter white Y (cd/m2): ');
    rawMeas.blackY = input('Enter black Y (cd/m2): ');
    rawMeas.gammaExp = input('Enter gamma exponent: ');
    saveRawMeasurements = GetWithDefault('Save raw measurments? [0 -> don''t save; 1 -> save them]',1);
    if (saveRawMeasurements)
        SaveCalFile(rawMeas,[monitorName '_rawmeas']);
    end
end

%% Figure out three channel XYZs and black XYZ
relRedXYZ = xyYToXYZ([rawMeas.redxy' ; 1]);
relGreenXYZ = xyYToXYZ([rawMeas.greenxy' ; 1]);
relBlueXYZ = xyYToXYZ([rawMeas.bluexy' ; 1]);
incWhiteXYZ = xyYToXYZ([rawMeas.whitexy' ; (rawMeas.whiteY-rawMeas.blackY)]);
blackXYZ = xyYToXYZ([rawMeas.whitexy' ; rawMeas.blackY]);

% Form matrix to solve for phosphor luminances
M = [relRedXYZ relGreenXYZ relBlueXYZ];
phosLums = M\incWhiteXYZ;
redXYZ = relRedXYZ*phosLums(1);
greenXYZ = relGreenXYZ*phosLums(2);
blueXYZ = relBlueXYZ*phosLums(3);

%% We're going to do this by patching up a calibration structure like the
% one we create with the calibration routines.  This takes a bit more
% screwing around than it might to do things directly, but let's us
% take advantage of the calibration routines already in place.
cal.describe.S = [380 4 101];
cal.describe.monitor = monitorName;
cal.describe.comment = 'Calibration derived from NEC spectra view measurments';
cal.describe.whichScreen = 2;
computerInfo = GetComputerInfo;
displayDescription = mglDescribeDisplays;
cal.describe.caltype = 'monitor';
cal.describe.computer = sprintf('%s''s %s, %s', computerInfo.userShortName, computerInfo.localHostName, computerInfo.OSVersion);
cal.describe.driver = sprintf('%s %s','unknown_driver','unknown_driver_version');
cal.describe.hz = displayDescription(cal.describe.whichScreen).refreshRate;
cal.describe.screenSizePixel = displayDescription(cal.describe.whichScreen).screenSizePixel;
cal.describe.displayDescription = displayDescription(cal.describe.whichScreen);
cal.describe.date = sprintf('%s %s',date,datestr(now,14));
cal.describe.who = input('Enter your name: ','s');
%cal.describe.dacsize = ScreenDacBits(cal.describe.whichScreen-1);
cal.describe.dacsize = 8;
cal.describe.program = 'CalFIleFromSpectraView';
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

cal.rawdata.rawGammaInput = linspace(0,1,nGammaLevels+1)';
cal.rawdata.rawGammaInput = cal.rawdata.rawGammaInput(2:end);
gammaFun = cal.rawdata.rawGammaInput.^rawMeas.gammaExp;
cal.rawdata.rawGammaTable = [gammaFun gammaFun gammaFun];
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
fprintf('Predicted red xyY: %0.3f %0.3f %0.1f cd/m2\n',predRedxyY(1),predRedxyY(2),predRedxyY(3));
fprintf('Predicted green xyY: %0.3f %0.3f %0.1f cd/m2\n',predGreenxyY(1),predGreenxyY(2),predGreenxyY(3));
fprintf('Predicted blue xyY: %0.3f %0.3f %0.1f cd/m2\n',predBluexyY(1),predBluexyY(2),predBluexyY(3));
fprintf('Mean gamma: %0.2f\n',mean(cal.describe.gamma.exponents));




