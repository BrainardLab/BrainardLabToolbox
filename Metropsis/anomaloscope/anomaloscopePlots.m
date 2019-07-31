function anomaloscopePlots(varargin)
% Plots protanope and deuteranope anomaloscope matches
%
% Syntax:
%    anomaloscopePlots
%
% Description:
%    This routine plots Rayleigh matches made by protanopes and
%    deuteranopes who were tested on an Oculus-HMC anomaloscope (data
%    obtained by dce, summer 2019). The routine produces and saves four
%    plots: one of protanopes' matches, one of deuteranopes' matches, one
%    comparing the matches of protanopes and of deuteranopes with two
%    L-cone variants, and one plotting a least-squares line of best fit for
%    each subject. To avoid overwriting files, it is advidable to change
%    default PDF filenames. Data points were obtained from PDF reports of
%    anomaloscope results using a pixel color algorithm on
%    WebPlotDigitizer, a free online program.
%
% Inputs
%    none
%
% Outputs
%    none. Saves plots as PDF files in an experimental directory
%
% Optional key-value pairs
%    'pittDiagram'    -logical indicating whether to plot results on the
%                      background of an anomaloscope Pitt diagram. Default
%                      is true.

% History:
%    07/25/19  dce       Wrote routine

% Examples:
%{
    anomaloscopePlots('pittDiagram', false)
%}

%% Parse input
p = inputParser;
p.addParameter('pittDiagram', true, @(x) (islogical(x)));
p.parse(varargin{:});

%% Load data. If applicable, load Pitt diagram image to use as plotting background
load anomaloscopeData.mat 
if p.Results.pittDiagram
    pittDiagram = imread('/Users/deena/Dropbox (Aguirre-Brainard Lab)/MELA_materials/projectDichromat/pittDiagram.jpg');
end

%% Make/choose directory for saving plots
baseDir = '/Users/deena/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/projectDichromat/anomaloscope plots';

% Make folder for Pitt diagram/no Pitt diagram
if p.Results.pittDiagram
    directory = fullfile(baseDir, 'pittBackground');
else
    directory = fullfile(baseDir, 'noBackground');
end
if (~exist(directory, 'dir'))
    mkdir(directory);
end

%% Axis limits for plots. The anomaloscope uses a mixing light ratio from 0
%%  (green) to 73 (red) and a reference light intensity from 0 to 45.
xMin = 0;
xMax = 73;
yMin = 0;
yMax = 45;
xVals = xMin:xMax; %vector with range of possible x values

%% Deuteranopes

% Create figure and add image background if applicable
close all;
figure(1);
if p.Results.pittDiagram
    imagesc([xMin xMax], [yMin yMax], flipud(pittDiagram));
    hold on;
    set(gca, 'ydir', 'normal');
end

% Plot data
plot(MELA_3003_X, MELA_3003_Y, '.', MELA_3004_X, MELA_3004_Y, '.',...
    MELA_3009_X, MELA_3009_Y, '.', MELA_3011_X, MELA_3011_Y, '.',...
    MELA_3012_X, MELA_3012_Y, '.', MELA_3016_X, MELA_3016_Y, '.',...
    MELA_3019_X, MELA_3019_Y, '.', 'MarkerSize', 14);

% If not using image background, set axes and grid
if ~p.Results.pittDiagram
    axis([xMin xMax yMin yMax]);
    grid on;
end

title('Deuteranope Matches', 'FontSize', 16);
xlabel('Mixing Light', 'FontSize', 14);
ylabel('Reference Light', 'FontSize', 14);
legend('MELA\_3003', 'MELA\_3004', 'MELA\_3009', 'MELA\_3011',...
    'MELA\_3012', 'MELA\_3016', 'MELA\_3019');

% Save PDF
print('-bestfit', fullfile(directory, 'deuteranopes'), '-dpdf');
hold off;

%% Protanopes
% Create figure and add image background if applicable
figure(2);
if p.Results.pittDiagram
    imagesc([xMin xMax],[yMin yMax],flipud(pittDiagram));
    hold on;
    set(gca, 'ydir', 'normal');
end

% Plot data
plot(MELA_3006_X, MELA_3006_Y, '.', MELA_3007_X, MELA_3007_Y, '.', 'MarkerSize', 14);

% If not using image background, set axes and grid
if ~p.Results.pittDiagram
    axis([xMin xMax yMin yMax]);
    grid on;
end

title('Protanope Matches', 'FontSize', 16);
xlabel('Mixing Light', 'FontSize', 14);
ylabel('Reference Light', 'FontSize', 14);
legend('MELA\_3006', 'MELA\_3007');

% Save PDF
print('-bestfit', fullfile(directory, 'protanopes'), '-dpdf');
hold off;

%% Comparison
% Data
deuteranopesLong_X = MELA_3003_X;
deuteranopesLong_Y = MELA_3003_Y;
deuteranopesShort_X = [MELA_3004_X; MELA_3009_X; MELA_3011_X; MELA_3012_X; MELA_3016_X; MELA_3019_X];
deuteranopesShort_Y = [MELA_3004_Y; MELA_3009_Y; MELA_3011_Y; MELA_3012_Y; MELA_3016_Y; MELA_3019_Y];
protanopes_X = [MELA_3006_X; MELA_3007_X];
protanopes_Y = [MELA_3006_Y; MELA_3007_Y];

% Calculate lines of best fit for each subject group using least squares
% method. polyfit() returns a slope and intercept for each group
dLongFit = polyfit(deuteranopesLong_X, deuteranopesLong_Y, 1);
dShortFit = polyfit(deuteranopesShort_X, deuteranopesShort_Y, 1);
pFit = polyfit(protanopes_X, protanopes_Y, 1);

% Calculate y values of groups' fit lines from formula parameters
dLongFitY = (xVals * dLongFit(1)) + dLongFit(2);
dShortFitY = (xVals * dShortFit(1)) + dShortFit(2);
pFitY = (xVals * pFit(1)) + pFit(2);

% Create figure and add image background if applicable
figure(3);
if p.Results.pittDiagram
    imagesc([xMin xMax], [yMin yMax], flipud(pittDiagram));
    hold on;
    set(gca, 'ydir', 'normal');
else
    hold on;
end

% Plot data and best-fit lines
plot(deuteranopesLong_X, deuteranopesLong_Y, 'y.', deuteranopesShort_X,...
    deuteranopesShort_Y, 'b.', protanopes_X, protanopes_Y, 'c.', 'MarkerSize', 14);
plot(xVals, dLongFitY, 'y', xVals, dShortFitY, 'b', xVals, pFitY, 'c', 'LineWidth', 2.5);

% If not using image background, set axes and grid
if ~p.Results.pittDiagram
    axis([xMin xMax yMin yMax]);
    grid on;
end

title('Comparison of Deuteranope and Protanope Matches', 'FontSize', 16);
xlabel('Mixing Light', 'FontSize', 14);
ylabel('Reference Light', 'FontSize', 14);
legend('Deuteranopes Long', 'Deuteranopes Short', 'Protanopes');

% Save PDF
print('-bestfit', fullfile(directory, 'comparison'), '-dpdf');
hold off

%% Plot with lines of best fit for each subject
% Calculate lines of best fit for each subject using least squares method.
% polyfit() returns a slope and intercept for each subject
MELA_3003Fit = polyfit(MELA_3003_X, MELA_3003_Y, 1);
MELA_3004Fit = polyfit(MELA_3004_X, MELA_3004_Y, 1);
MELA_3006Fit = polyfit(MELA_3006_X, MELA_3006_Y, 1);
MELA_3007Fit = polyfit(MELA_3007_X, MELA_3007_Y, 1);
MELA_3009Fit = polyfit(MELA_3009_X, MELA_3009_Y, 1);
MELA_3011Fit = polyfit(MELA_3011_X, MELA_3011_Y, 1);
MELA_3012Fit = polyfit(MELA_3012_X, MELA_3012_Y, 1);
MELA_3016Fit = polyfit(MELA_3016_X, MELA_3016_Y, 1);
MELA_3019Fit = polyfit(MELA_3019_X, MELA_3019_Y, 1);

% Calculate y values of subjects' fit lines from formula parameters
MELA_3003FitY = (xVals * MELA_3003Fit(1)) + MELA_3003Fit(2);
MELA_3004FitY = (xVals * MELA_3004Fit(1)) + MELA_3004Fit(2);
MELA_3006FitY = (xVals * MELA_3006Fit(1)) + MELA_3006Fit(2);
MELA_3007FitY = (xVals * MELA_3007Fit(1)) + MELA_3007Fit(2);
MELA_3009FitY = (xVals * MELA_3009Fit(1)) + MELA_3009Fit(2);
MELA_3011FitY = (xVals * MELA_3011Fit(1)) + MELA_3011Fit(2);
MELA_3012FitY = (xVals * MELA_3012Fit(1)) + MELA_3012Fit(2);
MELA_3016FitY = (xVals * MELA_3016Fit(1)) + MELA_3016Fit(2);
MELA_3019FitY = (xVals * MELA_3019Fit(1)) + MELA_3019Fit(2);

% Create figure and add image background if applicable
figure(4);
if p.Results.pittDiagram
    imagesc([xMin xMax], [yMin yMax], flipud(pittDiagram));
    hold on;
    set(gca, 'ydir', 'normal');
end

% Set plot colors and plot data 
colors = [1 1 0; 1 0 1; 0 1 1; 0 0.4470 0.7410; 0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880;...
    0.3010 0.7450 0.9330];
set(gca, 'ColorOrder', colors);
plot(xVals, MELA_3003FitY, xVals, MELA_3004FitY, xVals,...
    MELA_3006FitY, xVals, MELA_3007FitY, xVals, MELA_3009FitY,...
    xVals, MELA_3011FitY, xVals, MELA_3012FitY, xVals, MELA_3016FitY,...
    xVals, MELA_3019FitY, 'LineWidth', 2.5);

% If not using image background, set axes and grid
if ~p.Results.pittDiagram
    axis([xMin xMax yMin yMax]);
    grid on;
end

title('Subject Lines of Best Fit', 'FontSize', 16);
xlabel('Mixing Light', 'FontSize', 14);
ylabel('Reference Light', 'FontSize', 14);
legend('MELA\_3003', 'MELA\_3004','MELA\_3006', 'MELA\_3007',...
    'MELA\_3009', 'MELA\_3011', 'MELA\_3012', 'MELA\_3016', 'MELA\_3019');

% Save PDF
print('-bestfit', fullfile(directory, 'subjectFits'), '-dpdf');
hold off;
end