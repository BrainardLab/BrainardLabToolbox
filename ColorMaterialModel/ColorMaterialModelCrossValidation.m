% ColorMaterialModelCrossValidation
%
% Perform cross valiadation to establish the quality of the model.
%
% We want to be able to compare several instancies of our model using cross
% validation. The main goal is to figure out whether we're overfitting with
% our many parameters.
%
% 03/17/2017 ar Wrote it.

% Initialize
clear; close all;

% Set directories and load the subject data
subjectList = {'mdc'};
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/';
load([mainDir, 'Experiment1/pairIndicesE1P2.mat']);  % pair indices
load('ColorMaterialExampleStructure.mat')  % other params.
load colorMaterialInterpolateFunctionCubic.mat

params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.tryWeightValues = 0.5;
params.trySpacingValues = [0.5 1 2];
params.maxPositionValue = 20;
params.whichMethod = 'lookup';
params.nSimulate = 1000;
params.F = colorMaterialInterpolatorFunction;
% Arbitrarily decide nFolds
nFolds = 6;
nModelTypes = 3;
nConditions = 1;

whichError = 'loglikelihood';
for s = 1:length(subjectList)
    load([mainDir, 'Experiment1/' subjectList{s} 'SummarizedData.mat']); % data
    nTrials = size(thisSubject.block,2);
    
    for whichModelType = 1:nModelTypes
        if whichModelType == 1
            params.whichWeight = 'weightVary';
            params.whichPositions = 'full';
            thisSubject.model{whichModelType} = 'Full-Vary';
        elseif whichModelType == 2
            params.whichWeight = 'weightVary';
            params.whichPositions = 'smoothSpacing';
            params.smoothOrder = 1;
            params.model{whichModelType} = 'SmoothLinear-Vary';
        elseif whichModelType == 3
            params.whichWeight = 'weightVary';
            params.whichPositions = 'smoothSpacing';
            params.smoothOrder = 2;
            params.model{whichModelType} = 'SmoothQuadratic-Vary';
        end
        
        for whichCondition = 1:nConditions
            
            % partition for cross validation.
            c = cvpartition(nTrials,'Kfold',nFolds);
            for kk = 1:nFolds
                
                clear trainingIndex testIndex trainingData testData nTrainingTrials nTestTrials probabilitiesTestData
                % Get indices for kkth fold
                trainingIndex = c.training(kk);
                testIndex = c.test(kk);
                
                % Separate the training from test data
                trainingData = sum(responsesAcrossBlocks(:,trainingIndex),2);
                testData = sum(responsesAcrossBlocks(:,testIndex),2);
                nTrainingTrials = c.TrainSize(kk)*ones(size(trainingData));
                nTestTrials = c.TestSize(kk)*ones(size(testData));
                pTestData = testData./nTestTrials;
                
                % Get the predictions from the model for current parameters
                [thisSubject.condition{whichCondition}.crossVal(whichModelType).returnedParamsTraining(kk,:), ...
                    thisSubject.condition{whichCondition}.crossVal(whichModelType).logLikelyFitTraining(kk), ...
                    thisSubject.condition{whichCondition}.crossVal(whichModelType).predictedProbabilitiesBasedOnSolutionTraining(kk,:), ...
                    thisSubject.condition{whichCondition}.crossVal(whichModelType).kTraining(kk)] = ...
                    FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
                    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
                    trainingData, c.TrainSize(kk)*ones(size(trainingData)),...
                    params, 'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
                    'tryWeightValues',params.tryWeightValues,'trySpacingValues',params.trySpacingValues, ...
                    'maxPositionValue', params.maxPositionValue);
                
                % Now use these parameters to predict the response for the test data.
                [negLogLikely,predictedResponses] = FitColorMaterialModelMLDSFun(thisSubject.condition{whichCondition}.crossVal(whichModelType).returnedParamsTraining(kk,:),...
                    pairColorMatchColorCoords,pairMaterialMatchColorCoords,...
                    pairColorMatchMaterialCoords,pairMaterialMatchMaterialCoords,...
                    testData, nTestTrials, params);
                
                thisSubject.condition{whichCondition}.crossVal(whichModelType).LogLikelyhood(kk) = -negLogLikely;
                thisSubject.condition{whichCondition}.crossVal(whichModelType).predictedProbabilities(kk,:) = predictedResponses;
                
                % Compute RMSE (it's easy enough and we might want to look at
                % some point)
                thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError(kk) = ...
                    ComputeRealRMSE(predictedResponses, pTestData);
                clear negLogLikely predictedResponses
            end
            
            % Compute mean error for both rmse and log likelihood.
            thisSubject.condition{whichCondition}.crossVal(whichModelType).meanRMSError = ...
                mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError);
            thisSubject.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood = ...
                mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).LogLikelyhood);
        end
    end
    
    cd([mainDir' 'Experiment1/CrossVal']);
    save([subjectList{s} 'CV' num2str(nFolds) 'Folds'],  'thisSubject');
end