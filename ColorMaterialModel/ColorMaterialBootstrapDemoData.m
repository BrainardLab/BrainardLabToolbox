% ColorMaterialModelBootstrapDemoData
% Perform bootstraping to find confidence intervals for model paramters.
%
% 04/30/2017 ar Wrote it from cross-validation code. 
% 04/30/2017 ar Added comments.

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
nConditions = 1; 
nModelTypes = 1; 

CIrange = 95; 
CIlo = (1-CIrange/100)/2; 
CIhi = 1-CIlo; 

for whichCondition = 1:nConditions
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
        
        for whichModelType = 1:nModelTypes
            if whichModelType == 1
                params.whichWeight = whichWeight;
                params.whichPositions = 'full';
                params.tryColorSpacingValues = [params.trySpacingValues];
                params.tryMaterialSpacingValues = [params.trySpacingValues];
                params.tryWeightValues = [params.tryWeightValues];
            else
                error('Model type not implemented. ')
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
    
    cd(mainDir);
    save(['demo' params.whichWeight '-Bootstrap'],  'thisSubject');
end
