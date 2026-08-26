% ObserverFundamental Demo
%
% Show how we compute cone fundamentals taking individual differences into
% account. The fundamentals are according to the CIE standard but also
% include the Asano et al. individual differences model. See Asano, Y.,
% Fairchild, M. D., & Blondé, L. (2016). Individual colorimetric observer
% model. PloS one, 11(2), e0145671.
%
% See also: DefaultConeParams, ComputeCIEFundamentals (in PTB),
%   IsomerizationsInEyeDemo (in PTB), t_conesPhotoPigment (in ISETBio).

% History
%   12/30/24  dhb  Wrote the demo.

%% Initialize
clear; close all;

% Set wavelength support
wls = (400:5:700)';
S = WlsToS(wls);

%% Set the parameters of the Asano et al. model
%
% First we set the CIE cone fundamental parameters (field size, pupil size,
% observer age), and then the individual difference parameters ride on top
% of those. 
%
% We then call into a Psychtoolbox routine that uses all of the paramters to put
% together the cone fundamentals. This cone fundamentals in quantal units, so
% that integrating against spectral retinal irradiance and multiplying
% by cone aperture acceptance area gives excitations/cone-sec. Note
% that these take lens density into account.  Note that spectral retinal
% irradiance is a little funny here as when we compute it for this purpose,
% we ignore the absorption by the lens, because (following standard
% practice for cone fundamentals) lens absoprtion is folded into the cone
% fundamentals. This convention is like that used to define retinal
% illuminance in trolands - the geometry is taken into account but not
% pre-retinal absorption.
%
% What we'll do below is show how to use the various pieces available from
% this call below, plus the cone aperture size, inside of ISETBio.
coneParams = DefaultConeParams('cie_asano');

% Set age, pupil size, and field size paramters.  These are part of the CIE
% model, and we apply the Asano et al. adjustments to these.
% 
% Comparisons with Stockman-Sharpe tabulated get made if field size is 2 or 10
coneParams.fieldSizeDegrees = 2;
coneParams.ageYears = 32;
coneParams.pupilDiamMM = 3;

% Set individual difference parameters. These are the parameters we
% implement from the Asano et al. model. Density changes apply to lens,
% macular pigment, and L, M, S photopigment. These are expressed as percent
% changes from the nominal values. Shifts in photoreceptor wavelength of
% peak absorption are in nm.
%
% These are set to zero here but can be adjusted
coneParams.indDiffParams.dlens = 0;
coneParams.indDiffParams.dmac = 0;
coneParams.indDiffParams.dphotopigment = [0 0 0]';
coneParams.indDiffParams.lambdaMaxShift = [0 0 0]';

%% Compute the quantal sensitivity 
% 
% This is the probability of a photopigment excitation given a photon of
% different wavelengths passing through the cone's entrance aperture.
% Sensitivity is referred to number/rate of arrival of photons (quanta) at
% the cornea, in that lens and macular pigment transmittance are folded in.
%
% To get actual number of excitations, you would need to take the cone
% apearture size into account, and also convert the geometry of the
% incident light into a form that allows you to get the number of quanta 
% arriving per unit area on the retina, but referred out to the relative
% spectrum entering the cornea.  We know how to do this, but are not
% illustrating it here.
[~,~,T_quantalExcitationProb,adjIndDiffParams,cieConeParams,cieStaticParams] = ...
    ComputeCIEConeFundamentals(S,coneParams.fieldSizeDegrees,...
    coneParams.ageYears,coneParams.pupilDiamMM,[],[],[], ...
    [],[],[],coneParams.indDiffParams);

%% Plot the quantal-unit fundamentals
fundamentalsFig = figure; clf; hold on;
plot(wls,T_quantalExcitationProb(1,:),'r','LineWidth',6);
plot(wls,T_quantalExcitationProb(2,:),'g','LineWidth',6);
plot(wls,T_quantalExcitationProb(3,:),'b','LineWidth',6);
xlabel('Wavelength (nm)');
ylabel('Exciation probability'); grid on;
title('Cone fundamental with spectrum in quantal units');

%% Convert to energy units
%
% Because number of quanta/Joule depends on wavelength, the fundamentals
% have a slightly different shape if the input spectrum is in energy units
% rather than quantal units. We can convert to take this into account.
%
% It is not an error that we are calling EnergyToQuanta(), because that
% name refers to what you do to convert spectra.  Here we are converting
% sensitivity, and that is the inverse of converting spectra.  The
% transposes in the call handle the PTB/BrainardLab convention that spectra
% live in matrix columsn while sensitivites live in matrix rows.
%
% Energy in Joules (or power in Watts) gives number of excitations (or
% excitations/sec).  Because a Joule is a lot of photons, we stop thinking
% in probability and instead think in terms of excitation number.
nConeTypes = size(T_quantalExcitationProb,1);
T_energyExcitationProb = zeros(size(T_quantalExcitationProb));
for cc = 1:nConeTypes
    T_energyExcitationProb(cc,:) = EnergyToQuanta(wls,T_quantalExcitationProb(cc,:)')';
end

% This call encapsulates the above and also returns the energy fundamentals normalized to
% 1
 [T_energyNormalized,T_energyExcitationProbChk,T_quantalExcitationProbChk] = ComputeObserverFundamentals(coneParams,S);
 if (max(abs( (T_energyExcitationProb(:) - T_energyExcitationProbChk(:))/mean(T_energyExcitationProb(:)))) > 1e-7)
     error('Inconsistency in what we think a call does');
 end
 if (max(abs((T_quantalExcitationProb(:) - T_quantalExcitationProbChk(:))/mean(T_quantalExcitationProb(:)))) > 1e-7)
     error('Inconsistency in what we think a call does');
 end

%% Plot the energy-unit fundamentals
fundamentalsFig1 = figure; clf; hold on;
plot(wls,T_energyExcitationProb(1,:),'r','LineWidth',6);
plot(wls,T_energyExcitationProb(2,:),'g','LineWidth',6);
plot(wls,T_energyExcitationProb(3,:),'b','LineWidth',6);
xlabel('Wavelength (nm)');
ylabel('Number of excitations'); grid on;
title('Cone fundamental with spectrum in energy units');

%% Load Stockman-Sharpe 2-deg
load T_cones_ss2
load T_cones_ss10

%% Plot the normalized energy-unit fundamentals
%
% Along with Stockman-Sharpe
fundamentalsFig2 = figure; clf;
set(fundamentalsFig2,"Position",[10 10 2150 660]);
subplot(1,2,1); hold on;
plot(wls,T_energyExcitationProb(1,:)/max(T_energyExcitationProb(1,:)),'r','LineWidth',6);
plot(wls,T_energyExcitationProb(2,:)/max(T_energyExcitationProb(2,:)),'g','LineWidth',6);
plot(wls,T_energyExcitationProb(3,:)/max(T_energyExcitationProb(3,:)),'b','LineWidth',6);
switch (coneParams.fieldSizeDegrees)
    case 2
        plot(SToWls(S_cones_ss2),T_cones_ss2,'k:','LineWidth',2);
    case 10
        plot(SToWls(S_cones_ss10),T_cones_ss10,'k:','LineWidth',2);
end
xlabel('Wavelength (nm)');
ylabel('Number of excitations'); grid on;
title('Cone fundamental (normalized) with spectrum in energy units');

subplot(1,2,2); hold on;
plot(wls,log10(T_energyExcitationProb(1,:)/max(T_energyExcitationProb(1,:))),'r','LineWidth',6);
plot(wls,log10(T_energyExcitationProb(2,:)/max(T_energyExcitationProb(2,:))),'g','LineWidth',6);
plot(wls,log10(T_energyExcitationProb(3,:)/max(T_energyExcitationProb(3,:))),'b','LineWidth',6);
switch (coneParams.fieldSizeDegrees)
    case 2
        plot(SToWls(S_cones_ss2),log10(T_cones_ss2),'k:','LineWidth',2);
    case 10
        plot(SToWls(S_cones_ss10),log10(T_cones_ss10),'k:','LineWidth',2);
end
xlabel('Wavelength (nm)');
ylabel('Number of excitations'); grid on;
title('Cone fundamental (normalized) with spectrum in energy units');

% Generate a distribution of fundamentals
%
%   Asano et al. give the following population SD's for the individual
%   difference parameters (their Table 5, Step 2 numbers):
%       Lens    - 18.7%
%       Macular - 36.5%
%       L Density - 9%
%       M Density - 9%
%       S Density - 7.4%
%       L Shift   - 2 nm
%       M Shift   - 1.5 nm
%       S Shift   - 1.3 nm
nExemplars = 100;
fundamentalsFig3 = figure; clf;
set(fundamentalsFig3,"Position",[10 10 2150 660]);
for ee = 1:10
    coneParamsRnd{ee} = DefaultConeParams('cie_asano');

    coneParamsRnd{ee}.fieldSizeDegrees = coneParams.fieldSizeDegrees;
    coneParamsRnd{ee}.ageYears = coneParams.ageYears;
    coneParamsRnd{ee}.pupilDiamMM = coneParams.pupilDiamMM;

    % Set individual difference parameters. These are the parameters we
    % implement from the Asano et al. model. Density changes apply to lens,
    % macular pigment, and L, M, S photopigment. These are expressed as percent
    % changes from the nominal values. Shifts in photoreceptor wavelength of
    % peak absorption are in nm.  We take draws based on the Asano et al. 
    % standard deviations, but truncate at a specified number of sds, to avoid 
    % crazy outliers.
    maxZ = 2;
    lensSd = 18.7; macSd = 36.5;
    LMDenSd = 9; SDenSd = 7.4;
    LShiftSd = 2; MShiftSd = 1.5; SShiftSd = 1.3;

    coneParamsRnd{ee}.indDiffParams.dlens = TruncatedZeroMeanNormal(lensSd,maxZ);
    coneParamsRnd{ee}.indDiffParams.dmac = TruncatedZeroMeanNormal(macSd,maxZ);
    coneParamsRnd{ee}.indDiffParams.dphotopigment = [ ...
        TruncatedZeroMeanNormal(LMDenSd,maxZ) ...
        TruncatedZeroMeanNormal(LMDenSd,maxZ) ...
        TruncatedZeroMeanNormal(SDenSd,maxZ) ]';
    coneParamsRnd{ee}.indDiffParams.lambdaMaxShift = [ ...
        TruncatedZeroMeanNormal(LShiftSd,maxZ) ...
        TruncatedZeroMeanNormal(MShiftSd,maxZ) ...
        TruncatedZeroMeanNormal(SShiftSd,maxZ) ]';
    T_conesRnd{ee} = ComputeObserverFundamentals(coneParamsRnd{ee},S);

    subplot(1,2,1); hold on;
    plot(wls,T_conesRnd{ee}(1,:),'r','LineWidth',1);
    plot(wls,T_conesRnd{ee}(2,:),'g','LineWidth',1);
    plot(wls,T_conesRnd{ee}(3,:),'b','LineWidth',1);

    subplot(1,2,2); hold on;
    plot(wls,log10(T_conesRnd{ee}(1,:)),'r','LineWidth',1);
    plot(wls,log10(T_conesRnd{ee}(2,:)),'g','LineWidth',1);
    plot(wls,log10(T_conesRnd{ee}(3,:)),'b','LineWidth',1);
end

subplot(1,2,1); hold on;
switch (coneParams.fieldSizeDegrees)
    case 2
        plot(SToWls(S_cones_ss2),T_cones_ss2,'k:','LineWidth',3);
    case 10
        plot(SToWls(S_cones_ss10),T_cones_ss10,'k:','LineWidth',3);
end
xlabel('Wavelength (nm)');
ylabel('Number of excitations'); grid on;
title('Cone fundamental (normalized) with spectrum in energy units');

subplot(1,2,2); hold on;
switch (coneParams.fieldSizeDegrees)
    case 2
        plot(SToWls(S_cones_ss2),log10(T_cones_ss2),'k:','LineWidth',3);
    case 10
        plot(SToWls(S_cones_ss10),log10(T_cones_ss10),'k:','LineWidth',3);
end
xlabel('Wavelength (nm)');
ylabel('Number of excitations'); grid on;
title('Cone fundamental (normalized) with spectrum in energy units');

function val = TruncatedZeroMeanNormal(sd,maxZ)
val = normrnd(0,sd);
if (val > maxZ*sd)
    val = maxZ*sd;
end
if (val < -maxZ*sd)
    val = -maxZ*sd;
end
end