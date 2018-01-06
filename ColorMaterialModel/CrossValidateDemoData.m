% CrossValidateDemoData
% Perform cross validation on demo data to establish the quality of the model.
%
% We want to be able to compare several instancies of our model using cross
% validation. The main goal is to figure out whether we're overfitting with
% our many parameters. Here we use the simulated demo data to learn more
% about diffferent models by examining the cross validation
%
% 03/17/2017 ar Wrote it.
% 04/30/2017 ar Clean up and comment.
% 06/19/2017 ar Pulled the cross validation function. Commenting and cleanup.  up code. 

% Initialize
clear; close all;

% Set directories and load the subject data
demoDir = [analysisDir '/DemoData/']; 

% Set parameters for the simulated data set we're cross-validating. 
nBlocks = 24; 
simulatedW = 0.5; 
nDataSets = 1; 

% Cross-validate linear or non-linear simulated dataset. 
LINEAR = 1;

% Set some parameters for cross validation. 
nModelTypes = 3;
nConditions = 1;
nFolds = 6;
printOutcome = 1; 

if LINEAR
    % THERE IS SOME HARDCODING OF THE NAME HERE. CHANGE if needed. 
    load([demoDir 'DemoData' num2str(simulatedW) 'W' num2str(nBlocks) 'Blocks' num2str(nDataSets)  'Lin.mat']); % data
else
    % Currently non lin option does not exist we should create it. 
    % load(['DemoData' num2str(w) 'W' num2str(nBlocks) num2str(nSets) 'NonLin.mat']); % data
end

%% Standard set of parameters we need to define for the model. 
params.whichMethod = 'lookup'; % options: 'lookup', 'simulate' or 'analytic'
params.whichDistance = 'euclidean'; % options: euclidean, cityblock (or any metric enabled by pdist function). 

% For simulate method, set up how many simulations to use for predicting probabilities.  
if strcmp(params.whichMethod, 'simulate')
    params.nSimulate = 1000;
end

% Does material/color weight vary in fit?
% Options: 
%  'weightVary' - yes, it does.
%  'weightFixed' - fix weight to specified value in tryWeightValues(1);
params.whichWeight = 'weightVary';

% Initial position spacing values to try.
params.tryColorSpacingValues = [0.5 1 2];
params.tryMaterialSpacingValues = [0.5 1 2];
params.tryWeightValues = [0.2 0.5 0.8];

% addNoise parameter is already a part of the generated data sets. 
% We should not set it again here. Commenting it out. 
% params.addNoise = true; 
params.maxPositionValue = max(params.F.GridVectors{1});

%% Define different models. 
% To enable the same partition across condition
for whichModelType = 1:nModelTypes
    if whichModelType == 1
        params.whichPositions = 'smoothSpacing';
        params.smoothOrder = 1;
        modelCode = 'Linear'; 
    elseif whichModelType == 2
        % For which model type 2 and 3 - use the spacing values for color and material
        % that are returned by a linear fit as a starting point.
        % Instead the whole list of parameters we have used before.
        params.whichPositions = 'smoothSpacing';
        params.smoothOrder = 3; % overwrite smooth spacing default.
        modelCode = 'Cubic'; 
    elseif whichModelType == 3
        params.whichPositions = 'full';
        modelCode = 'Full'; 
    end
    
    % Run the cross validation for this condition
    % Demo case has just one condition, by default. 
    for whichCondition = 1:nConditions
        [dataSet{1}.condition{whichCondition}.crossVal(whichModelType).LogLikelihood, ...
            dataSet{1}.condition{whichCondition}.crossVal(whichModelType).RMSError, ...
            params] = ColorMaterialModelCrossValidation(dataSet{1}.responsesAcrossBlocks, nBlocks, nFolds, pairInfo, params);
        
        % Compute mean error for both log likelihood and rmse.
        dataSet{1}.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood = ...
            mean(dataSet{1}.condition{whichCondition}.crossVal(whichModelType).LogLikelyhood);
        dataSet{1}.condition{whichCondition}.crossVal(whichModelType).meanRMSError = mean(dataSet{1}.condition{whichCondition}.crossVal(whichModelType).RMSError);
    end
end

% Save in the right folder.
cd(demoDir)
save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-' num2str(nFolds) 'FoldsCVResults'],  'dataSet{1}');
cd(analysisDir)

%% Print outputs
if printOutcome 
    for i = 1:nModelTypes
        tmpMeanError(i) = mean(dataSet{1}.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood);
    end
    fprintf('meanLogLikely: %s  %.4f, %s %.4f, %s %.4f.\n', modelCode(1), tmpMeanError(1), modelCode(2), tmpMeanError(2), modelCode(3), tmpMeanError(3));
    
    for i = 1:nModelTypes
        tmpMeanError(i) = mean(dataSet{1}.condition{whichCondition}.crossVal(whichModelType).RMSError);
    end
    fprintf('meanRMSE: %s  %.4f, %s %.4f, %s %.4f.\n', modelCode(1), tmpMeanError(1), modelCode(2), tmpMeanError(2), modelCode(3), tmpMeanError(3));
    
    modelPair = [1, 2; 1,3; 1,2];
    for whichModelPair = 1:length(modelPair)
        [~,P,~,STATS] = ttest(dataSet{1}.condition{1}.crossVal(modelPair(1)).LogLikelyhood, dataSet{1}.condition{1}.crossVal(modelPair(2)).LogLikelyhood);
        fprintf('%s Vs %s LogLikely: t(%d) = %.2f, p = %.4f, \n', modelCode(whichModelPair(1)), ...
            modelCode(whichModelPair(2)), STATS.df, STATS.tstat, P);
        [~,P,~,STATS] = ttest(dataSet{1}.condition{1}.crossVal(whichModelPair(1)).RMSError, ...
            dataSet{1}.condition{1}.crossVal(whichModelPair(2)).RMSError);
        fprintf('%s Vs %s RMSE: t(%d) = %.2f, p = %.4f, \n', modelCode(whichModelPair(1)), modelCode(whichModelPair(2)), STATS.df, STATS.tstat, P);
    end
end
