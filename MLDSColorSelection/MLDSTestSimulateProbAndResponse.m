% MLDSTestSimulateProbAndResponse
%
% Simple basic test.  Make sure taht MLDSComputeProb and
% MLDSSimulateResponse are consistent with one another.
%
% Looks good.
%
% 4/30/15  dhb  Wrote it in a fit of paranoia.

%% Clear
clear; close all;

%% Set parameters
sigma = 0.1;
x = 0;
y1 = -0.2;

nY2s = 100;
y2s = linspace(-6*sigma,6*sigma,nY2s);
nSimulatePerY2 = 4000;

%% Loop over values that have a range of predicted probabilities
%
% Compute analytic and by simulation and save 'em up for plotting below.
for i = 1:nY2s
    y2 = y2s(i);
    
    computedProbs(i) = MLDSComputeProb(x,y1,y2,sigma,@MLDSIdentityMap);
    
    simulateYes = 0;
    for k = 1:nSimulatePerY2
        simulateYes = simulateYes + MLDSSimulateResponse(x,y1,y2,sigma,@MLDSIdentityMap);
    end
    simulatedProbs(i) = simulateYes/nSimulatePerY2;
end

%% Plot
figure; clf; hold on
plot(computedProbs,simulatedProbs,'ro','MarkerFaceColor','r');
plot([0 1],[0 1],'k');
axis([0 1 0 1]);
axis('square');

