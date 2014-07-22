% Dummy code that converts from one image format to another. 

%% Initialize and set parameters. 
clear; close all;

%% Load color matching functions.
% For LMS conversions
load T_cones_ss2

% For XYZ conversions. 
load T_xyz1931
S = [400, 10, 31]; % render specific spacing.
T_sensorXYZ = 683*SplineCmf(S_xyz1931,T_xyz1931,S);

%% set the calibration file for converting left image (via LMS)
calLeft = LoadCalFile('StereoLCDLeft');
calLeft = SetGammaMethod(calLeft, 0);
calLeftLMS = SetSensorColorSpace(calLeft, T_cones_ss2,  S_cones_ss2); 
% Note: what exact S you put above is not so important, because SetSensorColorSpace checks and does the splining anyway.
%% from multispectral image to sensor
leftImage = load('NCT1Basis2L.mat');
% this is the rendertoolbox function that converts from multispectral image
% (which is what you get from RenderToolbox) to sensor image.
% you can specify if you want it to convert it into LMS or XYZ 
sensorImageLMSLeft = MultispectralToSensorImage(leftImage.multispectralImage, leftImage.S, T_cones_ss2, S_cones_ss2);

%% From the LMS representation to RGB
% to make it MUCH faster use ImageToCalFormat and CalFormatToImage
[temp,m,n] = ImageToCalFormat(sensorImageLMSLeft);

tempRGB = SensorToSettings(calLeftLMS, temp); % get gamma-corrected settings
uncorrectedRGB = SensorToPrimary(calLeftLMS, temp); % get gamma-uncorrected settings aka primaries. 

sensorImageLeftRGB = CalFormatToImage(tempRGB, m, n); % return into the adequate format
sensorImageLeftUncorrectedRGB = CalFormatToImage(uncorrectedRGB, m, n);

% save([leftImageName, '-RGB.mat'], 'sensorImageLeftRGB')
% save([leftImageName, '-UncorrRGB.mat'], 'sensorImageLeftUncorrectedRGB')
%% From LMS to XYZ
% to get from LMS to XYZ (and then to xyY, Lab, Lch, etc... so it can come
% in handy) you now go from RGB values to XYZ via the calibration file
% formated for XYZ sensor
calLeftXYZ = SetSensorColorSpace(calLeft, T_sensorXYZ,  S);
% you can either go from settings to sensor. 
[temp,m,n] = ImageToCalFormat(sensorImageLeftRGB);
[tempRGB] = SettingsToSensor(calLeftXYZ, temp);
% or go from primaries to sensor. 
% [temp,m,n] = ImageToCalFormat(sensorImageLeftUncorrectedRGB);
% [tempRGB] = PrimaryToSensor(calXYZ, temp);
sensorImageXYZ = CalFormatToImage(tempRGB, m, n);
clear temp tempRGB
    