% ColorMaterialModelCrossValidationRealData
% Perform cross valiadation on uses it to extract model paramters.
%
% 03/17/2017 ar Wrote it.
% 04/30/2017 ar Clean up. Adding comments.

% Initialize
clear; close all;

% Load the look up table. Set experiment to analyze.
load colorMaterialInterpolateFunCubiceuclidean.mat
whichExperiment = 'Pilot';

% Set paramters for a given expeirment.
switch whichExperiment
    case 'Pilot'
        figAndDataDir = ['/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/' whichExperiment '/'];
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        nFolds = 5;
        nBlocks = 25;
        load([figAndDataDir 'pairIndicesPilot.mat'])
        load([figAndDataDir  'ParamsPilot.mat'])
    case 'E1P2FULL'
        figAndDataDir = ['/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1/'];
        subjectList = {'mdc','nsk'};
        conditionCode = {'NC', 'CY', 'CB'};
        nFolds = 6;
        nBlocks = 24;
        load([figAndDataDir 'pairIndicesE1P2Complete.mat'])
        load([figAndDataDir 'ParamsE1P2FULL.mat'])
end

nSubjects = length(subjectList);
nConditions = length(conditionCode);
params.F = colorMaterialInterpolatorFunction;
params.trySpacingValues = [0.5 1 2 3];
params.tryWeightValues = [0.5 0.2 0.8];

params.maxPositionValue = 20;
params.whichMethod = 'lookup';
params.nSimulate = 1000;
whichWeight = 'weightVary';

% Set cross validation parameters
nModelTypes = 1;
for s = 1:nSubjects
    switch whichExperiment
        case 'Pilot'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedData.mat']); % data
        case 'E1P2FULL'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
    end
    
    % Partition data for cross validation.
    c = cvpartition(nBlocks,'Kfold',nFolds);
    
    for whichCondition = 1:nConditions
        for kk = 1:c.NumTestSets
            
            clear trainingIndex testIndex trainingData testData nTrainingTrials nTestTrials probabilitiesTestData
            
            % Get indices for kkth fold
            trainingIndex = c.training(kk);
            testIndex = c.test(kk);
            
            % Separate the training from test data
            trainingData = sum(thisSubject.condition{whichCondition}.firstChosenPerTrial(:,trainingIndex),2);
            testData = sum(thisSubject.condition{whichCondition}.firstChosenPerTrial(:,testIndex),2);
            nTrainingTrials = c.TrainSize(kk)*ones(size(trainingData));
            nTestTrials = c.TestSize(kk)*ones(size(testData));
            probabilitiesTestData = testData./nTestTrials;
            
            for whichModelType = 1:nModelTypes
                if whichModelType == 1
                    params.whichWeight = whichWeight;
                    params.whichPositions = 'smoothSpacing';
                    params.smoothOrder = 1;
                    params.tryColorSpacingValues = params.trySpacingValues;
                    params.tryMaterialSpacingValues = params.trySpacingValues;
                    params.tryWeightValues = params.tryWeightValues;
                elseif whichModelType == 2
                    params.whichWeight = whichWeight;
                    params.whichPositions = 'smoothSpacing';
                    params.smoothOrder = 3;
                    params.tryColorSpacingValues = [linearSolutionColorSlope];
                    params.tryMaterialSpacingValues = [linearSolutionMaterialSlope];
                    params.tryWeightValues = [params.tryWeightValues]; 
                elseif whichModelType == 3
                    params.whichWeight = whichWeight;
                    params.whichPositions = 'full';
                    params.tryColorSpacingValues = [linearSolutionColorSlope];
                    params.tryMaterialSpacingValues = [linearSolutionMaterialSlope];
                    params.tryWeightValues = [params.tryWeightValues]; 
                end
                
                % Get the predictions from the model for current parameters
                [thisSubject.condition{whichCondition}.crossVal(whichModelType).returnedParamsTraining(kk,:), ...
                    thisSubject.condition{whichCondition}.crossVal(whichModelType).logLikelyFitTraining(kk), ...
                    thisSubject.condition{whichCondition}.crossVal(whichModelType).predictedProbabilitiesBasedOnSolutionTraining(kk,:)] = ...
                    FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
                    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
                    trainingData, nTrainingTrials,params, ...
                    'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
                    'tryWeightValues',params.tryWeightValues,'tryColorSpacingValues',params.tryColorSpacingValues,'tryMaterialSpacingValues',params.tryMaterialSpacingValues, ...
                    'maxPositionValue', params.maxPositionValue);
                
                % For linear model, grab solution to use as a start when we search for
                % the cubic and full solutions.
                if (whichModelType == 1)
                    linearSolutionParameters = thisSubject.condition{whichCondition}.crossVal(whichModelType).returnedParamsTraining(kk,:);
                    linearSolutionMaterialSlope = linearSolutionParameters(1);
                    linearSolutionColorSlope = linearSolutionParameters(2);
                    linearSolutionWeight = linearSolutionParameters(3);
                end
                
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
        end 
        
        % Compute mean error for both log likelihood and rmse.
        thisSubject.condition{whichCondition}.crossVal(whichModelType).meanRMSError = ...
            mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError);
        thisSubject.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood = ...
            mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).LogLikelyhood);
        
        % Save in the right folder.
        cd(figAndDataDir);
        save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-' num2str(nFolds) 'Folds'],  'thisSubject');
    end
end