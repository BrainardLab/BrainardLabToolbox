% AnalyzeDemoSpacings.m
% This script analyzes the recovered of parameters (weights, positions) from the set of simulated data with different spacings.  

% 07/11/2017 ar Wrote it. 

% Initalize
clear; close all; 

% Set some parameters; 
differentSpacings = [1 1.5 2 2.5 3]; % different spacings we have simulated. 
colors = {'r', 'g', 'b', 'm', 'k'}; % use different colors to plot them (each color corresponds to one spacing)
whichSimulatedWeight = 0.2; 
nBlocks = 24; 
nDataSets = 15; 
weibullplots = 0; 
saveFig = 0; 
figDir = pwd; 
conditionCode = 'demo'; 
subjectName = 'demo'; 
% We ran the 'recovery' with two different models. 
% In both of them the weigth was allowed to vary freely (naturally).   
whichModel = GetWithDefault('Which model to use? [1]Full  [2]SmoothSpacing?', 1);
modelFolder = {'DiffSpacingsFullModel', 'DiffSpacingsLinSSModel'}; 

% We will plot the results in one figure with two subplots, each returning
% the positions on 1) color and 2) material dimension.
figure; clf;
for i = 1:length(differentSpacings)
    
    
    % (1) subplot for color
    subplot(1,2,1); hold on;
    title('COLOR')
    for j = 1:length(k{i}.dataSet)
        [~,materialMatchColorCoords,whichWeight(i,j),~] = ColorMaterialModelXToParams(k{i}.dataSet{j}.returnedParams,k{i}.params);
        plot(k{i}.params.materialMatchColorCoords, materialMatchColorCoords, 'o', 'MarkerFaceColor', colors{i}, 'MarkerEdgeColor', colors{i});
    end
    
    % (2) subplot for material
    subplot(1,2,2); hold on;
    title('MATERIAL')
    for j = 1:length(k{i}.dataSet)
        [colorMatchMaterialCoords,~,~,~] = ColorMaterialModelXToParams(k{i}.dataSet{j}.returnedParams,k{i}.params);
        plot(k{i}.params.colorMatchMaterialCoords, colorMatchMaterialCoords, 'o', 'MarkerFaceColor', colors{i}, 'MarkerEdgeColor', colors{i});
    end
end


%      ColorMaterialModelPlotSolution(probabilitiesFromSimulatedData,predictedProbabilitiesBasedOnSolution, ...
%             resizedDataProb, resizedSolutionProb, ...
%             returnedParams, params, params.subjectName, params.conditionCode, figDir, ...
%             saveFig, weibullplots,colIndex, matIndex, probabilitiesForActualPositions, resizedProbabilitiesForActualPositions);

% plot each results for each particular set.
for i = 4%1:length(differentSpacings)
    k{i} = load(['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots/' modelFolder{whichModel} ...
        '/DemoData' num2str(whichSimulatedWeight) 'W' num2str(nBlocks) 'Blocks' num2str(nDataSets) 'Spacing' ...
        num2str(differentSpacings(i)) 'LinFitVary.mat']);
   
    for j = 1%:length(k{i}.dataSet)
        ColorMaterialModelPlotSolution(k{i}.dataSet{j}.probabilitiesFromSimulatedData,...
            k{i}.dataSet{j}.predictedResponses,...
            k{i}.dataSet{j}.resizedProbabilitiesForActualPositions, ...
            k{i}.dataSet{j}.returnedParams, k{i}.params, subjectName, conditionCode, figDir, saveFig, weibullplots)
    end
end
