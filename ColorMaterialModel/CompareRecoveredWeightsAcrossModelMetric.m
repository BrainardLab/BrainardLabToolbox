% CompareRecoveredWeightsAcrossModelsCubic

% Initialize
clear all; close all;

nSets = 10; % 9 sets are just demo data, one is abby's data - recovered paramters from cubic model (this is set 7).

for i = 1:nSets
    
    % For each model keep original positions and weights as well as the
    % recovered weights for each model. In the variable names 
    % we denote linear model with a, quadratic with b, cubic with c and
    % full with d. 
    
    load(['DemoData0.5W24Blocks1Linear' num2str(i) 'FitfullCityBlock.mat'])
    [aColor(:,i),aMaterial(:,i), aw(i), aSigma(i)]  = ColorMaterialModelXToParams(dataSet{1}.returnedParams, params); clear dataSet
    allADev(i,:) = [aColor(:,i)',aMaterial(:,i)', aw(i), aSigma(i)] - [params.materialMatchColorCoords, params.colorMatchMaterialCoords, params.w, params.sigma];
     weights1(i) = params.w;
    load(['DemoData0.5W24Blocks1Linear' num2str(i) 'FitFull.mat'])
    [bColor(:,i),bMaterial(:,i), bw(i), bSigma(i)] = ColorMaterialModelXToParams(dataSet{1}.returnedParams, params); clear dataSet
    allBDev(i,:) = [bColor(:,i)',bMaterial(:,i)', bw(i), bSigma(i)]- [params.materialMatchColorCoords, params.colorMatchMaterialCoords, params.w, params.sigma];
    
      % record Initial parameters;
    weights(i) = params.w;
    positionsC(i,:) = params.materialMatchColorCoords;
    positionsM(i,:) = params.colorMatchMaterialCoords;
    clear params;
    
end

% sort for plotting
[kk, temp]=sort(weights);
figure; hold on
plot(1:nSets, aw(temp), 'bo', 'MarkerSize', 10, 'MarkerEdgeColor', 'b');
plot(1:nSets, bw(temp), 'go', 'MarkerSize', 10, 'MarkerEdgeColor', 'g');
legend('cityblock', 'euclidean', 'Location', 'Best')
plot(1:nSets, weights(temp), 'kx', 'MarkerSize', 10, 'MarkerFaceColor', 'k')
axis([0 nSets+1, 0, 1])

% compare by computing deviation from the real weight...
%[H,P,CI,STATS] = ttest([(abs(aw-weights))], [(abs(cw-weights))]);
sumDev(1,:) = [mean((abs(aw-weights))), mean((abs(bw-weights)))]; 
sumDev(2,:) = [std((abs(aw-weights))), std((abs(bw-weights)))]; 

% plot positions for color and material
figure; hold on; axis square;
title('Positions: color')
for i = 1:nSets
    plot(positionsC(i,:), aColor(:,i), 'bo', 'MarkerSize', 10, 'MarkerEdgeColor', 'b', 'LineWidth', 2)
    plot(positionsC(i,:), bColor(:,i), 'go', 'MarkerSize', 10, 'MarkerEdgeColor', 'g', 'LineWidth', 2)
end
line([-20 20], [-20 20], 'Color', 'k')
legend('line', 'quad', 'cub', 'full', 'Location', 'Best')
axis([-20 20 -20 20])

figure; hold on; axis square;
title('Positions: material')
for i = 1:nSets
    plot(positionsM(i,:), aMaterial(:,i), 'bo', 'MarkerSize', 10, 'MarkerEdgeColor', 'b', 'LineWidth', 2);
    plot(positionsM(i,:), bMaterial(:,i), 'go', 'MarkerSize', 10, 'MarkerEdgeColor', 'g', 'LineWidth', 2);
 end

line([-20 20], [-20 20], 'Color', 'k')
legend('cityblock', 'euclid', 'Location', 'Best')
axis([-20 20 -20 20])

% Compute
for i = 1:nSets
    rmseA(i) = ComputeRealRMSE([aColor(:,i); aMaterial(:,i)], [positionsC(i,:), positionsC(i,:)]');
    rmseB(i) = ComputeRealRMSE([bColor(:,i); bMaterial(:,i)], [positionsC(i,:), positionsC(i,:)]');
   
end

sumDevPositions(1,:) = [mean(rmseA), mean(rmseB)];
sumDevPositions(2,:) = [std(rmseA), std(rmseB)];
