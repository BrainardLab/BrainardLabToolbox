% ColorMaterialModelCrossValidation
%
% Write a skeleton to do cross validation. 
% Use cvpartition
%
% We want to be able to compare two instancies of our model using cross
% validation. The main goal is to figure out whether we're overfitting with
% our many parameters. 
%
% A thing we know so far is that full positions + weights fixed model (12 params) works
% equally well as the full positions + weights vary model. It looks like
% any crazy inappropriate weight can be 'countered' by recovering certain
% (crazy) position. We therefore suspect our 12 params model might be
% overfitting the data. To test for the possibility of overfitting with the increasing number of 
% parameters in smoothPositions vs. fullPositions we want to use cross validation
%
% Basic cross validation for one model option 

% Initialize
clear; close all; 

% First thing to do is take a set of test data and organize it so that 
% each block is a column and each row is a set of trials
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/'; 
load([mainDir, 'Experiment1/mdcSummarizedData.mat']); % data
% adjust this. 
load([mainDir, 'Experiment1/pairIndicesE1P2.mat']);  % pair indices

load('ColorMaterialExampleStructure.mat')  % other params. 
params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end); 
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end); 
params.smoothOrder = 3;
trySpacingValues = [0.5 1 2];
tryWeightValues = 0.5; 
params.trySpacingValues = trySpacingValues; 
whichCondition = 1; 
params.whichWeight = 'weightVary'; 
nTrials = size(thisSubject.block,2);  

% Arbitrarily decide nFolds
nFolds = 5; 

c = cvpartition(nTrials,'Kfold',nFolds);
for kk = 1:nFolds
    
    % We keep the code below, that looks like it's standard.
    % Get indices for kkth fold
    trainingIndex = c.training(kk);
    testIndex = c.test(kk);
    
    % sanity check
    check = trainingIndex + testIndex;
    if (any(check ~= 1))
        error('We do not understand cvparitiion''s kFold indexing scheme');
    end
    
    % Here use the data to figure out how the two models compare.
    
    % Separate the training from test data
    trainingData = sum(thisSubject.condition{whichCondition}.chosenAcrossTrials(:, trainingIndex),2); %./sum(trainingIndex);
    testData = sum(thisSubject.condition{whichCondition}.chosenAcrossTrials(:, trainingIndex),2); %./sum(trainingIndex);
    
    % Compute the probabilities from the test data.
    % This is what we will compare with the predictions based on the
    % training data
    pTestData = sum(thisSubject.condition{whichCondition}.chosenAcrossTrials(:, testIndex),2)./sum(testIndex);  
    params.whichPositions = 'smoothSpacing'; 
    
    % Get the predictions from the smooth spacing model
    [returnedParamsTrainingSmooth(kk,:), logLikelyFitTrainingSmooth(kk), predictedProbabilitiesBasedOnSolutionTrainingSmooth(kk,:), kTrainingSmooth(kk)] = ...
        ColorMaterialModelMain(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
        pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
        trainingData,sum(trainingIndex)*[ones(size(trainingData))],params, ...
        'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
        'tryWeightValues',params.tryWeightValues,'trySpacingValues',params.trySpacingValues, ...
        'maxPositionValue', params.maxPositionValue); %#ok<SAGROW>
    
    params.whichPositions = 'full';
    % Get the predictions from the full positions model
    [returnedParamsTrainingFull(kk,:), logLikelyFitTrainingFull(kk), predictedProbabilitiesBasedOnSolutionTrainingFull(kk,:), kTrainingFull(kk)] = ...
        ColorMaterialModelMain(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
        pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
        trainingData,sum(trainingIndex)*[ones(size(trainingData))],params, ...
        'whichPositions', params.whichPositions,'whichWeight',params.whichWeight, ...
        'tryWeightValues',params.tryWeightValues,'trySpacingValues',params.trySpacingValues, ...
        'maxPositionValue', params.maxPositionValue); %#ok<SAGROW>

    switch whichError
        case 'rmse'
            SmoothPositionsRMSError(kk) = computeRealRMSE(pTestData, predictedProbabilitiesBasedOnSolutionTrainingSmooth(kk,:)');
            FullPositionsRMSError(kk) = computeRealRMSE(pTestData, predictedProbabilitiesBasedOnSolutionTrainingFull(kk,:)');
        case 'loglikelihood'
            SmoothPositionsLogLikelyhood(kk) = ColorMaterialModelComputeLogLikelihoodSimple(pTestData, predictedProbabilitiesBasedOnSolutionTrainingSmooth(kk,:)',nTrials);
            FullPositionsLogLikelyhood(kk) = ColorMaterialModelComputeLogLikelihoodSimple(pTestData, predictedProbabilitiesBasedOnSolutionTrainingFull(kk,:)',nTrials);
    end
end

% Get mean error for two types of model
switch whichError
    case 'rmse'
        meanSmoothPositionsError = mean(SmoothPositionsRMSError);
        meanFullPositionsError = mean(FullPositionsRMSError);
    case 'loglikelihood'
        meanLogLikelihoodSmoothPositions = mean(SmoothPositionsLogLikelyhood);
        meanLogLikelihoodFullPositions = mean(FullPositionsLogLikelyhood);
end
cd([mainDir' 'Experiment1/']); 
save(['crossValidation' num2str(nFolds) 'Folds']);