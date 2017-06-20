%function [LogLikelyhood, RMSError, params] = ColorMaterialModelCrossValidation(theData, nBlocks, nFolds, pairInfo, params)
function [LogLikelyhood, RMSError, params] = ColorMaterialModelCrossValidation(theData, nBlocks, nFolds, pairInfo, params)
% Performs nFolds cross-validation on a given data set. Returns the errors
% expressed as logLikelihood (preferred) as well as RMSE and updated
% parameter structure if any. 
% 
% Input: 
% theData - full data from one expeirimental condition. This is a marix of
%           zeros and ones in the format nTrials x nBlocks (rows x
%           columns). 
% nBlocks - number of experimental blocks
% nFolds - number of different data subsamples for cross validation. 
% pairInfo - structure defining the pairs in each trial. 
% params - parameter structure
% 
% Output: 
% LogLikelyhood - log likelihood across validations
% RMSError - root mean square error across validations. 
% params - structure giving experiment design parameters

% March 2017 ar Wrote it. 
% 06/17/2017 ar Functionalized it, added comments. 

% Sanity check
if (size(theData,2) ~= nBlocks)
    error('Oops');
end
    
% Partition data for cross validation.
c = cvpartition(nBlocks,'Kfold',nFolds);

for kk = 1:c.NumTestSets
    
    clear trainingIndex testIndex trainingData testData nTrainingTrials nTestTrials probabilitiesTestData ...
        negLogLikely predictedResponses
    
    % Get indices for kkth fold
    trainingIndex = c.training(kk);
    testIndex = c.test(kk);
    
    % Separate the training from test data
    trainingData = sum(theData(:,trainingIndex),2);
    testData = sum(theData(:,testIndex),2);
    
    nTrainingTrials = c.TrainSize(kk)*ones(size(trainingData));
    nTestTrials = c.TestSize(kk)*ones(size(testData));
    probabilitiesTestData = testData./nTestTrials;
    
    % Get the predictions from the model for current parameters
    [returnedParamsTraining(kk,:), logLikelyFitTraining(kk), predictedProbabilitiesBasedOnSolutionTraining(kk,:)] = ...
        FitColorMaterialModelMLDS(pairInfo.pairColorMatchColorCoords, pairInfo.pairMaterialMatchColorCoords,...
        pairInfo.pairColorMatchMaterialCoords, pairInfo.pairMaterialMatchMaterialCoords,...
        trainingData, nTrainingTrials,params);
    
    % Now use these parameters to predict the responses for the test data.
    [negLogLikely,predictedResponses] = FitColorMaterialModelMLDSFun(returnedParamsTraining(kk,:),...
        pairInfo.pairColorMatchColorCoords,pairInfo.pairMaterialMatchColorCoords,...
        pairInfo.pairColorMatchMaterialCoords,pairInfo.pairMaterialMatchMaterialCoords,...
        testData, nTestTrials, params);
    
    LogLikelyhood(kk) = -negLogLikely;
    predictedProbabilities(kk,:) = predictedResponses;
    
    %  Compute RMSE, in case we want to look at them at some point in the future)
    RMSError(kk) = ComputeRealRMSE(predictedResponses, probabilitiesTestData);
end

% For linear model, grab the mean returend solution to use as a start when we search for
% the cubic and full solutions. We implement this by modifying the
% parameter structure. It will be implemented if we're doing
% testing of additional models.
if (strcmp (params.whichPositions, 'smoothSpacing')) && (params.smoothOrder == 1)
    tmpLinearSolutionParameters = mean(returnedParamsTraining,2);
    params.linearSolutionMaterialSlope = tmpLinearSolutionParameters(1);
    params.linearSolutionColorSlope = tmpLinearSolutionParameters(2);
    params.linearSolutionWeight = [params.tryWeightValues, tmpLinearSolutionParameters(3)];
end