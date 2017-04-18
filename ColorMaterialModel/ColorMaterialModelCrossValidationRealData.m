% ColorMaterialModelCrossValidationRealData
% Perform cross valiadation to establish the quality of the model.  
%
%
% 03/17/2017 ar Wrote it.

% Initialize
clear; close all;

% Set directories and load the subject data
mainDir = pwd;

% Load the look up table. 
load colorMaterialInterpolateFunCubiceuclidean.mat
whichExperiment = 'E1P2FULL';

switch whichExperiment
    case 'Pilot'
        figAndDataDir = ['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/' whichExperiment '/'];
        % Specify other experimental parameters
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        % Load the pair indices.
        load([figAndDataDir 'pairIndicesPilot.mat'])
        load([figAndDataDir  'ParamsPilot.mat'])
    case 'E1P2FULL'
        figAndDataDir = ['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1/'];
        
        % Specify other experimental parameters
        subjectList = {'mdc','nsk'};
        conditionCode = {'NC', 'CY', 'CB'};
        load([figAndDataDir 'pairIndicesE1P2Complete.mat'])
        load([figAndDataDir 'ParamsE1P2FULL.mat'])
end

nSubjects = length(subjectList);
nConditions = length(conditionCode);
params.F = colorMaterialInterpolatorFunction;
params.trySpacingValues = [0.5 1 2 3];
params.maxPositionValue = 20;
params.whichMethod = 'lookup';
params.nSimulate = 1000;
whichWeight = 'weightVary';
% Set cross validation paramters

nModelTypes = 1; % we will only work with full positions for now. 
for s = 1:nSubjects
    switch whichExperiment
        case 'Pilot'
            load([figAndDataDir '/' subjectList{s} 'SummarizedData.mat']); % data
            nFolds = 5;
            nBlocks = 25;
        case 'E1P2FULL'
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
            nFolds = 6;
            nBlocks = 24;
    end
    
    for whichModelType = 1:nModelTypes
        if whichModelType == 1
            params.whichWeight = whichWeight;
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
        
        if strcmp(params.whichWeight, 'weightFixed')
            fixedWValue = [0.1:0.1:0.9];
            nWeigthValues = length(fixedWValue);
        else
            tryWeightValues = [0.5 0.2 0.8];
            nWeigthValues = 1;
        end
        
        for whichCondition = 1:nConditions
            for ww = 1:nWeigthValues
                
                % partition for cross validation.
                c = cvpartition(nBlocks,'Kfold',nFolds);
                
                if strcmp(params.whichWeight, 'weightFixed')
                    tryWeightValues = fixedWValue(ww);
                end
                
                for kk = 1:c.NumTestSets
                    
                    clear trainingIndex testIndex trainingData testData nTrainingTrials nTestTrials probabilitiesTestData
                    % Get indices for kkth fold
                    trainingIndex = c.training(kk);
                    testIndex = c.test(kk);
                    
                    % Separate the training from test data
                    trainingData = sum(thisSubject.condition{whichCondition}.firstChosenAcrossTrials(:,trainingIndex),2);
                    testData = sum(thisSubject.condition{whichCondition}.firstChosenAcrossTrials(:,testIndex),2);
                    nTrainingTrials = c.TrainSize(kk)*ones(size(trainingData));
                    nTestTrials = c.TestSize(kk)*ones(size(testData));
                    pTestData = testData./nTestTrials;
                    
                    % Get the predictions from the model for current parameters
                    [thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).returnedParamsTraining(kk,:), ...
                        thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).logLikelyFitTraining(kk), ...
                        thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).predictedProbabilitiesBasedOnSolutionTraining(kk,:), ...
                        thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).kTraining(kk)] = ...
                        FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
                        pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
                        trainingData, c.TrainSize(kk)*ones(size(trainingData)),...
                        params, 'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
                        'tryWeightValues',tryWeightValues,'trySpacingValues',params.trySpacingValues, ...
                        'maxPositionValue', params.maxPositionValue);
                    
                    % Now use these parameters to predict the response for the test data.
                    [negLogLikely,predictedResponses] = FitColorMaterialModelMLDSFun(thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).returnedParamsTraining(kk,:),...
                        pairColorMatchColorCoords,pairMaterialMatchColorCoords,...
                        pairColorMatchMaterialCoords,pairMaterialMatchMaterialCoords,...
                        testData, nTestTrials, params);
                    
                    thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).LogLikelyhood(kk) = -negLogLikely;
                    thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).predictedProbabilities(kk,:) = predictedResponses;
                    
                    %  Compute RMSE (it's easy enough and we might want to look at
                    %  some point)
                    thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).RMSError(kk) = ...
                        ComputeRealRMSE(predictedResponses, pTestData);
                    clear negLogLikely predictedResponses
                end
                
                % Compute mean error for both rmse and log likelihood.
                thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).meanRMSError = ...
                    mean(thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).RMSError);
                thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).meanLogLikelihood = ...
                    mean(thisSubject.condition{whichCondition}.crossVal(whichModelType,ww).LogLikelyhood);
                
                cd(figAndDataDir);
                if strcmp(params.whichWeight, 'weightVary')
                    save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-' num2str(nFolds) 'Folds' date],  'thisSubject');
                else
                    save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-' num2str(fixedWValue(ww)) num2str(nFolds) 'Folds' date],  'thisSubject');
                end
                
            end
        end
    end    
end
