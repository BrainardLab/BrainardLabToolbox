% calibrationTutorial.
%
% Exercise to learn about calibration.  Does a calculation of
% how to gamma correct and color transform "by hand" and then
% does it using PTB routines, for comparison.
%
% 9/5/08,  dhb, ik  Outlined the goal
% 9/9/08   dhb      Cosmetic changes
%          dhb      Initialize min_diff for each of three guns.
% 12/02/09 dhb      Fix up some bugs because we're now in the 0-1 world, not DAC values.
% 05/27/10 dhb      Prompt for input file, simplify logic and checks.
% 09/28/17 dhb      Update savefig->FigureSave and new location of S in cal structure.

%% Clear
clear; close all;

%% Load a test calibration file
cal = GetCalibrationStructure('\nEnter a calibration filename','FrontRoomLex',[]);

% Get wavelength sampling of functions in cal file.
S = cal.rawData.S;

%% Plot the ambient light
figure(1);
plot(SToWls(S),cal.processedData.P_ambient,'k');
title( 'Monitor Ambient' ) 
xlabel( 'Wavelength [ nm ]' ), ylabel( 'Radiance [ W / m^2 / sr / nm ]' ) 
ambient = cal.processedData.P_ambient;

%% Plot the three monitor phosphors.  Each phosphor spectrum is in a separate
% column of the matrix cal.P_device.  In MATLAB, can use the : operator to
% help extract various pieces of a matrix.  So:
redPhosphor = cal.processedData.P_device(:,1);
greenPhosphor = cal.processedData.P_device(:,2);
bluePhosphor = cal.processedData.P_device(:,3);
figure(2);clf; hold on
set(gca,'FontName','Helvetica','FontSize',18);
plot(SToWls(S),redPhosphor,'r','LineWidth',3);  %%correct to change from S_ambient? 
plot(SToWls(S),greenPhosphor,'g','LineWidth',3);;
plot(SToWls(S),bluePhosphor,'b','LineWidth',3);
title( 'Monitor channel spectra','FontSize',24);
xlabel( 'Wavelength [ nm ]','FontSize',24); ylabel( 'Radiance [ W / m^2 / sr / nm ]','FontSize',24);
hold off
saveas(gcf,'MonitorSpectraMetropsis.pdf');

%% Plot the gamma curves
% 14 bit display => 16384 input levels
nBits = 14;
figure(3); clf; hold on
set(gca,'FontName','Helvetica','FontSize',18);
gammaInput = cal.processedData.gammaInput;
redGamma = cal.processedData.gammaTable(:,1);
greenGamma = cal.processedData.gammaTable(:,2);
blueGamma = cal.processedData.gammaTable(:,3);
plot(gammaInput,redGamma,'r','LineWidth',3);
plot(gammaInput,greenGamma,'g','LineWidth',3);
plot(gammaInput,blueGamma,'b','LineWidth',3);
title( 'Monitor gamma curves','FontSize',24);
xlabel( 'Input RGB','FontSize',24); ylabel( 'Normalized Output','FontSize',24);
hold off
saveas(gcf,'MonitorGammaMetropsis.pdf');

%% Plot the human cones.
%
% Just doing this here because I need this plot in the
% same format as the monitor stuff for a talk.
load T_cones_ss2
figure(4); clf; hold on
set(gca,'FontName','Helvetica','FontSize',18);
plot(SToWls(S_cones_ss2),T_cones_ss2(1,:),'r','LineWidth',3);
plot(SToWls(S_cones_ss2),T_cones_ss2(2,:),'g','LineWidth',3);;
plot(SToWls(S_cones_ss2),T_cones_ss2(3,:),'b','LineWidth',3);
title( 'LMS Cone Fundamentals','FontSize',24);
xlabel( 'Wavelength','FontSize',24); ylabel( 'Sensitivity','FontSize',24);
hold off
saveas(gcf,'ConeFundamentals.pdf');

%% Get and plot the XYZ color matching functions.  See "help PsychColorimetricMatFiles'
load T_xyz1931

%% Spline wavelength spacing of color matching functions to match calibration.  The
% factor of 683 makes the units of luminance cd/m2.
T_xyz = 683*SplineCmf(S_xyz1931,T_xyz1931,S);
figure(5);
plot(SToWls(S),T_xyz');
title( 'Color matching functions' ) 
xlabel( 'Wavelength [ nm ]' ), ylabel( 'Spectral sensitivities');

%% Standard initialization of calibration structure
cal = SetSensorColorSpace(cal,T_xyz,S);
cal = SetGammaMethod(cal,0);

%% Choose a target XYZ that is within monitor gamut.
% 
% We'll do this using Psychtoolbox calibration code.
targetrgb = [0.4 0.7 0.6]';
targetXYZ = PrimaryToSensor(cal,targetrgb);

%% Here's how we compute RGB with calibration routines.
targetRGB = SensorToSettings(cal,targetXYZ);
calComputeXYZ = SettingsToSensor(cal,targetRGB);
if (max(abs(targetXYZ-calComputeXYZ))/min(abs(targetXYZ)) < 0.001)
    fprintf('Psychtoolbox XYZ from RGB calculation obtains target to better than 0.1%%\n');
else
    fprintf('Psychtoolbox XYZ from RGB calculation misses target by more than 0.1%%\n');
end

%% And this goes back to the specified linear rgb values, from either RGB or XYZ
calComputergb = SettingsToPrimary(cal,targetRGB);
if (max(abs(targetrgb-calComputergb))/min(abs(targetrgb)) < 0.001)
    fprintf('Psychtoolbox rgb from RGB calculation obtains target to better than 0.1%%\n');
else
    fprintf('Psychtoolbox rgb from RGB calculation misses target by more than 0.1%%\n');
end
calComputergb2 = SensorToPrimary(cal,targetXYZ);
if (max(abs(targetrgb-calComputergb2))/min(abs(targetrgb)) < 0.001)
    fprintf('Psychtoolbox rgb from XYZ calculation obtains target to better than 0.1%%\n');
else
    fprintf('Psychtoolbox rgb from XYZ calculation misses target by more than 0.1%%\n');
end

%% Manual calibration computations, from RGB to XYZ
%
% Use measured gamma curves to get linear rgb
[nil,indexR] = min(abs(gammaInput-targetRGB(1)));
[nil,indexG] = min(abs(gammaInput-targetRGB(2)));
[nil,indexB] = min(abs(gammaInput-targetRGB(3)));
r = redGamma(indexR);
g = greenGamma(indexG);
b = blueGamma(indexB);
rgb = [r g b]';

% Add up the phosphors, weighed by the linear r, g, and b
% value.
spectrum = r*redPhosphor + g*greenPhosphor + b*bluePhosphor;

% Add in the ambient light from the monitor.  
spectrum = spectrum + ambient;

% Now go from the spectrum to the XYZ values.  That is, compute XYZ for the
% spectrum you computed just above.
XYZ = T_xyz*spectrum;

% Verify that we correctly predict the target to reasonable precision
if (max(abs(targetXYZ-XYZ))/min(abs(targetXYZ)) < 0.001)
    fprintf('Manual XYZ from RGB calculation obtains target to better than 0.1%%\n');
else
    fprintf('Manual XYZ from RGB calculation misses target by more than 0.1%%\n');
end

%% Manual calculation of RGB from targetXYZ 

% Compute the matrix that takes phosphor spectra to XYZ
Mrgb2xyz = T_xyz*cal.P_device(:,1:3);
Mxyz2rgb = inv(Mrgb2xyz);

% Subtract ambient light XYZ target XYZ
tempXYZ = targetXYZ - T_xyz*ambient;

% Use matrix to compute desired rgb from specified XYZ.
manualComptuergb = Mxyz2rgb * tempXYZ;  

% Convert linear rgb to actual settings (gamma correct).  For this, you need to find the input
% values in gammaInput that makes the output as close as possible to the desired
% r, g, and b values.  These can be compared to the RGB values used to produce
% the target XYZ.  This is done here in a little subfunction called SimpleGammaCorrection
nLevels = length(gammaInput);
OUT_R = SimpleGammaCorrection(nLevels,gammaInput,redGamma,manualComptuergb(1));
OUT_G = SimpleGammaCorrection(nLevels,gammaInput,greenGamma,manualComptuergb(2));
OUT_B = SimpleGammaCorrection(nLevels,gammaInput,blueGamma,manualComptuergb(3)); 
manualComputeRGB = [OUT_R OUT_G OUT_B]';

% Verify that we correctly predict the target to reasonable precision
if (max(abs(targetRGB-manualComputeRGB))/min(abs(targetRGB)) < 0.001)
    fprintf('Manual RGB from XYZ calculation obtains target to better than 0.1%%\n');
else
    fprintf('Manual RGB from XYZ calculation misses target by more than 0.1%%\n');
end

%% Report of some things we might care about.  These
% can be checked against the numbers that were input
% and should match.
%
% The CCT doesn't agree with what SV outputs, however.
% This may be a bug in SV, in cct, or a fact that the
% standard is a bit underspecified.
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
whiteLum = predRedxyY(3) + predGreenxyY(3) + predBluexyY(3);
fprintf('RGB normalized luminances: %0.3f %0.3f %0.3f\n',predRedxyY(3)/whiteLum,predGreenxyY(3)/whiteLum,predBluexyY(3)/whiteLum);

