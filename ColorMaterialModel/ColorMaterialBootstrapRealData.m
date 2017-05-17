% ColorMaterialModelBootstrapRealData
% Perform bootstraping to find confidence intervals for model paramters.
%
% 04/30/2017 ar Wrote it from cross-validation code. 
% 04/30/2017 ar Added comments.

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
params.tryWeightValues = [0.5 0.2 0.8];

params.maxPositionValue = 20;
params.whichMethod = 'lookup';
params.nSimulate = 1000;
whichWeight = 'weightVary';
nModelTypes = 1; 
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
                        
            % Find indices for bootstrap data. 
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
            
            for whichModelType = 1:nModelTypes
                if whichModelType
                    params.whichWeight = whichWeight;
                    params.whichPositions = 'full';
                    params.tryColorSpacingValues = [params.trySpacingValues];
                    params.tryMaterialSpacingValues = [params.trySpacingValues];
                    params.tryWeightValues = [params.tryWeightValues];
                else
                    error('Model type not yet implemented. ')
                end
                
                % Get the predictions from the model for current parameters
                [thisSubject.condition{whichCondition}.bootstrap(whichModelType).returnedParams(kk,:), ...
                    thisSubject.condition{whichCondition}.bootstrap(whichModelType).logLikelyFit(kk), ...
                    thisSubject.condition{whichCondition}.bootstrap(whichModelType).predictedProbabilitiesBasedOnSolution(kk,:)] = ...
                    FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
                    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
                    bootstrapData, nBootstrapTrials,params, ...
                    'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
                    'tryWeightValues',params.tryWeightValues,'tryColorSpacingValues',params.tryColorSpacingValues,'tryMaterialSpacingValues',params.tryMaterialSpacingValues, ...
                    'maxPositionValue', params.maxPositionValue);
            end
        end
        
        for jj = 1:size(thisSubject.condition{whichCondition}.bootstrap.returnedParamsTraining,2)
            subject{s}.thisSubject.condition{whichCondition}.bootstrapMeans(jj) = mean(thisSubject.condition{whichCondition}.bootstrap.returnedParamsTraining(:,jj));
            subject{s}.thisSubject.condition{whichCondition}.bootstrapCI(jj,1) = prctile(thisSubject.condition{whichCondition}.bootstrap.returnedParamsTraining(:,jj),100*CIlo);
            subject{s}.thisSubject.condition{whichCondition}.bootstrapCI(jj,2) = prctile(thisSubject.condition{whichCondition}.bootstrap.returnedParamsTraining(:,jj),100*CIhi);
        end
        
       % Save in the right folder.
        cd(figAndDataDir);
        save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-Bootstrap'],  'thisSubject');
    end
end