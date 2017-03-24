% ColorMaterialModelCrossValidation
% Perform cross valiadation to establish the quality of the model.
%
% We want to be able to compare several instancies of our model using cross
% validation. The main goal is to figure out whether we're overfitting with
% our many parameters. Here we use the simulated demo data to learn more
% about diffferent models by examining the cross validation 
%
% 03/17/2017 ar Wrote it.

% Initialize
clear; close all;

% Set directories and load the subject data
mainDir = pwd;
load('ColorMaterialExampleStructure.mat')  % other params.
load colorMaterialInterpolateFunctionCubic.mat
params.F = colorMaterialInterpolatorFunction;
params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.tryWeightValues = [0.25 0.5 0.75];
params.trySpacingValues = [0.5 1 2 3];
params.maxPositionValue = 20;
params.whichMethod = 'lookup';
params.nSimulate = 1000;
LINEAR = 0; 
% Set cross validation paramters
nFolds = 6;
if LINEAR
    load(['demoSimulatedData-' date '.mat']); % data
else
    load(['demoSimulatedDataNonLin-' date '.mat']); % data
end
nModelTypes = 3;
nConditions = 1;
nTrials = nBlocks*ones(size(responsesFromSimulatedData));
nTrials = nTrials(1);
for whichModelType = 1:nModelTypes
    if whichModelType == 1
        params.whichWeight = 'weightVary';
        params.whichPositions = 'full';
        thisSubject.model{whichModelType} = 'Full-Vary';
    elseif whichModelType == 2
        params.whichWeight = 'weightVary';
        params.whichPositions = 'smoothSpacing';
        params.smoothOrder = 1;
        thisSubject.model{whichModelType}  = 'SmoothLinear-Vary';
    elseif whichModelType == 3
        params.whichWeight = 'weightVary';
        params.whichPositions = 'smoothSpacing';
        params.smoothOrder = 2;
        thisSubject.model{whichModelType}  = 'SmoothCubic-Vary';
    end
    
    for whichCondition = 1:nConditions
       
        % partition for cross validation.
        c = cvpartition(nTrials,'Kfold',nFolds);
        for kk = 1:c.NumTestSets
            
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
            
%           Compute RMSE (it's easy enough and we might want to look at
%           some point)
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
cd(mainDir);
if LINEAR
    save(['demoCV' num2str(nFolds) 'NonLinFolds' date],  'thisSubject');
else
    save(['demoCV' num2str(nFolds) 'LinFolds' date],  'thisSubject');
end
for i = 1:3
k(i) = thisSubject.condition{1}.crossVal(i).meanLogLikelihood; end
fprintf('meanLogLikely: Full %.4f, Linear %.4f, Quadratic %.4f.\n', k(1), k(2),k(3)); 


for i = 1:3
k(i) = thisSubject.condition{1}.crossVal(i).meanRMSError; end
fprintf('meanRMSE: Full %.4f, Linear %.4f, Quadratic %.4f.\n', k(1), k(2),k(3)); 

[H,P,CI,STATS] = ttest2(thisSubject.condition{1}.crossVal(1).LogLikelyhood, thisSubject.condition{1}.crossVal(2).LogLikelyhood); 
fprintf('Full Vs Linear LogLikely: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest2(thisSubject.condition{1}.crossVal(2).LogLikelyhood, thisSubject.condition{1}.crossVal(3).LogLikelyhood); 
fprintf('Linear Vs Quadratic LogLikely: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest2(thisSubject.condition{1}.crossVal(1).LogLikelyhood, thisSubject.condition{1}.crossVal(3).LogLikelyhood); 
fprintf('Full Vs Quadratic LogLikely: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest2(thisSubject.condition{1}.crossVal(1).RMSError, thisSubject.condition{1}.crossVal(2).RMSError); 
fprintf('Full Vs Linear RMSE: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest2(thisSubject.condition{1}.crossVal(2).RMSError, thisSubject.condition{1}.crossVal(3).RMSError); 
fprintf('Linear Vs Quadratic RMSE: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest2(thisSubject.condition{1}.crossVal(1).RMSError, thisSubject.condition{1}.crossVal(3).RMSError); 
fprintf('Full Vs Quadratic RMSE: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 