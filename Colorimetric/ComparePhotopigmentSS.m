function ComparePhotopigmentSS(pigmentA, pigmentB)
% ComparePhotopigmentSS(pigmentA, pigmentB)
%
% Generate spectral sensitivities and compare them.
S = [380 2 201];
T1 = GetHumanPhotopigmentSS(S, {pigmentA}, [], [], [], []);
T2 = GetHumanPhotopigmentSS(S, {pigmentB}, [], [], [], []);

theFig = figure;
% Plot them on top of each other and against each other.
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
semilogy(SToWls(S), T1, '-k'); hold on;
semilogy(SToWls(S), T2, '-r');
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
plot(log10(T1), log10(T2), '.k'); hold on;
plot([-8 0], [-8 0], '--k');
xlim([-8 0]);
ylim([-8 0]);
xlabel(['log Rel. sensitivity (' pigmentA ')']);
ylabel(['log Rel. sensitivity (' pigmentB ')']);
title(['Comparison ' pigmentA ' vs. ' pigmentB]);
pbaspect([1 1 1]);

set(theFig, 'PaperPosition', [0 0 8 8]); %Position plot at left hand corner with width 5 and height 5.
set(theFig, 'PaperSize', [8 8]); %Set the paper to have width 5 and height 5.
saveas(theFig, ['Comparison_' pigmentA '-' pigmentB '.pdf'], 'pdf')