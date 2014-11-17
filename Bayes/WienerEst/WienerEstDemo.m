% WienerEstDemo
%
% This script shows the use of the Wiener estimator code in this directory.
%
% It also demonstrates that the estimator does what it is supposed to,
% relative to using regression.  Given simulated data, we can actually
% compute how well various estimators predict both the observed data
% (for this regression will do best) and the underlying true data
% (here the Wiener estimator will do best).  
%
% 4/21/13  dhb  Wrote it.

%% Clear
clear; close all;

%% Run this in the directory where it exists
cd(fileparts(mfilename('fullpath')));

%% Basic parameters of the simulations
nDataPoints = 100;
nBeta = 5;
nTrials = 100;

%% Generate predictors in columns of matrix B.
% We want these to be linearly dependent, but not orthogonal,
% to allow comparison of Wiener and straight regression in terms of the answer.
%
% I'm not sure of the best generate interesting non-orthogonal
% predictors, but here is one way that seems to work
%   Generate a big matrix using hadamard
%   Pull out the nDataPoints by nBeta submatrix
%   Recombine these in a manner to produce linear dependence
%
% The computation of cosTheta at the end lets you check that
% columns 1 and 2 of B are not orthogonal.  It could be 
% generalized to check all the numbers.
temp = hadamard(2^ceil(log2(nDataPoints)));
temp = temp(1:nDataPoints,1:nBeta);
recomb = zeros(nBeta,nBeta);
for j = 1:nBeta
    for i = 1:nBeta-1
        k = rem(i+j,nBeta) + 1;
        recomb(k,j) = 1;
    end
end
B = temp*recomb;
cosTheta12 = B(:,1)'*B(:,2)/(norm(B(:,1))*norm(B(:,2)));
fprintf('Angle between columns 1 and 2 of B is %0.1f deg\n',rad2deg(acos(cosTheta12)));

%% Specify prior on weights for predictors.
% We'll make them independent with decreasing
% variance.
uBeta = zeros(nBeta,1);
KBeta = eye(nBeta);
for i = 1:nBeta
    KBeta(i,i) = 1/i;
end

%% Specify measurement matrix R.
%
% We'll  assume one measurement per time point,
% but with some time blur between samples, so
% that there is correlation structure in the
% measurements independent of the actual structure
% of the underlying data.
%
% I'm not sure of the generality of the code that
% blurs the measurement matrix -- it relies on how
% conv truncated the results of the convolution
% and I derived that empircally for the case I typed
% in.
%
% You can get rid of this by making MEASUREBLUR = false.
% Note that in this case, the regression and regression 2
% methods below are identical.
MEASUREBLUR = true;
if (MEASUREBLUR)
    R = eye(nDataPoints+1);
    HRF = [1 0.5 0.3 0.2];
    for i = 1:nDataPoints+1
        R(i,:) = conv(R(i,:),HRF(end:-1:1),'same');
    end
    R = R(1:end-1,2:end);
else
    R = eye(nDataPoints);
end

%% Generate some simulated data
trueBeta = MultiNormalDraw(nTrials,uBeta,KBeta);
trueTimeSeries = B*trueBeta;

%% Specify additive measurement noise.
% We'll assume this is iid with zero mean
% and standard deviation noiseSd.
%
% It's useful to scale the noiseSd to the scale of the time
% series data, just so we have some intuition
% about how big the noise is.
noiseSd = 0.10*max(abs(trueTimeSeries(:)));
uNoise = zeros(nDataPoints,1);
KNoise = (noiseSd^2) * eye(nDataPoints);

%% Make the estimator
%
% This depends on the measurement matrix R, the predictor matrix B,
% the prior on the beta values and the noise parameters.
[I,i,RB,W,b] = MakeWienerEst(R,B,[],uBeta,KBeta,uNoise,KNoise);

%% Generate observed data by adding noise.
observedTimeSeries = R*trueTimeSeries + MultiNormalDraw(nTrials,uNoise,KNoise);

%% Estimate using Wiener.
% 
% Note that I = B*w and i = B*b (as returned by MakeWienerEst)
% and we short circuit that here rather than using returned I and i.
wienerEstBeta = W*observedTimeSeries + b*ones(1,nTrials);
wienerEstTimeSeries = B*wienerEstBeta;

%% Estimate using regression (two different ways)

% The first version of regression takes the measurement
% matrix in account, essentially deconvolving by this
% matrix but without any fanciness with respect to the
% noise structure relative to how well each predictor
% can be seen in the data.  
regressionEstBeta = (RB)\observedTimeSeries;
regressionEstTimeSeries = B*regressionEstBeta;

% This second version estimates the beta weights by
% straight regression of the predictors against 
% the observed time series data.  It ignores the
% measurement matrix completely, but is guaranteed
% to find the beta values that lead to the minimum
% MSE of the observed data.
regression2EstBeta = B\observedTimeSeries;
regression2EstTimeSeries = B*regression2EstBeta;

%% Compute mean sum of squared errors (MSE).
%
% What should be the case is that the Wiener estimator always
% has lowest error to the true beta values and to the true time series,
% while the regression2 method should have the lowest MSE to the observed time series.
wienerEstBetaMSE = sum((trueBeta(:) - wienerEstBeta(:)).^2)/length(trueBeta(:));
wienerEstTimeSeriesMSE = sum((trueTimeSeries(:) - wienerEstTimeSeries(:)).^2)/length(trueTimeSeries(:));
wienerEstObservedMSE = sum((observedTimeSeries(:) - wienerEstTimeSeries(:)).^2)/length(observedTimeSeries(:));
regressionEstBetaMSE = sum((trueBeta(:) - regressionEstBeta(:)).^2)/length(trueBeta(:));
regressionEstTimeSeriesMSE = sum((trueTimeSeries(:) - regressionEstTimeSeries(:)).^2)/length(trueTimeSeries(:));
regressionEstObservedMSE = sum((observedTimeSeries(:) - regressionEstTimeSeries(:)).^2)/length(observedTimeSeries(:));
regression2EstBetaMSE = sum((trueBeta(:) - regression2EstBeta(:)).^2)/length(trueBeta(:));
regression2EstTimeSeriesMSE = sum((trueTimeSeries(:) - regression2EstTimeSeries(:)).^2)/length(trueTimeSeries(:));
regression2EstObservedMSE = sum((observedTimeSeries(:) - regression2EstTimeSeries(:)).^2)/length(observedTimeSeries(:));

fprintf('Beta estimation MSE\n');
fprintf('\tWiener:       %0.4f\n',wienerEstBetaMSE);
fprintf('\tRegression:   %0.4f\n',regressionEstBetaMSE);
fprintf('\tRegression 2: %0.4f\n',regression2EstBetaMSE);

fprintf('True time series estimation MSE\n');
fprintf('\tWiener:       %0.4f\n',wienerEstTimeSeriesMSE);
fprintf('\tRegression:   %0.4f\n',regressionEstTimeSeriesMSE);
fprintf('\tRegression 2: %0.4f\n',regression2EstTimeSeriesMSE);

fprintf('Observed time series estimation MSE\n');
fprintf('\tWiener:       %0.4f\n',wienerEstObservedMSE);
fprintf('\tRegression:   %0.4f\n',regressionEstObservedMSE);
fprintf('\tRegression 2: %0.4f\n',regression2EstObservedMSE);

%% Plot what happened for beta estimation with Wiener and 
% regression method.
fig1 = figure; clf;
set(gcf,'Position',[1000         796         1200         600]);
minBetaVal = min([trueBeta(:) ; wienerEstBeta(:) ; regressionEstBeta(:) ; regression2EstBeta(:)]);
maxBetaVal = max([trueBeta(:) ; wienerEstBeta(:) ; regressionEstBeta(:) ; regression2EstBeta(:)]);
for i = 1:nTrials
    figure(fig1);
    subplot(1,3,1); hold on;
    plot(trueBeta(:,i),wienerEstBeta(:,i),'ro','MarkerSize',10);

    subplot(1,3,2); hold on;
    plot(trueBeta(:,i),regressionEstBeta(:,i),'ro','MarkerSize',10);
   
    subplot(1,3,3); hold on;
    plot(trueBeta(:,i),regression2EstBeta(:,i),'ro','MarkerSize',10);
end

% Tidy up the plots
figure(fig1);
subplot(1,3,1); hold on;
plot([minBetaVal maxBetaVal],[minBetaVal maxBetaVal],'k');
xlim([minBetaVal maxBetaVal]);
ylim([minBetaVal maxBetaVal]);
xlabel('Simulated Time'); ylabel('Underlying Time Data');
title(sprintf('Wiener Estimation: MSE = %0.4f',wienerEstBetaMSE));
axis('square');

subplot(1,3,2); hold on;
plot([minBetaVal maxBetaVal],[minBetaVal maxBetaVal],'k');
xlim([minBetaVal maxBetaVal]);
ylim([minBetaVal maxBetaVal]);
xlabel('Simulated Time'); ylabel('Underlying Time Data');
title(sprintf('Regression Estimation: MSE = %0.4f',regressionEstBetaMSE));
axis('square');

subplot(1,3,3); hold on;
plot([minBetaVal maxBetaVal],[minBetaVal maxBetaVal],'k');
xlim([minBetaVal maxBetaVal]);
ylim([minBetaVal maxBetaVal]);
xlabel('Simulated Time'); ylabel('Underlying Time Data');
title(sprintf('Regression 2 Estimation: MSE = %0.4f',regression2EstBetaMSE));
axis('square');

%% Plot what happened for true time series estimation 
%
% Here just sample one trial to keep plot from being too cluttered
fig2 = figure; clf;
set(gcf,'Position',[422   538   986   712]);
whichToPlot = 1;
subplot(3,1,1); hold on;
plot(1:nDataPoints,trueTimeSeries(:,whichToPlot),'k');
plot(1:nDataPoints,wienerEstTimeSeries(:,whichToPlot),'r');
xlabel('Time'); ylabel('Underlying Time Series Value');
title(sprintf('Wiener, MSE = %0.4f',wienerEstTimeSeriesMSE));

subplot(3,1,2); hold on;
plot(1:nDataPoints,trueTimeSeries(:,whichToPlot),'k');
plot(1:nDataPoints,regressionEstTimeSeries(:,whichToPlot),'r');
xlabel('Time'); ylabel('Underlying Time Series Value');
title(sprintf('Regression, , MSE = %0.4f',regressionEstTimeSeriesMSE));

subplot(3,1,3); hold on;
plot(1:nDataPoints,trueTimeSeries(:,whichToPlot),'k');
plot(1:nDataPoints,regression2EstTimeSeries(:,whichToPlot),'r');
xlabel('Time'); ylabel('Underlying Time Series Value');
title(sprintf('Regression 2, MSE = %0.4f',regression2EstTimeSeriesMSE));

suptitle('Fit To True Time Series');

%% Plot what happened for observed time series estimation for Wiener and
% regression 2 methods
%
% Here just sample one trial to keep plot from being too cluttered
fig3 = figure; clf;
set(gcf,'Position',[422   538   986   712]);
whichToPlot = 1;
subplot(3,1,1); hold on;
plot(1:nDataPoints,observedTimeSeries(:,whichToPlot),'k');
plot(1:nDataPoints,wienerEstTimeSeries(:,whichToPlot),'r');
xlabel('Time'); ylabel('Observed Time Series Value');
title(sprintf('Wiener, MSE = %0.4f',wienerEstObservedMSE));

subplot(3,1,2); hold on;
plot(1:nDataPoints,observedTimeSeries(:,whichToPlot),'k');
plot(1:nDataPoints,regressionEstTimeSeries(:,whichToPlot),'r');
xlabel('Time'); ylabel('Observed Time Series Value');
title(sprintf('Regression, , MSE = %0.4f',regressionEstObservedMSE));

subplot(3,1,3); hold on;
plot(1:nDataPoints,observedTimeSeries(:,whichToPlot),'k');
plot(1:nDataPoints,regression2EstTimeSeries(:,whichToPlot),'r');
xlabel('Time'); ylabel('Observed Time Series Value');
title(sprintf('Regression 2, MSE = %0.4f',regression2EstObservedMSE));

suptitle('Fit To Observed Time Series');
