% ColorMaterialModelFitDemoData.m
%
% Demonstrates color material MLDS model fitting procedure for a data set.
% Initially used as a test bed for testing and improving search algorithm.
% Later on, the code that generates demo data has been pulled into separate
% code. 
% 
% 05/03/17 ar Cleaned up, added comments. 

%% Initialize and set directories and some plotting params.
clear; close all;
currentDir = pwd;
dataDir = ['/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData'];
saveFig = 0;
weibullplots = 0;

%% Load a data set. 
nBlocks = 56; 
w = 0.75; 
fileName = ['DemoData' num2str(w) 'W' num2str(nBlocks) 'Blocks10Sets.mat']; 
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
params.smoothOrder = 3; % this option is only for smoothSpacing

% Does material/color weight vary in fit?
%  'weightVary' - yes, it does.
%  'weightFixed' - fix weight to specified value in tryWeightValues(1);
params.whichWeight = 'weightVary';

% Initial position spacing values to try.
params.trySpacingValues = [0.5 1 2];
params.maxPositionValue = 20;
params.tryWeightValues = [0.5 0.2 0.8];
params.addNoise = true;

% Loop over n dataSets and extract the solution
for whichSet = 1:length(dataSet)
    
    dataSet{whichSet}.nTrials = nBlocks*ones(size(dataSet{whichSet}.responsesFromSimulatedData));
    [dataSet{whichSet}.initialLogLikely, dataSet{whichSet}.predictedResponses] = ColorMaterialModelComputeLogLikelihood(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
        pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
        dataSet{whichSet}.responsesFromSimulatedData, dataSet{whichSet}.nTrials,...
        params.materialMatchColorCoords(params.targetIndex), params.colorMatchMaterialCoords(params.targetIndex), ...
        params.w,params.sigma,'Fobj', params.F, 'whichMethod', 'lookup');
    fprintf('True position log likelihood %0.2f.\n', dataSet{whichSet}.logLikely);
    clear logLikely predictedResponses
    
    %% Fit the data and extract parameters and other useful things from the solution
    [dataSet{whichSet}.returnedParams, dataSet{whichSet}.logLikelyFit, ...
        dataSet{whichSet}.predictedProbabilitiesBasedOnSolution, ~] = FitColorMaterialModelMLDS(...
        pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
        pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
        dataSet{whichSet}.responsesFromSimulatedData,dataSet{whichSet}.nTrials,params, ...
        'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
        'tryWeightValues',params.tryWeightValues,'trySpacingValues',params.trySpacingValues, 'maxPositionValue', params.maxPositionValue); %#ok<SAGROW>
    fprintf('Returned weight: %0.2f.\n', dataSet{whichSet}.returnedParams(end-1));
    fprintf('Log likelyhood of the solution: %0.2f.\n', dataSet{whichSet}.logLikelyFit);
    
    % Plot the solution
    % Reformat probabilities to look only at color/material tradeoff
    % Indices that reformating is based on are saved in the data matrix
    % that we loaded. 
    for i = 1:length(rowIndex)
        dataSet{whichSet}.resizedDataProb(rowIndex((i)), columnIndex((i))) = dataSet{whichSet}.probabilitiesFromSimulatedData(overallColorMaterialPairIndices(i));
        dataSet{whichSet}.resizedSolutionProb(rowIndex((i)), columnIndex((i))) = dataSet{whichSet}.predictedProbabilitiesBasedOnSolution(overallColorMaterialPairIndices(i));
        dataSet{whichSet}.resizedProbabilitiesForActualPositions(rowIndex((i)), columnIndex((i))) = dataSet{whichSet}.probabilitiesForActualPositions(overallColorMaterialPairIndices(i));
    end
    % compute RMSEs
    dataSet{whichSet}.rmse = ComputeRealRMSE(dataSet{whichSet}.probabilitiesFromSimulatedData(:), dataSet{whichSet}.predictedProbabilitiesBasedOnSolution(:));
end
switch params.whichWeight
    case 'weightFixed'
        save([fileName 'FitFixed'])
    case 'weightVary'
        save([fileName num2str(nBlocks) 'FitVary'])
end