% ModalityToolboxDemo
%
% Demo that demonstrates
% - Silverman's test for modality (Silverman, 1981)
%       See also SilvermansTest
%
% - Hartigan's dip test (Hartigan & Hartigan, 1985; Hartigan, 1985).
%       See also HartigansDipTest, HartigansDipTestBootstrap
%
% - Test by RE Strauss (found on-line, not in literature)
%
% References:
% - Silverman, B.W. (1981). Using kernel density estimates to
%   investigate multimodality. Journal of the Royal Statistical Society B
%   43, 97-99.
% - Hartigan, J.A. and P.M. Hartigan. 1985. The dip test of unimodality.
%   Annals of Statistics 13: 70-84.
% - Hartigan, P.M. 1985. Algorithm AS 217: Computation of the dip statistic
%   to test for unimodality. Applied Statistics 34: 320-325.
%
% Two cases are examined: Mixture of Gaussians with different means, and a
% real data set of meteoites (cited in Silverman, 1981; table 2 in Good &
% Gaskins, 1980).

% Blank slate
clear all; close all;

% Some general parameters
nSamples = 1000; % Number of samples
nBoot = 1000;    % Number of bootstrap samples
nHistBins = 20;  % Number of histogram bins
max_k = 6;      % Maximum number of modes expected

%% Synthesized Gaussian mixture
% Set up two Gaussians, one of them has a fixed mean (mu1), the other one
% (mu2) can be in the interval [1, 9]. The variance of the two (var) is the
% same).
mu1 = 0;
mu2 = linspace(0, 5, 9);
var = 1;

% Iterate over mu2 and calculate relevant statistics
for i = 1:length(mu2)
    % Generate samples.
    xSamples(i,:) = sort([mu1 + randn(1, nSamples) mu2(i) + randn(1, nSamples)]);
    
    % Hartigan's Test
    [dip(i), p(i), ~, ~, bootDip{i}] = HartigansDipBootstrap(xSamples(i,:), nBoot);
    
    % Strauss' test
    [strausscoeff(i),pr(i)] = StraussTest(xSamples(i,:), nBoot);
    
    % Silverman's test
    [m, prsilver] = SilvermansTest(xSamples(i, :), nBoot, max_k);
    
    disp(['Hartigan''s dip statistic: ' num2str(dip(i)) ' (p = ' num2str(p(i)) ')']);
    disp(['Strauss statistic: ' num2str(strausscoeff(i)) ' (p = ' num2str(pr(i)) ')']);
    
    for j = 1:max_k
       disp(['Silverman''s test (max_k = ' num2str(max_k) ')']);
       disp(['k = ' num2str(j) ' (p = ' num2str(prsilver(j)) ')']);
    end
end

figure;
% Plot the histograms
for i = 1:length(mu2)
    % Plot histograms of samples.
    subplot(3, 3, i)
    
    % Normalize the histogram
    [f, x] = hist(xSamples(i,:), nHistBins);
    bar(x,f/trapz(x,f)); hold on
    
    xlim([-10 10]);
    ylim([0 0.5]);
    xlabel('Value');
    ylabel('Density');
    pbaspect([1 1 1]);
end


%% Real data set
% Table 2 in Good & Gaskins (1980)
xSamples = [20.77 22.56 22.71 22.99 26.39 27.08 27.32 27.33 22.57 27.81 28.69 ...
    29.36 30.25 31.89 32.88 33.23 33.28 33.40 33.52 33.83 33.95 34.82];
% Hartigan's Test
[dip(i), p(i), ~, ~, bootDip{i}] = HartigansDipBootstrap(xSamples, nBoot);

% Strauss' test
[strausscoeff(i),pr(i)] = StraussTest(xSamples, nBoot);

% Silverman's test
[m, p] = SilvermansTest(xSamples, nBoot, max_k);


figure;
% Normalize the histogram
[f, x] = hist(xSamples(i,:), nHistBins);
bar(x,f/trapz(x,f)); hold on