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

%% Set relevant preferences and directories. 
%setpref('ColorMaterialModel','demoDataDir','/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/');
setpref('ColorMaterialModel','demoDataDir','/Users/dhb/Documents/Matlab/toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/');

% Main demo for the toolbox and larger audience. 
% If this is set to false, then the data is saved on dropbox and analyzed
% separately (as a part of the main model/experimental analysis. 
MAINDEMO = true; 
if MAINDEMO
    dataDir = '/Users/ana/Documents/MATLAB/toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/';
else
    dataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/DemoData/';
end
figDir = dataDir;

%% Load a data set (given the params)
nBlocks = 24; 
simulatedW = 0.5; 
nDataSets = 1; 
fileName = ['DemoData' num2str(simulatedW) 'W' num2str(nBlocks) 'Blocks' num2str(nDataSets) '.mat']; 
cd(dataDir)
load(fileName); 

% Plot the solution? Save the plots? Include Weibull plots?
plotSolution = 1;
saveFig = 0; 
weibullplots = 0; 
params.subjectName = fileName(1:end-4); 

%% Set model parameters 
% Specify which method to use for looking up probabilities. 
params.whichMethod = 'lookup'; % options: 'lookup', 'simulate' or 'analytic'
params.whichDistance = 'euclidean'; % options: euclidean, cityblock (or any metric enabled by pdist function). 

% For simulate method, set up how many simulations to use for predicting probabilities.  
if strcmp(params.whichMethod, 'simulate')
    params.nSimulate = 1000;
end

% What sort of position fitting are we doing, and if smooth the order of the polynomial.
% Options:
%  'full' - Weights vary
%  'smoothSpacing' - Weights computed according to a polynomial fit.
params.whichPositions = 'full';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 1; % this option is only for smoothSpacing
end

% Does material/color weight vary in fit?
% Options: 
%  'weightVary' - yes, it does.
%  'weightFixed' - fix weight to specified value in tryWeightValues(1);
params.whichWeight = 'weightVary';

% Initial position spacing values to try.
params.tryColorSpacingValues = [0.5 1 2];
params.tryMaterialSpacingValues = [0.5 1 2];
params.tryWeightValues = [0.2 0.5 0.8];

% addNoise parameter is already a part of the generated data sets. 
% We should not set it again here. Commenting it out. 
% params.addNoise = true; 
params.maxPositionValue = max(params.F.GridVectors{1});

% Loop over all the data sets and extract the solution
for whichSet = 1:length(dataSet)
    
    % Compute initial log-likelihood.
    dataSet{whichSet}.nTrials = nBlocks*ones(size(dataSet{whichSet}.responsesFromSimulatedData));
    [dataSet{whichSet}.initialLogLikely, dataSet{whichSet}.predictedResponses] = ...
        ColorMaterialModelComputeLogLikelihood(pairInfo.pairColorMatchColorCoords, pairInfo.pairMaterialMatchColorCoords,...
        pairInfo.pairColorMatchMaterialCoords, pairInfo.pairMaterialMatchMaterialCoords,...
        dataSet{whichSet}.responsesFromSimulatedData, dataSet{whichSet}.nTrials,...
        params.materialMatchColorCoords(params.targetIndex), params.colorMatchMaterialCoords(params.targetIndex), ...
        params.w, params.sigma, 'whichMethod', params.whichMethod, 'Fobj', params.F);
    
    % Fit the data and extract parameters and other useful things from the solution
    [dataSet{whichSet}.returnedParams, dataSet{whichSet}.logLikelyFit, ...
        dataSet{whichSet}.predictedProbabilitiesBasedOnSolution] = FitColorMaterialModelMLDS(...
        pairInfo.pairColorMatchColorCoords, pairInfo.pairMaterialMatchColorCoords,...
        pairInfo.pairColorMatchMaterialCoords, pairInfo.pairMaterialMatchMaterialCoords,...
        dataSet{whichSet}.responsesFromSimulatedData,dataSet{whichSet}.nTrials,params); %#ok<SAGROW>
    
    % Print some diagnostics
    fprintf('True position log likelihood %0.2f.\n', dataSet{whichSet}.initialLogLikely);
    fprintf('Returned weight: %0.2f.\n', dataSet{whichSet}.returnedParams(end-1));
    fprintf('Log likelyhood of the solution: %0.2f.\n', dataSet{whichSet}.logLikelyFit);
    
    % Compute RMSE (root mean square error) for the current solution        
    % (to get some sense of how we're doing)
    dataSet{whichSet}.rmse = ComputeRealRMSE(dataSet{whichSet}.probabilitiesFromSimulatedData(:),...
        dataSet{whichSet}.predictedProbabilitiesBasedOnSolution(:));
    
    % Plot current solution.
    if plotSolution
        ColorMaterialModelPlotSolution(dataSet{whichSet}.probabilitiesFromSimulatedData, dataSet{whichSet}.predictedProbabilitiesBasedOnSolution, ...
            dataSet{whichSet}.returnedParams, indexMatrix, params, figDir, ...
            saveFig, weibullplots, ...
            dataSet{whichSet}.probabilitiesForActualPositions);
    end
end
% Save current fit
cd(dataDir)
save([params.subjectName 'Fit.mat'], 'dataSet', 'params', 'pairInfo')