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
load('/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1/mdcSummarizedData.mat') % data
load('/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1/pairIndicesE1P2.mat');  % pair indices
load('ColorMaterialExampleStructure.mat')  % other params. 
params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end); 
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end); 
params.smoothOrder = 3;
trySpacingValues = [0.5 1 2];
tryWeightValues = 0.5; 
params.trySpacingValues = trySpacingValues; 

nReplications = size(thisSubject.block,2);  

% colorCoordIndex = 1;
% materialCoordIndex = 2;
% colorMatchIndexInPair = 1;
% materialMatchIndexInPair = 2;

% Arbitrarily decide nFolds
nFolds = 8; 

% I am not sure yet, what other things we need to pass. 
c = cvpartition(nReplications,'Kfold',nFolds);
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
    trainingData = sum(thisSubject.condition{1}.chosenAcrossTrials(:, trainingIndex),2); %./sum(trainingIndex);
    testData = sum(thisSubject.condition{1}.chosenAcrossTrials(:, trainingIndex),2); %./sum(trainingIndex);
    
    % Compute the probabilities from the test data.
    % This is what we will compare with the predictions based on the
    % training data
    pTestData = sum(thisSubject.condition{1}.chosenAcrossTrials(:, trainingIndex),2)./sum(testIndex);
    
      
    params.whichPositions = 'smoothSpacing'; 
   
    % Get the predictions from the smooth spacing model
    [returnedParamsTrainingSmooth(kk,:), logLikelyFitTrainingSmooth(kk), predictedProbabilitiesBasedOnSolutionTrainingSmooth(kk,:), kTrainingSmooth(kk)] = ...
           ColorMaterialModelMain(pairColorMatchMaterialCoordIndices,pairMaterialMatchColorCoordIndices,...
        trainingData,sum(trainingIndex)*[ones(size(trainingData))],params, ...
        'whichPositions', 'smoothSpacing','whichWeight','weightFixed', ...
        'tryWeightValues',tryWeightValues,'trySpacingValues',trySpacingValues); %#ok<SAGROW>
    
    params.whichPositions = 'full'; 
    % Get the predictions from the full positions model
    [returnedParamsTrainingFull(kk,:), logLikelyFitTrainingFull(kk), predictedProbabilitiesBasedOnSolutionTrainingFull(kk,:), kTrainingFull(kk)] = ...
        ColorMaterialModelMain(pairColorMatchMaterialCoordIndices,pairMaterialMatchColorCoordIndices,...
        trainingData,sum(trainingIndex)*[ones(size(trainingData))],params, ...
        'whichPositions', 'full','whichWeight','weightFixed', ...
        'tryWeightValues',tryWeightValues,'trySpacingValues',trySpacingValues); %#ok<SAGROW>
 
    % compute the error for each kk 
    SmoothPositionsRMSError(kk) = computeRealRMSE(pTestData, predictedProbabilitiesBasedOnSolutionTrainingSmooth(kk,:)'); 
    FullPositionsRMSError(kk) = computeRealRMSE(pTestData, predictedProbabilitiesBasedOnSolutionTrainingFull(kk,:)'); 
end

% Get mean error for two types of model
meanSmoothPositionsError = mean(SmoothPositionsRMSError);
meanFullPositionsError = mean(FullPositionsRMSError);
cd('/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1/')
save('crossValidationTake8')