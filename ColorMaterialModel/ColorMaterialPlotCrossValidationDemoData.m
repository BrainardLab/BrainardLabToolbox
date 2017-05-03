% ColorMaterialModelCrossValidation
% Perform cross valiadation to establish the quality of the model.
%
% We want to be able to compare several instancies of our model using cross
% validation. The main goal is to figure out whether we're overfitting with
% our many parameters. Here we use the simulated demo data to learn more
% about diffferent models by examining the cross validation
%
% 03/17/2017 ar Wrote it.
% 04/30/2017 ar Clean up and comment.

% Initialize
clear; close all;

% Set directories and load the subject data
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots';

% Load lookup tables.
load('ColorMaterialExampleStructure.mat')  % other params.
load colorMaterialInterpolateFunCubiceuclidean.mat

% Set parameters.
params.F = colorMaterialInterpolatorFunction;
params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.tryWeightValues = [0.25 0.5 0.75];
params.trySpacingValues = [0.5 1 2 3];
params.maxPositionValue = 20;
params.whichMethod = 'lookup';
params.nSimulate = 1000;
nModelTypes = 3;
nConditions = 1;

% Try linear vs. non-linear data simulation.
LINEAR = 0;

% Set cross validation paramters
nFolds = 6;
if LINEAR
    load(['demoSimulatedData-24-Mar-2017.mat']); % data
else
    load(['demoSimulatedDataNonLin-24-Mar-2017.mat']); % data
end
nTrials = nBlocks*ones(size(responsesFromSimulatedData));
nTrials = nTrials(1);

% Partition for cross validation.
c = cvpartition(nTrials,'Kfold',nFolds);


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
        params.smoothOrder = 3;
        thisSubject.model{whichModelType}  = 'SmoothCubic-Vary';
    end
    
    for whichCondition = 1:nConditions
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
            probabilitiesTestData = testData./nTestTrials;
            
            % Get the predictions from the model for current parameters
            [thisSubject.condition{whichCondition}.crossVal(whichModelType).returnedParamsTraining(kk,:), ...
                thisSubject.condition{whichCondition}.crossVal(whichModelType).logLikelyFitTraining(kk), ...
                thisSubject.condition{whichCondition}.crossVal(whichModelType).predictedProbabilitiesBasedOnSolutionTraining(kk,:), ...
                thisSubject.condition{whichCondition}.crossVal(whichModelType).kTraining(kk)] = ...
                FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
                pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
                trainingData, nTrainingTrials,params, ...
                'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
                'tryWeightValues',params.tryWeightValues,'trySpacingValues',params.trySpacingValues, ...
                'maxPositionValue', params.maxPositionValue);
            
            % Now use these parameters to predict the responses for the test data.
            [negLogLikely,predictedResponses] = FitColorMaterialModelMLDSFun(thisSubject.condition{whichCondition}.crossVal(whichModelType).returnedParamsTraining(kk,:),...
                pairColorMatchColorCoords,pairMaterialMatchColorCoords,...
                pairColorMatchMaterialCoords,pairMaterialMatchMaterialCoords,...
                testData, nTestTrials, params);
            
            thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).LogLikelyhood(kk) = -negLogLikely;
            thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).predictedProbabilities(kk,:) = predictedResponses;
            
            %  Compute RMSE, in case we want to look at them at some point in the future)
            thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError(kk) = ...
                ComputeRealRMSE(predictedResponses, probabilitiesTestData);
            clear negLogLikely predictedResponses
        end
        
        % Compute mean error for both log likelihood and rmse.
        thisSubject.condition{whichCondition}.crossVal(whichModelType).meanRMSError = ...
            mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError);
        thisSubject.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood = ...
            mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).LogLikelyhood);
        
    end
end
cd(mainDir);
if LINEAR
    save(['demoCrossVal' num2str(nFolds) 'NonLinFolds' date],  'thisSubject');
else
    save(['demoCrossVal' num2str(nFolds) 'LinFolds' date],  'thisSubject');
end

%% Print outputs
for i = 1:nModelTypes
    k(i) = thisSubject.condition{1}.crossVal(i).meanLogLikelihood;
end
fprintf('meanLogLikely: Full %.4f, Linear %.4f, Cubic %.4f.\n', k(1), k(2),k(3)); 

for i = 1:nModelTypes
    k(i) = thisSubject.condition{1}.crossVal(i).meanRMSError;
end
fprintf('meanRMSE: Full %.4f, Linear %.4f, Cubic %.4f.\n', k(1), k(2),k(3));

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(1).LogLikelyhood, thisSubject.condition{1}.crossVal(2).LogLikelyhood); 
fprintf('Full Vs Linear LogLikely: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(2).LogLikelyhood, thisSubject.condition{1}.crossVal(3).LogLikelyhood); 
fprintf('Linear Vs Cubic LogLikely: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(1).LogLikelyhood, thisSubject.condition{1}.crossVal(3).LogLikelyhood); 
fprintf('Full Vs Cubic LogLikely: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(1).RMSError, thisSubject.condition{1}.crossVal(2).RMSError); 
fprintf('Full Vs Linear RMSE: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest(thisSubject.condition{1}.crossVal(2).RMSError, thisSubject.condition{1}.crossVal(3).RMSError); 
fprintf('Linear Vs Cubic RMSE: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 

[H,P,CI,STATS] = ttest2(thisSubject.condition{1}.crossVal(1).RMSError, thisSubject.condition{1}.crossVal(3).RMSError); 
fprintf('Full Vs Cubic RMSE: t(%d) = %.2f, p = %.4f, \n', STATS.df, STATS.tstat, P); 