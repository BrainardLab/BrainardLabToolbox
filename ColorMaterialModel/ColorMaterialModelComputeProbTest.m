% ColorMaterialModelComputeProbTest
%
% Test that forward simulation and computation of probability match up
% nicely.

%% Clear
clear; close all;

%% Define target and sigma and w
targetC = 0;
targetM = 0;
sigma = 1;
w = 0.15;

%% Put y1 in a fixed place
cy1 = 20;
my1 = 0;

%% Vary y2 along material dimension
cy2 = 0;
nY2s = 10;

% Comment on this scaling. 
lowy2 = (w*cy1-3)/(1-w);
highy2 = (w*cy1+3)/(1-w);
my2s = linspace(lowy2,highy2,nY2s);

%% For each y2, get probability for simulated data and computed probabilities based on the assumed mapping function. 
nSimulate  = 1000;
simulatedPs = zeros(nY2s,1);
computedPs = zeros(nY2s,1);
for ii = 1:nY2s
    for jj = 1:nSimulate
        response(jj) = ColorMaterialModelSimulateResponse(targetC,targetM,cy1,cy2,my1,my2s(ii),sigma,w);
    end
    simulatedPs(ii) = sum(response)/nSimulate;
    computedPs(ii) = ColorMaterialModelComputeProb(targetC,targetM,cy1,cy2,my1,my2s(ii),sigma,w);
end

%% Scale for best fit
scaledComputedPs = (computedPs\simulatedPs)*computedPs;

%% Plot simulated vs. computed probabilities. 
figure; clf; hold on
plot(my2s,simulatedPs,'ro','MarkerSize',8,'MarkerFaceColor','r');
plot(my2s,computedPs,'r','LineWidth',2);
plot(my2s,scaledComputedPs,'g:','LineWidth',1);
xlabel('Y2 Material Coordinate')
ylabel('Prob Y1 Dist < Y2 Dist');
ylim([0 1]);
