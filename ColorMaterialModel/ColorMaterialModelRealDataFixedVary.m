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
        figAndDataDir = ['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/' whichExperiment '/'];
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        nFolds = 5;
        nBlocks = 25;
        load([figAndDataDir 'pairIndicesPilot.mat'])
        load([figAndDataDir  'ParamsPilot.mat'])
    case 'E1P2FULL'
        figAndDataDir = ['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1/'];
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

params.maxPositionValue = 20;
params.whichMethod = 'lookup';
params.nSimulate = 1000;
params.whichWeight = 'weigthVary';
params.tryWeigthValues = [0.2 0.5 0.8];
% positions: full or smoothSpacing
params.whichPositions = 'full';
fixedWeightValues = [0.1:0.1:0.9];
if strcmp(whichWeigth, 'weightFixed')
    fixedWeightValues = 0.5;
end

% Set cross validation parameters
nModelTypes = 1;
for s = 1:nSubjects
    switch whichExperiment
        case 'Pilot'
            load([figAndDataDir '/' subjectList{s} 'SummarizedData.mat']); % data
        case 'E1P2FULL'
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
    end
    
    for whichFixedWeigth = 1:length(fixedWeightValues)
        clear thisSubject
        if strcmp(whichWeigth, 'weightFixed')
            params.tryWeigthValues = fixedWeightValues(whichFixedWeigth);
        end
        
        for whichCondition = 1:nConditions
            nTrials = thisSubject.condition{whichCondition}.totalTrials;
            
            % Get the predictions from the model for current parameters
            [thisSubject.condition{whichCondition}.returnedParams, ...
                thisSubject.condition{whichCondition}.logLikelyFit, ...
                thisSubject.condition{whichCondition}.predictedProbabilitiesBasedOnSolution, ...
                thisSubject.condition{whichCondition}.k] = ...
                FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
                pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
                thisSubject.condition{whichCondition}.firstChosen , nTrials,params, ...
                'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
                'tryWeightValues',params.tryWeightValues,'trySpacingValues',params.trySpacingValues, ...
                'maxPositionValue', params.maxPositionValue);
            
            thisSubject.condition{whichCondition}.RMSError = ...
                ComputeRealRMSE(predictedResponses, probabilitiesTestData);
            
            % Save in the right folder.
            cd(figAndDataDir);
            if strcmp(params.whichWeigth, 'weightFixed')
                save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-' num2str(fixedWeigthValue)],  'thisSubject');
            else
                save([subjectList{s} conditionCode{whichCondition} params.whichWeight],  'thisSubject');
            end
        end
    end
end