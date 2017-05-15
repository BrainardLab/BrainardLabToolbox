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
nRepetitions = 150; 
for s = 1:nSubjects
    switch whichExperiment
        case 'Pilot'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedData.mat']); % data
        case 'E1P2FULL'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
    end
    
    for whichCondition = 1:nConditions
        
        for kk = 1:nRepetitions
                        
            % Separate the training from test data
            nTrialTypes = size(thisSubject.condition{whichCondition}.firstChosenPerTrial,1);
            if (size(thisSubject.condition{whichCondition}.firstChosenPerTrial,2) ~= nBlocks)
                error('Oops');
            end
            bootstrapData = zeros(nTrialTypes,1);
            for bb = 1:nTrialTypes
                id = randi(nBlocks,[nBlocks 1]);
                bootstrapData(bb) = sum(thisSubject.condition{whichCondition}.firstChosenPerTrial(bb,id));
            end
            nBootstrapTrials = nBlocks*ones(nTrialTypes,1);
            
            for whichModelType = 1%:nModelTypes
              
                    params.whichWeight = whichWeight;
                    params.whichPositions = 'full';
                    params.tryColorSpacingValues = [params.trySpacingValues];
                    params.tryMaterialSpacingValues = [params.trySpacingValues];
                    params.tryWeightValues = [params.tryWeightValues]; 
               
                % Get the predictions from the model for current parameters
                [thisSubject.condition{whichCondition}.bootstrap(whichModelType).returnedParamsTraining(kk,:), ...
                    thisSubject.condition{whichCondition}.bootstrap(whichModelType).logLikelyFitTraining(kk), ...
                    thisSubject.condition{whichCondition}.bootstrap(whichModelType).predictedProbabilitiesBasedOnSolutionTraining(kk,:)] = ...
                    FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
                    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
                    bootstrapData, nBootstrapTrials,params, ...
                    'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
                    'tryWeightValues',params.tryWeightValues,'tryColorSpacingValues',params.tryColorSpacingValues,'tryMaterialSpacingValues',params.tryMaterialSpacingValues, ...
                    'maxPositionValue', params.maxPositionValue);
                
                % For linear model, grab solution to use as a start when we search for
                % the cubic and full solutions.
                %
                % ANA TO CHECK WHICH IS MATERIAL SLOPE AND WHICH ONE IS THE
                % COLOR SLOPE.
%                 if (whichModelType == 1)
%                     linearSolutionParameters = thisSubject.condition{whichCondition}.bootstrap(whichModelType).returnedParamsTraining(kk,:);
%                     linearSolutionMaterialSlope = linearSolutionParameters(1);
%                     linearSolutionColorSlope = linearSolutionParameters(2);
%                     linearSolutionWeight = linearSolutionParameters(3);
%                 end
            end
        end 
        
       % Save in the right folder.
        cd(figAndDataDir);
        save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-Bootstrap'],  'thisSubject');
    end
end