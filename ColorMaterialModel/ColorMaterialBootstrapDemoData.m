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
mainDir = '/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots';

cd('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData')
load('DemoData0.25W24Blocks1Lin.mat'); % data
nTrials = nBlocks*ones(size(dataSet{1}.responsesForOneBlock));
nTrials = nTrials(1);
params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
params.nSimulate = 1000; % for method 'simulate'
params.whichDistance = 'euclidean';

params.F = colorMaterialInterpolatorFunction;
params.trySpacingValues = [0.5 1 2 3];
params.tryWeightValues = [0.5 0.2 0.8];

params.maxPositionValue = 20;
params.whichMethod = 'lookup';
params.nSimulate = 1000;
whichWeight = 'weightVary';
nRepetitions = 150; 
for whichCondition = 1%:nConditions
    for kk = 1:nRepetitions
        
        % Separate the training from test data
        nTrialTypes = size(dataSet{1}.responsesAcrossBlocks,1);
        if (size(dataSet{1}.responsesAcrossBlocks,2) ~= nBlocks)
            error('Oops');
        end
        bootstrapData = zeros(nTrialTypes,1);
        for bb = 1:nTrialTypes
            id = randi(nBlocks,[nBlocks 1]);
            bootstrapData(bb) = sum(dataSet{1}.responsesAcrossBlocks(bb,id));
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
        end
    end
    
%     % Compute mean error for both log likelihood and rmse.
%     thisSubject.condition{whichCondition}.crossVal(whichModelType).meanRMSError = ...
%         ;
%     thisSubject.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood = ...
%         mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).LogLikelyhood);
    
      % Save in the right folder.
        cd(mainDir);
        save(['demo' params.whichWeight '-Bootstrap'],  'thisSubject');
end
