% ColorMaterialModelPlotFittedData.m
% Import already fitted data and plots them. 
% Useful for debugging plotting functions and for just looking at some
% already fit data sets. 
%
% 06/21/2017 ar Wrote it. 

% Initialize; 
clear; close all; 

% Main demo for the toolbox and larger audience. 
% If this is set to false, then the data is saved on dropbox and analyzed
% separately (as a part of the main model/experimental analysis. 
MAINDEMO = true; 
if MAINDEMO
    dataDir = '/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/';
else
    dataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/DemoData/';
end
figDir = dataDir;
saveFig = 0; 
weibullplots = 0; 
%% Load a data set (given the params)
nBlocks = 24; 
simulatedW = 0.5; 
nDataSets = 1; 
fileName = ['DemoData' num2str(simulatedW) 'W' num2str(nBlocks) 'Blocks' num2str(nDataSets) 'Fit.mat']; 
cd(dataDir)
load(fileName);
for whichSet = 1:length(dataSet)
    ColorMaterialModelPlotSolution(dataSet{whichSet}.probabilitiesFromSimulatedData, dataSet{whichSet}.predictedProbabilitiesBasedOnSolution, ...
        dataSet{whichSet}.returnedParams, indexMatrix, params, figDir, ...
        saveFig, weibullplots, ...
        dataSet{whichSet}.probabilitiesForActualPositions);
end