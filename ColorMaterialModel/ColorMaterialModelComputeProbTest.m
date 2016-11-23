% ColorMaterialModelComputeProbTest
%
% Test that forward simulation and computation of probability match up
% nicely.

%% Clear
clear; close all;

%% Define target and sigma and w
targetColorCoord = 0;
targetMaterialCoord = 0;
sigma = 1;
w = 0.5;

%% Put y1 in a fixed place
colorMatchColorCoord = 0;
colorMatchMaterialCoord = 20;

%% Vary y2 along material dimension
materialMatchMaterialCoord = 0;
nMaterialMatches = 10;

% Comment on this scaling. 
lowy2 = (w*colorMatchMaterialCoord-3)/(1-w);
highy2 = (w*colorMatchMaterialCoord+3)/(1-w);
materialMatchColorCoords = linspace(lowy2,highy2,nMaterialMatches);

%% For each y2, get probability for simulated data and computed probabilities based on the assumed mapping function. 
nSimulate  = 1000;
simulatedPs = zeros(nMaterialMatches,1);
computedPs = zeros(nMaterialMatches,1);
for ii = 1:nMaterialMatches
    for jj = 1:nSimulate
        response(jj) = ColorMaterialModelSimulateResponse(targetColorCoord,targetMaterialCoord, colorMatchColorCoord,materialMatchColorCoords(ii), colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma);
    end
    simulatedPs(ii) = sum(response)/nSimulate;
    computedPs(ii) = ColorMaterialModelComputeProb(targetColorCoord,targetMaterialCoord, colorMatchColorCoord,materialMatchColorCoords(ii), colorMatchMaterialCoord, materialMatchMaterialCoord, w, sigma);
end

%% Scale for best fit
scaledComputedPs = (computedPs\simulatedPs)*computedPs;

%% Plot simulated vs. computed probabilities. 
figure; clf; hold on
plot(materialMatchColorCoords,simulatedPs,'ro','MarkerSize',8,'MarkerFaceColor','r');
plot(materialMatchColorCoords,computedPs,'r','LineWidth',2);
plot(materialMatchColorCoords,scaledComputedPs,'g:','LineWidth',1);
xlabel('Y2 Material Coordinate')
ylabel('Prob Y1 Dist < Y2 Dist');
ylim([0 1]);
