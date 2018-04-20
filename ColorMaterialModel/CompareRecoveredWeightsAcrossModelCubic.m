% CompareRecoveredWeightsAcrossModelsCubic

% Initialize
clear all; close all;

nSets = 10; % 9 sets are just demo data, one is abby's data - recovered paramters from cubic model (this is set 7).

for i = 1:nSets
    
    % For each model keep original positions and weights as well as the
    % recovered weights for each model. In the variable names 
    % we denote linear model with a, quadratic with b, cubic with c and
    % full with d. 
    
    load(['DemoData0.5W24Blocks1Cubic' num2str(i) 'FitLin.mat'])
    [aColor(:,i),aMaterial(:,i), aw(i), aSigma(i)]  = ColorMaterialModelXToParams(dataSet{1}.returnedParams, params); clear dataSet
    allADev(i,:) = [aColor(:,i)',aMaterial(:,i)', aw(i), aSigma(i)] - [params.materialMatchColorCoords, params.colorMatchMaterialCoords, params.w, params.sigma];
    
    load(['DemoData0.5W24Blocks1Cubic' num2str(i) 'FitQuad.mat'])
    [bColor(:,i),bMaterial(:,i), bw(i), bSigma(i)] = ColorMaterialModelXToParams(dataSet{1}.returnedParams, params); clear dataSet
    allBDev(i,:) = [bColor(:,i)',bMaterial(:,i)', bw(i), bSigma(i)]- [params.materialMatchColorCoords, params.colorMatchMaterialCoords, params.w, params.sigma];
    
    load(['DemoData0.5W24Blocks1Cubic' num2str(i) 'FitCubic.mat'])
    [cColor(:,i),cMaterial(:,i), cw(i), cSigma(i)] = ColorMaterialModelXToParams(dataSet{1}.returnedParams, params); clear dataSet
    allCDev(i,:) = [cColor(:,i)',cMaterial(:,i)', cw(i), cSigma(i)]- [params.materialMatchColorCoords, params.colorMatchMaterialCoords, params.w, params.sigma];
    
    load(['DemoData0.5W24Blocks1Cubic' num2str(i) 'FitFull.mat'])
    [dColor(:,i),dMaterial(:,i), dw(i), dSigma(i)] = ColorMaterialModelXToParams(dataSet{1}.returnedParams, params); clear dataSet
    allDDev(i,:) = [dColor(:,i)',dMaterial(:,i)', dw(i), dSigma(i)]- - [params.materialMatchColorCoords, params.colorMatchMaterialCoords, params.w, params.sigma];
    
    % record Initial parameters;
    weights(i) = params.w;
    positionsC(i,:) = params.materialMatchColorCoords;
    positionsM(i,:) = params.colorMatchMaterialCoords;
    clear params;
    
end

% sort for plotting
[kk, temp]=sort(weights);
figure; hold on
plot(1:nSets, aw(temp), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
plot(1:nSets, bw(temp), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(1:nSets, cw(temp), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot(1:nSets, dw(temp), 'mo', 'MarkerSize', 10, 'MarkerFaceColor', 'm');
legend('line', 'quad', 'cub', 'full', 'Location', 'Best')
plot(1:nSets, weights(temp), 'kx', 'MarkerSize', 10, 'MarkerFaceColor', 'k')
axis([0 nSets+1, 0, 1])

% compare by computing deviation from the real weight...
[H,P,CI,STATS] = ttest([(abs(aw-weights))], [(abs(cw-weights))]);
sumDev(1,:) = [mean((abs(aw-weights))), mean((abs(bw-weights))), mean((abs(cw-weights))), mean((abs(dw-weights)))]; 
sumDev(2,:) = [std((abs(aw-weights))), std((abs(bw-weights))), std((abs(cw-weights))), std((abs(dw-weights)))]; 
sumDev(3,:) = [min((abs(aw-weights))), min((abs(bw-weights))), min((abs(cw-weights))), min((abs(dw-weights)))]; 
sumDev(4,:) = [max((abs(aw-weights))), max((abs(bw-weights))), max((abs(cw-weights))), max((abs(dw-weights)))]; 

% plot positions for color and material
figure; hold on; axis square;
title('Positions: color')
for i = 1:nSets
    plot(positionsC(i,:), aColor(:,i), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'LineWidth', 2)
    plot(positionsC(i,:), bColor(:,i), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'LineWidth', 2)
    plot(positionsC(i,:), cColor(:,i), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'LineWidth', 2)
    plot(positionsC(i,:), dColor(:,i), 'mo', 'MarkerSize', 10, 'MarkerFaceColor', 'm', 'LineWidth', 2)
end
line([-20 20], [-20 20], 'Color', 'k')
legend('line', 'quad', 'cub', 'full', 'Location', 'Best')
axis([-20 20 -20 20])

figure; hold on; axis square;
title('Positions: material')
for i = 1:nSets
    plot(positionsM(i,:), aMaterial(:,i), 'bo', 'MarkerSize', 10, 'MarkerEdgeColor', 'b', 'LineWidth', 2);
    plot(positionsM(i,:), bMaterial(:,i), 'go', 'MarkerSize', 10, 'MarkerEdgeColor', 'g', 'LineWidth', 2);
    plot(positionsM(i,:), cMaterial(:,i), 'ro', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 2);
  plot(positionsM(i,:), dMaterial(:,i), 'mo', 'MarkerSize', 10, 'MarkerEdgeColor', 'm', 'LineWidth', 2);
end

line([-20 20], [-20 20], 'Color', 'k')
legend('line', 'quad', 'cub', 'full', 'Location', 'Best')
axis([-20 20 -20 20])

% Compute
for i = 1:nSets
    rmseA(i) = ComputeRealRMSE([aColor(:,i); aMaterial(:,i)], [positionsC(i,:), positionsC(i,:)]');
    rmseB(i) = ComputeRealRMSE([bColor(:,i); bMaterial(:,i)], [positionsC(i,:), positionsC(i,:)]');
    rmseC(i) = ComputeRealRMSE([cColor(:,i); cMaterial(:,i)], [positionsC(i,:), positionsC(i,:)]');
    rmseD(i) = ComputeRealRMSE([dColor(:,i); dMaterial(:,i)], [positionsC(i,:), positionsC(i,:)]');
end

sumDevPositions(1,:) = [mean(rmseA), mean(rmseB), mean(rmseC), mean(rmseD)];
sumDevPositions(2,:) = [std(rmseA), std(rmseB), std(rmseC), std(rmseD)];
sumDevPositions(3,:) = [min(rmseA), min(rmseB), min(rmseC), min(rmseD)];
sumDevPositions(4,:) = [max(rmseA), max(rmseB), max(rmseC), max(rmseD)];