function ComparePhotopigmentSS(pigmentA, pigmentB)
% ComparePhotopigmentSS(pigmentA, pigmentB)
%
% Generate spectral sensitivities and compare them.
%
% This is called by HumanPhotopigmentSSTest.
%
% 5/26/14  dhb  Update calling interface.  Add comments.
%          dhb  The plot generation code crashed on my machine.  Replaced with 
%               a style that works for me.
%          dhb  Prevent warning in call to semilog/log10 by removing numbers <= 0 from plotting.

S = [380 2 201];
wls = SToWls(S);
T1 = GetHumanPhotopigmentSS(S, {pigmentA}, [], [], [], [],[]);
T2 = GetHumanPhotopigmentSS(S, {pigmentB}, [], [], [], [],[]);
index1 = find(T1 > 0);
index2 = find(T2 > 0);
index3 = find(T1 > 0 & T2 > 0);

% Plot the two spectral sensitivities on top of one another.
theFig = figure;
set(gcf,'Position',[100 100 1000 1000]);
set(gca,'FontName','Helvetica','FontSize',14);
subplot(2, 2, 1);
plot(SToWls(S), T1, '-k'); hold on;
plot(SToWls(S), T2, '-r');
legend(pigmentA, pigmentB); legend boxoff;
xlim([380 780]);
ylim([0 1]);
xlabel('Wavelength [nm]');
ylabel('Rel. sensitivity');
title(['Comparison ' pigmentA ' vs. ' pigmentB]);
pbaspect([1 1 1]);

subplot(2, 2, 2);
index = find(T1 > 0);
semilogy(wls(index1), T1(index1), '-k'); hold on;
semilogy(wls(index2), T2(index2), '-r');
legend(pigmentA, pigmentB); legend boxoff;
xlim([380 780]);
ylim([10^-8 10^0]);
xlabel('Wavelength [nm]');
ylabel('log Rel. sensitivity');
title(['Comparison ' pigmentA ' vs. ' pigmentB]);
pbaspect([1 1 1]);

subplot(2, 2, 3);
plot(T1, T2, '.k'); hold on;
plot([0 1], [0 1], '--k');
xlim([0 1]);
ylim([0 1]);
xlabel(['Rel. sensitivity (' pigmentA ')']);
ylabel(['Rel. sensitivity (' pigmentB ')']);
title(['Comparison ' pigmentA ' vs. ' pigmentB]);
pbaspect([1 1 1]);

subplot(2, 2, 4);
plot(log10(T1(index3)), log10(T2(index3)), '.k'); hold on;
plot([-8 0], [-8 0], '--k');
xlim([-8 0]);
ylim([-8 0]);
xlabel(['log Rel. sensitivity (' pigmentA ')']);
ylabel(['log Rel. sensitivity (' pigmentB ')']);
title(['Comparison ' pigmentA ' vs. ' pigmentB]);
pbaspect([1 1 1]);

if (~exist('xTestPlots','dir'))
    mkdir('xTestPlots');
end
FigureSave(fullfile('xTestPlots',['Comparison_' pigmentA '_' pigmentB]),theFig,'pdf');
