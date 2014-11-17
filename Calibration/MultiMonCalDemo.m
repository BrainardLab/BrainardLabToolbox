% MultiMonCalDemo
%
% Show how to equalize background and contrast
% across multiple calibrated screens.
%
% Wrote this to illustrate how to do it for our dog behavior
% experiments, where we actually have three separate screens.
% 
% See also GetMultiMonNeutralBackground, GetMultiMonMaxContrast,
%   GetMultiMonContrastRGB, CalDemo, Brainard Lab threeScreenCalTutorial.
%
% Dog receptor demo relies on T_dogrec, which is in BrainardLab
% PsychCalLocalData.
%
% 7/22/09  dhb  Wrote it.

%% Clear
clear; close all

%% Specify desired color contrast direction and contrast.
% Contrast is defined relative to a direction
% vector with vector length 1.  For this reason, contrast
% can sometimes exceed unity.
contrastDir = [1 0 0]';
targetFactor = 0.45;
recType = 'dog';

%% Load the calibration files, as many as you like.
cals{1} = LoadCalFile('DogScreen1Lights');
cals{2} = LoadCalFile('DogScreen2Lights');
cals{3} = LoadCalFile('DogScreen3Lights');
S = cals{1}.S_device;

%% Initialize sensor color space.  
switch (recType)
    case 'dog'
        % Photoreceptor sensitivities estimate for
        % canine vision.  The order in the file is L cone, S cone
        % rod. 
        load T_dogrec
        T_rec = SplineCmf(S_dogrec,T_dogrec,S);
    case 'XYZ'
        % XYZ color matching functions
        load T_xyz1931
        T_rec = 683*SplineCmf(S_xyz1931,T_xyz1931,S);
    otherwise
        error('Unknown receptor type');
end
        
for i = 1:length(cals)
    calsRec{i} = SetSensorColorSpace(cals{i},T_rec,S);
    calsRec{i} = SetGammaMethod(calsRec{i},1);
end

%% Get background settings for each monitor
backgroundRGBs = GetMultiMonNeutralBackground(calsRec,targetFactor);

%% Get background in receptor space.  If everything is working
% right, these ought to be the same up to calibration quantization.
for i = 1:length(cals)
    backgroundRecs(:,i) = SettingsToSensor(calsRec{i},backgroundRGBs(:,i));
end

%% Get maximum contrast available in specified contrast dir
[maxContrast,normDir] = GetMultiMonMaxContrast(calsRec,backgroundRecs,contrastDir);

%% Get RGB values for each end of a series of contrast modulations.  The
% values come back as a cell array, one for the minimum end of the
% modulation for each specified contrast, one for the maximum end.  Each
% set of RGB values is a matrix, with each column corresponding to one
% monitor.
theContrasts = linspace(-maxContrast,maxContrast,100);
for c = 1:length(theContrasts)
    [minModulationRGBs{c},maxModulationRGBs{c}] = ...
        GetMultiMonContrastRGB(calsRec,backgroundRecs,normDir,theContrasts(c));
end
