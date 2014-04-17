% FindMinMaxLumAtChromDemo
%
% Find min and max luminance available within monitor gamut at 
% a fixed chromaticity.  Mostly a call to the function that
% does the work. 
%
% 5/14/10  dhb  Wrote it

%% Clear
clear; close all;

%% Load calibration/color space info
cal = LoadCalFile('FrontRoomClass');
S = cal.S_device;
load T_xyz1931
T_xyz = 683*SplineCmf(S_xyz1931,T_xyz1931,S);
cal = SetSensorColorSpace(cal,T_xyz,S);
cal = SetGammaMethod(cal,0);

%% Pick your favorite chromaticity by finding
% chromaticity of some triplet of rgb primaries
thexyY= XYZToxyY( PrimaryToSensor(cal,[1 1 1]') );

%% Find minimum and maximum luminance at the desired chromaticity
[minLum,maxLum] = FindMinMaxLumAtChrom(cal,thexyY(1:2));
fprintf('At chromaticity xy = (%0.3f, %0.3f), min lum is %0.2f, max lum is %0.2f\n',thexyY(1),thexyY(2),minLum,maxLum);

%% In real life, want a little headroom around the gamut
minLum = 1.05*minLum;
maxLum = 0.95*maxLum;

%% Check that it worked
rgbMin = SensorToPrimary(cal,xyYToXYZ([thexyY(1:2) ; minLum]));
fprintf('Minimum luminance primary values = [%0.3f, %0.3f, %0.3f]\n',rgbMin(1),rgbMin(2),rgbMin(3));
rgbMax = SensorToPrimary(cal,xyYToXYZ([thexyY(1:2) ; maxLum]));
fprintf('Maximu luminance primary values = [%0.3f, %0.3f, %0.3f]\n',rgbMax(1),rgbMax(2),rgbMax(3));

