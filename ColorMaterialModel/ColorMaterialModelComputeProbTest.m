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
w = 0.5;

%% Put y1 in a fixed place
cy1 = 4;
my1 = 0;

%% Vary y2 along material
nY2s = 10;
lowy2 = 1;
highy2 = 7;
cy2 = 0;
my2s = linspace(lowy2,highy2,nY2s);

%% For each y2, get probability both ways
nSimulate  = 1000;
simulatedPs = zeros(nY2s,1);
computedPs = zeros(nY2s,1);
for ii = 1:nY2s
    for jj = 1:nSimulate
        response(jj) = ColorMaterialModelSimulateResponse(targetC,targetM,cy1,cy2,my1,my2s(ii),sigma,w);
    end
    simulatedPs(ii) = sum(response)/nSimulate;
    
    computedPs(ii) = ColorMaterialComputeProb(targetC,targetM,cy1,cy2,my1,my2s(ii),sigma,w);
end

%% Plot
figure; clf; hold on
plot(simulatedPs,computedPs,'ro','MarkerSize',8,'MarkerFaceColor','r');

%% Another plot
figure; clf; hold on
plot(my2s,simulatedPs,'ro','MarkerSize',8,'MarkerFaceColor','r');
plot(my2s,computedPs,'r','LineWidth',2);



