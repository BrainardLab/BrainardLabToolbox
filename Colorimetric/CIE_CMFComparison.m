% CIE_CMFComparison.m
%
% This function compares different CMFs, namely CIE 1931 and CIE 2012,
% derived from the Stockman-Sharpe cone fundamentals for 2 and 10 degrees.
% These are related to CMFs using a linear transformation. See links below.
%
% 11/28/13  ms      Wrote it.

theFigure = figure;

%% Load in CIE 1931 xyz and plot
load T_xyz1931
subplot(2, 3, 1); plot(SToWls(S_xyz1931), T_xyz1931); xlim([380 780]); ylim([-0.05 2.5]);
xlabel('Wavelength [nm]'); ylabel('Tristimulus value'); pbaspect([1 1 1]);
title('CIE 1931 XYZ');

%% Load in CIE 1964 xyz and plot
load T_xyz1964
subplot(2, 3, 4); plot(SToWls(S_xyz1964), T_xyz1964); xlim([380 780]); ylim([-0.05 2.5]);
xlabel('Wavelength [nm]'); ylabel('Tristimulus value'); pbaspect([1 1 1]);
title('CIE 1964 XYZ');

%% Load in the 2-deg S-S cone fundamentals (CIE 2006)
load T_cones_ss2

% Transform these into color matching functions using a linear combination.
% See http://www.cvrl.org/database/text/cienewxyz/cie2012xyz2.htm. The
% following linear weights were obtained on Nov 28, 2013.
M_ss2 = [   +1.94735469 -1.41445123 +0.36476327 ;
            +0.68990272 +0.34832189 +0.00000000 ;
            +0.00000000 +0.00000000 +1.93485343];
        
% Multiply and plot
T_xyz_ss2 = M_ss2 * T_cones_ss2;

subplot(2, 3, 2); plot(SToWls(S_cones_ss2), T_xyz_ss2); xlim([380 780]); ylim([-0.05 2.5]);
hold on; plot(SToWls(S_xyz1931), T_xyz1931, 'LineStyle', '--', 'Color', [0.3 0.3 0.3]);  % CIE 1931 for reference
xlabel('Wavelength [nm]'); ylabel('Tristimulus value'); pbaspect([1 1 1]);
title({'CIE (2012) 2-deg XYZ' '"physiologically-relevant" CMFs'});

% Compare CIE 1931 and CIE 2012
subplot(2, 3, 3);

% Resample T_xyz1931 to S_cones_ss2
T_xyz1931_interp = SplineCmf(S_xyz1931, T_xyz1931, S_cones_ss2);
theRGB = [0 0 0]';
for i = 1:3
    tmpRGB = theRGB; tmpRGB(4-i) = 1;
    plot(T_xyz1931_interp(i, :), T_xyz_ss2(i, :), '.', 'Color', tmpRGB); hold on;
end
pbaspect([1 1 1]);
xlim([-0.05 2.5]); ylim([-0.05 2.5]); plot([-0.05 2.5], [-0.05 2.5], '--k');
xlabel('Tristimulus value (CIE 1931)'); ylabel('Tristimulus value (CIE 2012)');

%% Load in the 10-deg S-S cone fundamentals (CIE 2006)
load T_cones_ss10

% Transform these into color matching functions using a linear combination.
% See http://www.cvrl.org/database/text/cienewxyz/cie2012xyz10.htm. The
% following linear weights were obtained on Nov 28, 2013.
M_ss10 = [   +1.93986443 -1.34664359 +0.43044935 ; 
             +0.69283932 +0.34967567 +0.00000000 ;
             +0.00000000 +0.00000000 +2.14687945 ];

% Multiply and plot
T_xyz_ss10 = M_ss10 * T_cones_ss10;
subplot(2, 3, 5); plot(SToWls(S_cones_ss10), T_xyz_ss10); xlim([380 780]); ylim([-0.05 2.5]);
hold on; plot(SToWls(S_xyz1964), T_xyz1964, 'LineStyle', '--', 'Color', [0.3 0.3 0.3]);  % CIE 1931 for reference
xlabel('Wavelength [nm]'); ylabel('Tristimulus value'); pbaspect([1 1 1]);
title({'CIE (2012) 10-deg XYZ' '"physiologically-relevant" CMFs'});

% Compare CIE 1964 and CIE 2012 (10 deg)
subplot(2, 3, 6);

% Resample T_xyz1931 to S_cones_ss2
T_xyz1964_interp = SplineCmf(S_xyz1964, T_xyz1964, S_cones_ss10);
theRGB = [0 0 0]';
for i = 1:3
    tmpRGB = theRGB; tmpRGB(4-i) = 1;
    plot(T_xyz1964_interp(i, :), T_xyz_ss10(i, :), '.', 'Color', tmpRGB); hold on;
end
pbaspect([1 1 1]);
xlim([-0.05 2.5]); ylim([-0.05 2.5]); plot([-0.05 2.5], [-0.05 2.5], '--k');
xlabel('Tristimulus value (CIE 1964)'); ylabel('Tristimulus value (CIE 2012)');

set(theFigure, 'PaperPosition', [0 0 15 10]); %Position plot at left hand corner with width 15 and height 6.
set(theFigure, 'PaperSize', [15 10]); %Set the paper to have width 15 and height 6.
saveas(theFigure, 'CIE_CMFComparison.pdf', 'pdf');