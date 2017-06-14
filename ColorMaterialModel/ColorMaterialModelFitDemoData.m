% ColorMaterialModelFitDemoData.m
%
% Demonstrates color material MLDS model fitting procedure for a simulated
% data set (generated using ColorMaterialModelGenerateDemoData.m). 
% Initially used as a test bed for testing and improving search algorithm.
% Pulled out form the old code in which data generation and data fitting were together.  
% 
% 05/03/17 ar Cleaned up, added comments. 
% 06/15/17 ar More cleaning up and commenting. 

%% Initialize and set directories and some plotting params.
clear; close all;
currentDir = pwd;

%% Set relevant preferences and directories. 
%setpref('ColorMaterialModel','demoDataDir','/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/');
setpref('ColorMaterialModel','demoDataDir','/Users/dhb/Documents/Matlab/toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/');
dataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots'; 

saveFig = 0;
weibullplots = 0;

%% Load a data set (given the params)
howManyBlocks = 24; 
whichW = 0.5; 
howManyDataSets = 1; 
fileName = ['DemoData' num2str(whichW) 'W' num2str(howManyBlocks) 'Blocks' num2str(howManyDataSets) 'New.mat']; 
cd([dataDir '/'])
load(fileName); 

%% Set model parameters 
params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
params.nSimulate = 1000; % for method 'simulate'
params.whichDistance = 'euclidean';

% What sort of position fitting are we doing, and if smooth the order of the polynomial.
% Options:
%  'full' - Weights vary
%  'smoothSpacing' - Weights computed according to a polynomial fit.
params.whichPositions = 'full';
params.smoothOrder = 1; % this option is only for smoothSpacing

% Does material/color weight vary in fit?
%  'weightVary' - yes, it does.
%  'weightFixed' - fix weight to specified value in tryWeightValues(1);
params.whichWeight = 'weightVary';

% Initial position spacing values to try.
params.trySpacingValues = [0.5 1 2];
params.tryWeightValues = [0.2 0.5 0.8];
% addNoise parameter is already a part of the generated data sets. 
% We should not set it again here. 
% params.addNoise = true; 
params.maxPositionValue = max(params.F.GridVectors{1});

% Loop over all the data sets and extract the solution
for whichSet = 1:length(dataSet)
    % Compute initial log-likelihood.
    dataSet{whichSet}.nTrials = nBlocks*ones(size(dataSet{whichSet}.responsesFromSimulatedData));
    [dataSet{whichSet}.initialLogLikely, dataSet{whichSet}.predictedResponses] = ...
        ColorMaterialModelComputeLogLikelihood(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
        pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
        dataSet{whichSet}.responsesFromSimulatedData, dataSet{whichSet}.nTrials,...
        params.materialMatchColorCoords(params.targetIndex), params.colorMatchMaterialCoords(params.targetIndex), ...
        params.w,params.sigma,'Fobj', params.F, 'whichMethod', 'lookup');
    
    % Fit the data and extract parameters and other useful things from the solution
    [dataSet{whichSet}.returnedParams, dataSet{whichSet}.logLikelyFit, ...
        dataSet{whichSet}.predictedProbabilitiesBasedOnSolution] = FitColorMaterialModelMLDS(...
        pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
        pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
        dataSet{whichSet}.responsesFromSimulatedData,dataSet{whichSet}.nTrials,params, ...
        'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
        'tryWeightValues',params.tryWeightValues,'tryColorSpacingValues',params.trySpacingValues,...
        'tryMaterialSpacingValues',params.trySpacingValues,'maxPositionValue', params.maxPositionValue); %#ok<SAGROW>
    
    % Print some diagnostics
    fprintf('True position log likelihood %0.2f.\n', dataSet{whichSet}.initialLogLikely);
    fprintf('Returned weight: %0.2f.\n', dataSet{whichSet}.returnedParams(end-1));
    fprintf('Log likelyhood of the solution: %0.2f.\n', dataSet{whichSet}.logLikelyFit);
    
    % Plot the solution
    % Reformat probabilities to look only at color/material tradeoff
    % Indices that reformating is based on are saved in the data matrix
    % that we loaded. 
    for i = 1:length(overallColorMaterialPairIndices)
        dataSet{whichSet}.resizedDataProb(rowIndex((i)), columnIndex((i))) = ...
            dataSet{whichSet}.probabilitiesFromSimulatedData(overallColorMaterialPairIndices(i));
        dataSet{whichSet}.resizedSolutionProb(rowIndex((i)), columnIndex((i))) = ...
            dataSet{whichSet}.predictedProbabilitiesBasedOnSolution(overallColorMaterialPairIndices(i));
        dataSet{whichSet}.resizedProbabilitiesForActualPositions(rowIndex((i)), columnIndex((i))) = ...
            dataSet{whichSet}.probabilitiesForActualPositions(overallColorMaterialPairIndices(i));
    end
    
    % compute RMSEs
    dataSet{whichSet}.rmse = ComputeRealRMSE(dataSet{whichSet}.probabilitiesFromSimulatedData(:),...
        dataSet{whichSet}.predictedProbabilitiesBasedOnSolution(:));
end
save([fileName num2str(nBlocks) params.whichWeight 'Fit'])