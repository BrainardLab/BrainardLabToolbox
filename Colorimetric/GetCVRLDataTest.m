% GetCVRLDataTest
%
% Test the GetCVRLData routine.  Not every case is tested
% here, but the routine does try to probe the key cases
%
% 1/2/10  dhb  Wrote it.

%% Clear out
clear; close all;

%% Linear ss2 fundamentals
%
% Get at three spacings from CVRL.
[T_ss2_5nm,wls_ss2_5nm] = GetCVRLData('ss2');
[T_ss2_1nm,wls_ss2_1nm] = GetCVRLData('ss2',1);
[T_ss2_01nm,wls_ss2_01nm] = GetCVRLData('ss2',0.1);

% Load in Psychtoolbox version of this same data
load T_cones_ss2
wls_cones_ss2 = SToWls(S_cones_ss2);

% Make sure they all look the same when plotted
[ss2Plot,f] = StartFigure('3colsub');
f.xrange = [350 850]; f.nxticks = 6;
f.yrange = [0 1]; f.nyticks = 8;
f.xtickformat = '%d'; f.ytickformat = '%0.1f ';

subplot(1,3,1); hold on
plot(wls_ss2_01nm,T_ss2_01nm(1,:)','r','LineWidth',f.basiclinewidth);
plot(wls_cones_ss2,T_cones_ss2(1,:)','k','LineWidth',f.smalllinewidth);
plot(wls_ss2_5nm,T_ss2_5nm(1,:)','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
plot(wls_ss2_1nm,T_ss2_1nm(1,:)','kx','MarkerSize',f.smallmarkersize);
xlabel('Wavelength (nm)','FontName',f.fontname,'FontSize',f.labelfontsize);
ylabel('L Sensitivity','FontName',f.fontname,'FontSize',f.labelfontsize);
title('SS-2','FontName',f.fontname,'FontSize',f.titlefontsize);
FinishFigure(ss2Plot,f);

subplot(1,3,2); hold on
plot(wls_ss2_01nm,T_ss2_01nm(2,:)','g','LineWidth',f.basiclinewidth);
plot(wls_cones_ss2,T_cones_ss2(2,:)','k','LineWidth',f.smalllinewidth);
plot(wls_ss2_5nm,T_ss2_5nm(2,:)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
plot(wls_ss2_1nm,T_ss2_1nm(2,:)','kx','MarkerSize',f.smallmarkersize);
xlabel('Wavelength (nm)','FontName',f.fontname,'FontSize',f.labelfontsize);
ylabel('M Sensitivity','FontName',f.fontname,'FontSize',f.labelfontsize);
title('SS-2','FontName',f.fontname,'FontSize',f.titlefontsize);
FinishFigure(ss2Plot,f);

subplot(1,3,3); hold on
plot(wls_ss2_01nm,T_ss2_01nm(3,:)','b','LineWidth',f.basiclinewidth);
plot(wls_cones_ss2,T_cones_ss2(3,:)','k','LineWidth',f.smalllinewidth);
plot(wls_ss2_5nm,T_ss2_5nm(3,:)','bo','MarkerSize',f.basicmarkersize,'MarkerFaceColor','b');
plot(wls_ss2_1nm,T_ss2_1nm(3,:)','kx','MarkerSize',f.smallmarkersize);
xlabel('Wavelength (nm)','FontName',f.fontname,'FontSize',f.labelfontsize);
ylabel('S Sensitivity','FontName',f.fontname,'FontSize',f.labelfontsize);
title('SS-2','FontName',f.fontname,'FontSize',f.titlefontsize);
FinishFigure(ss2Plot,f);

%% Make sure log units work
[T_loge_ss2,wls_loge_ss2] = GetCVRLData('ss2',1,'logenergy');
[T_logq_ss2,wls_logq_ss2] = GetCVRLData('ss2',1,'logquanta');

% Convert the quantal units sensitivities to energy units, and normalize
% each to max of 0 by subtraction.  The normalization is necessary
% because the CVRL convention is to normallize both energy and quantal
% units to a maximum log10 value of 0.
%
% Although we are converting quantal sensitivities to energy sensitivities,
% we call Psychtoolbox routine EnergyToQuanta. That's because the toolbox
% routine is specified with respect to spectra, and the conversion for
% sensitivities is the inverse of the conversion for spectra.
T_logqconv_ss2 = log10(EnergyToQuanta(wls_logq_ss2,10.^T_logq_ss2')');
for i = 1:3
    T_logqconv_ss2(i,:) = T_logqconv_ss2(i,:)-max(T_logqconv_ss2(i,:));
end

% Plot.  The converted logquanta sensitivities should overlay the
% log energy sensitivities, which they do.
[ss2logPlot,f] = StartFigure('standard');
f.xrange = [350 850]; f.nxticks = 6;
f.yrange = [-7 0]; f.nyticks = 8;
f.xtickformat = '%d'; f.ytickformat = '%d ';

plot(wls_loge_ss2,T_loge_ss2(1,:)','r','LineWidth',f.basiclinewidth);
plot(wls_loge_ss2,T_loge_ss2(2,:)','g','LineWidth',f.basiclinewidth);
plot(wls_loge_ss2,T_loge_ss2(3,:)','b','LineWidth',f.basiclinewidth);
plot(wls_logq_ss2,T_logqconv_ss2(1,:)','k','LineWidth',f.smalllinewidth);
plot(wls_logq_ss2,T_logqconv_ss2(2,:)','k','LineWidth',f.smalllinewidth);
plot(wls_logq_ss2,T_logqconv_ss2(3,:)','k','LineWidth',f.smalllinewidth);

xlabel('Wavelength (nm)','FontName',f.fontname,'FontSize',f.labelfontsize);
ylabel('Log10 Sensitivity','FontName',f.fontname,'FontSize',f.labelfontsize);
title('SS-2','FontName',f.fontname,'FontSize',f.titlefontsize);
FinishFigure(ss2logPlot,f);

%% Test Stockman, MacLeod, Johnson data.  This has some conversion and
% splining which would be good to make sure work more or less.
[T_smj2_10_1nm,wls_smj2_10_1nm] = GetCVRLData('smj2_10',1,'energy');
[T_smj2_10loge_5nm,wls_smj2_10loge_5nm] = GetCVRLData('smj2_10',5,'logenergy');

% Plot them
[smj2Plot,f] = StartFigure('standard');
f.xrange = [400 700]; f.nxticks = 4;
f.yrange = [0 1]; f.nyticks = 6;
f.xtickformat = '%d'; f.ytickformat = '%0.1f ';

plot(wls_smj2_10_1nm,T_smj2_10_1nm(1,:)','r','LineWidth',f.basiclinewidth);
plot(wls_smj2_10_1nm,T_smj2_10_1nm(2,:)','g','LineWidth',f.basiclinewidth);
plot(wls_smj2_10_1nm,T_smj2_10_1nm(3,:)','b','LineWidth',f.basiclinewidth);
plot(wls_smj2_10loge_5nm,10.^T_smj2_10loge_5nm(1,:)','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
plot(wls_smj2_10loge_5nm,10.^T_smj2_10loge_5nm(2,:)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
plot(wls_smj2_10loge_5nm,10.^T_smj2_10loge_5nm(3,:)','bo','MarkerSize',f.basicmarkersize,'MarkerFaceColor','b');

xlabel('Wavelength (nm)','FontName',f.fontname,'FontSize',f.labelfontsize);
ylabel('Sensitivity','FontName',f.fontname,'FontSize',f.labelfontsize);
title('SMJ 2-deg from 10-deg CMFs','FontName',f.fontname,'FontSize',f.titlefontsize);
FinishFigure(smj2Plot,f);

%% Test DeMarco, Pokorny, Smith, which has its own path
[T_dps_01nm,wls_dps_01nm] = GetCVRLData('dps',0.1,'energy');
[T_dps_logq,wls_dps_logq] = GetCVRLData('dps',5,'logquanta');
T_logqconv_dps = EnergyToQuanta(wls_dps_logq,10.^T_dps_logq')';
for i = 1:3
    T_logqconv_dps(i,:) = T_logqconv_dps(i,:)/max(T_logqconv_dps(i,:));
end

% Psychtoolbox version
load T_cones_sp
wls_cones_sp = SToWls(S_cones_sp);

% Plot them
[dpsPlot,f] = StartFigure('standard');
f.xrange = [400 700]; f.nxticks = 4;
f.yrange = [0 1]; f.nyticks = 6;
f.xtickformat = '%d'; f.ytickformat = '%0.1f ';

plot(wls_dps_01nm,T_dps_01nm(1,:)','r','LineWidth',f.basiclinewidth);
plot(wls_dps_01nm,T_dps_01nm(2,:)','g','LineWidth',f.basiclinewidth);
plot(wls_dps_01nm,T_dps_01nm(3,:)','b','LineWidth',f.basiclinewidth);
plot(wls_cones_sp,T_cones_sp(1,:)','ro','MarkerSize',f.basicmarkersize,'MarkerFaceColor','r');
plot(wls_cones_sp,T_cones_sp(2,:)','go','MarkerSize',f.basicmarkersize,'MarkerFaceColor','g');
plot(wls_cones_sp,T_cones_sp(3,:)','bo','MarkerSize',f.basicmarkersize,'MarkerFaceColor','b');
plot(wls_dps_logq,T_logqconv_dps','ko','MarkerSize',f.smallmarkersize,'MarkerFaceColor','k');

xlabel('Wavelength (nm)','FontName',f.fontname,'FontSize',f.labelfontsize);
ylabel('Sensitivity','FontName',f.fontname,'FontSize',f.labelfontsize);
title('DeMarco, Pokorny, Smith','FontName',f.fontname,'FontSize',f.titlefontsize);
FinishFigure(dpsPlot,f);
