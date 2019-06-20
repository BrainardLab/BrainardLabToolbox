% colorTransformAssignment
%
% Skeleton assignment for thinking about transformations
% between color spaces.
%
% The beginning part loads in the spectral data you'll need
% from files that are part of the Psychophysics Toolbox.  All
% are at the same underlying wavelength sampling [380 5 81].
%
% 1/20/10  dhb  Wrote it.

%% Clear
clear; close all;

%% Load in some color matching functions
% and cone fundamentals to play with.
%
% Judd-Vos XYZ functions and Smith-Pokorny
% cone fundamentals are consistent with the
% same observer, so we'll use those.
load T_xyzJuddVos
load T_cones_sp

%% Load in some primaries.  Typical monitor
% primaries seem as good as anything.
load B_monitor

% Load in a spectral power distribution.
load spd_D65

%% 1) Compute the tristimulus coordinates and
% cone responses to spd_D65

tristimulusCoordinates = T_xyzJuddVos * spd_D65;
coneResponses = T_cones_sp * spd_D65;

%% 2) Find the linear transformation M_XYZToCones
% that maps XYZ tristimulus coordinates to
% cone responses.
%M_XYZToCones = [0.2420, 0.8526, -0.0445; -0.3896, 1.1601, 0.0853; 0.0034, -0.0018, 0.5643];
xyzToBasis = inv(T_xyzJuddVos * B_monitor); 
basisToCones = (T_cones_sp * B_monitor);

M_XYZToCones = (basisToCones * xyzToBasis); %why not the other way around? 
%M_XYZToCones = ((T_xyzJuddVos')\(T_cones_sp'))'

% Verify by making a plot that applying this to
% the XYZ color matching functions reproduces
% the cone fundamentals.
plot(SToWls(S_cones_sp), T_cones_sp, 'r-', SToWls(S_xyzJuddVos), M_XYZToCones * T_xyzJuddVos, 'b-');

%
% Verify that applying this matrix to the tristimulus
% vector you obtained explicitly for spd_D65 produces
% the cone coordinates you obtained explicitly for
% spd_D65.
calcConeResponses = M_XYZToCones * tristimulusCoordinates;
coneDifference = abs(calcConeResponses - coneResponses);
fprintf('tristimulus to cone difference is ');
fprintf('%g ', coneDifference);
fprintf('\n');

% Verify that obtaining M_ConesToXYZ by taking the
% inverse of M_XYZToCones works for the other direction.
M_ConesToXYZ = inv(M_XYZToCones);
calcConesToTristimulus = M_ConesToXYZ * coneResponses;
conesToTristimulusDifference = abs(calcConesToTristimulus - tristimulusCoordinates);
fprintf('cone to tristimulus difference is ');
fprintf('%g ', conesToTristimulusDifference);
fprintf('\n');

%% 3) Find the linear transformation M_XYZTorgb that
% obtains the linear phosphor weights rgb from desired
% XYZ coordinates.
xyzToBasis = inv(T_xyzJuddVos * B_monitor); 

% Compute the rgb values that are needed to produce
% a metamer on the monitor for spd_D65, using this
% matrix and the tristimulus values for spd_D65.
rgbValues = xyzToBasis * tristimulusCoordinates; 

% Reconstruct the spectrum that comes off the monitor
% when you use the rgb values above, and compute the
% tristimulus coordinates of this spectrum.  Verify that
% they match those of spd_D65.
calcSpectrum = B_monitor * rgbValues;
calcRgbToTristimulus = T_xyzJuddVos * calcSpectrum;

rgbToTristimulusDifference = abs(calcRgbToTristimulus - tristimulusCoordinates);
fprintf('rgb to tristimulus difference is ');
fprintf('%g ', rgbToTristimulusDifference);
fprintf('\n');

%
% Plot spd_D65 and the metameric light that comes from the
% monitor, to verify that even though they have the same
% tristimulus values, they are physically different.
figure(2);
plot(SToWls(S_monitor), spd_D65, 'b-', SToWls(S_monitor), calcSpectrum, 'r-');

%% 4) Constrcut a matrix B_monochrom that describes monochromatic
% primaries, one with power at 440 nm, one with power at 520 nm,
% and one with power at 650 nm.  Each column of this matrix should
% be the vector representation of one monochromatic light.
%
% Compute a matrix that transforms between rgb values for the
% monitor and rgb values with respect to these primaries, such
% that the two sets of rgb values produce metamers.  
%
% Verify that the metamer you get by applying your matrix and
% reconstructing the weighted sum of monochromatic primaries
% has the right properties, by expliclity computing tristimulus 
% values.