function CompareSphereMeas
% CompareSphereMeas
%
% Compare the three measurements of the sphere for a given date.
%
% 09/09/17  dhb  Update to use prefs for where data live and go.
% 11/09/17  npc  Fixed some path issues. Also added PTB-3 to the path.  
%                This is not included in the BrainardLabToolbox config for
%                some reason unknown to me (nicolas)
% 11/09/17 npc   Added ability to normalize with respect to either PR670-1
%                or PR670-2. The user is asked which one.
%
% Run this after doing: tbUse('BrainardLabToolbox');

% Clear and close
close all;

%% Measurement date to analyze
% Put the PTB-3 in the path
addpath(genpath(fullfile(getpref('BrainardLabToolbox', 'ptbBaseDir'), 'Psychtoolbox')));

dateStrDefault = '11-Nov-2015';
dateStr = GetWithDefault('Enter date string to compare for',dateStrDefault);

%% Define unit wl spacing
wls = (380:1:780)';

%% Get directory where stuff is
if (~ispref('BrainardLabToolbox','RadiometerChecksDir'))
    error('No ''BrainardLabToolbox:RadiometerChecksDir'' preference set.  Probably you need to update your BrainardLabToolbox local hook file.')
end
radiometerChecksDir = getpref('BrainardLabToolbox','RadiometerChecksDir');
if (~exist(radiometerChecksDir,'dir'))
    error(['Directory ' radiometerChecksDir ' does not exist.  Something is not set up correctly.']);
end

%% Save current dir
curDir = pwd;

%% Load new PR-650
cd(fullfile(radiometerChecksDir,'xNewMeter'));
if (exist(['NewUCSB_Sphere_' dateStr '.mat'],'file'))
    fprintf('Loading NewUCSB PR-650 data\n');
    newMeterData = load(['NewUCSB_Sphere_' dateStr],'wls','theSpectra');
    wlsNewMeter = newMeterData.wls;
    spectrumNewMeter = zeros(size(wlsNewMeter));
    for i = 1:length(newMeterData.theSpectra)
        spectrumNewMeter = spectrumNewMeter + newMeterData.theSpectra{i};
    end
    spectrumNewMeter = spectrumNewMeter/length(newMeterData.theSpectra);
    spectrumNewMeter = SplineSpd(wlsNewMeter, spectrumNewMeter, wls);
else
    fprintf('No NewUCSB PR-650 data available\n');
    wlsNewMeter = [];
    spectrumNewMeter = [];
end

%% Load the Penn PR-650
cd(fullfile(radiometerChecksDir,'xPennMeter'));
if (exist(['Penn_Sphere_' dateStr '.mat'],'file'))
    fprintf('Loading Penn PR-650 data\n');
    pennMeterData = load(['Penn_Sphere_' dateStr],'wls','theSpectra');
    wlsPennMeter = pennMeterData.wls;
    spectrumPennMeter = zeros(size(wlsPennMeter));
    for i = 1:length(pennMeterData.theSpectra)
        spectrumPennMeter = spectrumPennMeter + pennMeterData.theSpectra{i};
    end
    spectrumPennMeter = spectrumPennMeter/length(pennMeterData.theSpectra);
    spectrumPennMeter = SplineSpd(wlsPennMeter, spectrumPennMeter, wls);
else
    fprintf('No Penn PR-650 data available\n');
    wlsPennMeter = [];
    spectrumPennMeter = [];
end
cd(curDir);

%% Load the Penn PR-670 #1
cd(fullfile(radiometerChecksDir, 'xPR-670_1'));
if (exist(['PR-670_1_Sphere_' dateStr '.mat'],'file')) 
    fprintf('Loading PR-670_1 data\n');
    pr670_1_MeterData = load(['PR-670_1_Sphere_' dateStr],'wls','theSpectra');
    wlsPr670_1_Meter = pr670_1_MeterData.wls;
    spectrumPr670_1_Meter = zeros(size(wlsPr670_1_Meter));
    for i = 1:length(pr670_1_MeterData.theSpectra)
        spectrumPr670_1_Meter = spectrumPr670_1_Meter + pr670_1_MeterData.theSpectra{i};
    end
    spectrumPr670_1_Meter = spectrumPr670_1_Meter/length(pr670_1_MeterData.theSpectra);
    spectrumPr670_1_Meter = SplineSpd(wlsPr670_1_Meter, spectrumPr670_1_Meter, wls);
else
    fprintf('No PR-670_1 data available\n');
    wlsPr670_1_Meter = [];
    spectrumPr670_1_Meter = [];
end
cd(curDir);

%% Load the Penn PR-670 #2
cd(fullfile(radiometerChecksDir, 'xPR-670_2'));
if (exist(['PR-670_2_Sphere_' dateStr '.mat'],'file')) 
    fprintf('Loading PR-670_2 data\n');
    pr670_2_MeterData = load(['PR-670_2_Sphere_' dateStr],'wls','theSpectra');
    wlsPr670_2_Meter = pr670_2_MeterData.wls;
    spectrumPr670_2_Meter = zeros(size(wlsPr670_2_Meter));
    for i = 1:length(pr670_2_MeterData.theSpectra)
        spectrumPr670_2_Meter = spectrumPr670_2_Meter + pr670_2_MeterData.theSpectra{i};
    end
    spectrumPr670_2_Meter = spectrumPr670_2_Meter/length(pr670_2_MeterData.theSpectra);
    spectrumPr670_2_Meter = SplineSpd(wlsPr670_2_Meter, spectrumPr670_2_Meter, wls);
else
    fprintf('No PR-670_2 data available\n');
    wlsPr670_2_Meter = [];
    spectrumPr670_2_Meter = [];
end
cd(curDir);

%% Get the absolute spectral radiance from the LabSphere calibration
%
% This no longer matches what our LabSphere actually does
[wlsLabSphere, spectralRadianceLabSphere] = GetLabSphereCalibratedSpectralRadiance;
[~, commonWlsIdx1] = intersect(wls, wlsLabSphere);
[~, commonWlsIdx2] = intersect(wlsLabSphere, wls);


% Ask which PR670 to normalize against
normPR670Default = '1';
normPR670 = str2num(GetWithDefault('PR670 to normalize against (1 or 2)',normPR670Default))

if (normPR670 == 1)
    spectrumNormPR670 = spectrumPr670_1_Meter;
    prefixNormPR670 = 'PR-670 #1';
    spectrumOtherPR670 = spectrumPr670_2_Meter;
    prefixOtherPR670 = 'PR-670 #2';
else
    spectrumNormPR670 = spectrumPr670_2_Meter;
    prefixNormPR670 = 'PR-670 #2';
    spectrumOtherPR670 = spectrumPr670_1_Meter;
    prefixOtherPR670 = 'PR-670 #1';
end

%% Figure, normalized to PR_670_1
figure; clf; hold on
legendStr = {};
legendLength = 0;
fprintf('\n');
if (~isempty(spectrumNormPR670))
    plot(wls,spectrumNormPR670,'Color', [255 0 0]/255,'LineWidth',2);
    legendLength = legendLength + 1;
    legendStr{legendLength} = sprintf('%s (normalizer)', prefixNormPR670);
else
    error('Must have %s measurements, these are assumed for normalizing', prefixNormPR670);
end

if (~isempty(spectrumOtherPR670))
    spectrumFactor = spectrumOtherPR670\spectrumNormPR670;
    plot(wls,spectrumFactor*spectrumOtherPR670,'Color', [0 255 0]/255,'LineWidth',2);
    legendLength = legendLength + 1;
    legendStr{legendLength} = prefixOtherPR670;
    fprintf('%s to %s factor: %0.2f\n',prefixOtherPR670, prefixNormPR670, spectrumFactor);
end

if (~isempty(spectrumNewMeter))
    spectrumFactor = spectrumNewMeter\spectrumNormPR670;
    plot(wls,spectrumFactor*spectrumNewMeter,'Color',[0 0 255]/255,'LineWidth',2);
    legendLength = legendLength + 1;
    legendStr{legendLength} = 'NewUCSB PR-650';
    fprintf('NewUCSB meter PR-650 to %s factor: %0.2f\n', prefixNormPR670, spectrumFactor);
end

if (~isempty(spectrumPennMeter))
    spectrumFactor = spectrumPennMeter\spectrumNormPR670;
    plot(wls,spectrumFactor*spectrumPennMeter,'Color', [255 128 128]/255,'LineWidth',2);
    legendLength = legendLength + 1;
    legendStr{legendLength} = 'Penn PR-650';
    fprintf('Penn meter PR-650 to %s factor: %0.2f\n', prefixNormPR670, spectrumFactor);
end
xlabel('Wavelength (nm)','FontSize',18);
ylabel('Power re PR-670 #1','FontSize',18);
title(['Relative Spectra Comparison ' dateStr],'FontSize',18);
legend(legendStr,'Location','NorthWest','FontSize',14);
xlim([300 800]);
FigureSave(fullfile(radiometerChecksDir,'xComparison',['PRComparison_Relative_' dateStr]),gcf,'pdf');

%% Figure, absolute
figure; clf; hold on
legendStr = {};
legendLength = 0;
if (~isempty(spectrumNormPR670))
    plot(wls,spectrumNormPR670,'Color', [255 0 0]/255,'LineWidth',2);
    legendLength = legendLength + 1;
    legendStr{legendLength} = sprintf('%s (normalizer)', prefixNormPR670);
end

if (~isempty(spectrumOtherPR670))
    plot(wls,spectrumOtherPR670,'Color', [0 255 0]/255,'LineWidth',2);
    legendLength = legendLength + 1;
    legendStr{legendLength} = prefixOtherPR670;
end

if (~isempty(spectrumNewMeter))
    plot(wls,spectrumNewMeter,'Color',[0 0 255]/255,'LineWidth',2);
    legendLength = legendLength + 1;
    legendStr{legendLength} = 'NewUCSB PR-650';
end
if (~isempty(spectrumPennMeter))
    plot(wls,spectrumPennMeter,'Color', [0 0 0]/255,'LineWidth',2);
    legendLength = legendLength + 1;
    legendStr{legendLength} = 'Penn PR-650';
end
xlabel('Wavelength (nm)','FontSize',18);
ylabel('Power','FontSize',18);
title(['Absolute Spectra Comparison ' dateStr],'FontSize',18);
legend(legendStr,'Location','NorthWest','FontSize',14);
xlim([300 800]);
FigureSave(fullfile(radiometerChecksDir,'xComparison',['PRComparison_Absolute_' dateStr]),gcf,'pdf');

% XYZ color matching function
fprintf('\n');
load T_xyz1931;
T_xyz1931 = SplineCmf(S_xyz1931,683*T_xyz1931,wls);
measureXYZ = T_xyz1931*spectrumNormPR670;
measureCDM2(i) = measureXYZ(2);
fprintf(1,'Measured luminance (%s), %g cd/m2\n',prefixNormPR670, measureCDM2(i));
fprintf(1,'Measured chromaticity (%s), x: %.4f, y: %.4f\n', prefixNormPR670, measureXYZ(1)/sum(measureXYZ), measureXYZ(2)/sum(measureXYZ));

%% Fit a black body radiator to the mean relative spectrum
% meanSpectrum = mean([(spectrumNewMeter\spectrumPr670Meter)*spectrumNewMeter (spectrumPennMeter\spectrumPr670Meter)*spectrumPennMeter spectrumPr670Meter],2);
% x0 = [0.28];
% vlb = [0.1];
% vub = [1];
% options = optimset('fmincon');
% options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
% temp = fmincon(@(x)FitBBFunction(x,wls,meanSpectrum),x0,[],[],[],[],vlb,vub,[],options);
% [~,predSpectrum] = FitBBFunction(temp,wls,meanSpectrum);
% %plot(wls,predSpectrum,'k.','LineWidth',2);
% fprintf('Fit color temperature is %0.1f\n',1000*temp);

end

%% Fit function
function [f,relPredBB] = FitBBFunction(temp,wls,spectrum)

predBB = GenerateBlackBody(10000*temp,wls);
relPredBB = (predBB\spectrum)*predBB;
diff = relPredBB-spectrum;
f = sum(diff.^2);

end

