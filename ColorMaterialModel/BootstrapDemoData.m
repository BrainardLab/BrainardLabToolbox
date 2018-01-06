% BootstrapDemoData
%
% Run the model on demo data and implement bootstraping 
% so we can estimate confidence intervals for model paramters. 
%
% 06/19/2017 ar Adapted the previous code: functionalized bootstrapping
%               routine. Cleaned up this script which calls it. Added
%               comments. 

% Initialize
clear; close all;

% Set directories and load the subject data
codeDir = '/Users/radonjic/Documents/MATLAB/toolboxes/BrainardLabToolbox/ColorMaterialModel/';
simulatedDataDir = '/Users/radonjic/Documents/MATLAB/projects/ColorMaterial/SimulatedData/'; 

MAINDEMO = true; 
if MAINDEMO
    dataDir = demoDataDir; 
else
    dataDir = simulatedDataDir;
end

% Set parameters for the simulated data set we're cross-validating.
nBlocks = 24; 
simulatedW = 0.5; 
nDataSets = 1; 

% THERE IS SOME HARDCODING IN THE NAME HERE. Can be changed in the future if needed.
subjectName = ['DemoData' num2str(simulatedW) 'W' num2str(nBlocks) 'Blocks' num2str(nDataSets)]; 
load([dataDir subjectName '.mat']); % data

% Set some parameters for bootstrapping. 
nConditions = 1; % Demo case has just one condition, by default. 
nRepetitions = 1000;
nModelTypes = 1; 
showOutcome = 1; 
params.bootstrapMethod = 'perTrialPerBlock'; 

params.CIrange = 95; % confidence interval range. 
params.CIlo = (1-params.CIrange/100)/2;
params.CIhi = 1-params.CIlo;

%% Standard set of parameters we need to define for the model. 
params.whichMethod = 'lookup'; % options: 'lookup', 'simulate' or 'analytic'
params.whichDistance = 'euclidean'; % options: euclidean, cityblock (or any metric enabled by pdist function). 

% For simulate method, set up how many simulations to use for predicting probabilities.  
if strcmp(params.whichMethod, 'simulate')
    params.nSimulate = 1000;
end
% What sort of position fitting are we doing, and if smooth the order of the polynomial.
% Options:
%  'full' - Weights vary
%  'smoothSpacing' - Weights computed according to a polynomial fit.
params.whichPositions = 'full';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 1; % this option is only for smoothSpacing
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

%% Run the bootstrapping for each data set and condition 
% Leaving an option to enable different models (although for now we just have one model). 
% To introduce other models, we can redefine some of the parameters here. 
for whichDataSet = 1:nDataSets
    for whichModelType = 1:nModelTypes
        for whichCondition = 1:nConditions
            dataSet{nDataSets}.condition{whichCondition}.bootstrap = ....
                ColorMaterialModelBootstrapData(dataSet{nDataSets}.responsesAcrossBlocks, nBlocks, nRepetitions, pairInfo, params)
            for jj = 1:size(dataSet{nDataSets}.condition{whichCondition}.bootstrap.returnedParams,2)
                dataSet{nDataSets}.condition{whichCondition}.bootstrapMeans(jj) = ...
                    mean(dataSet{nDataSets}.condition{whichCondition}.bootstrap.returnedParams(:,jj));
                dataSet{nDataSets}.condition{whichCondition}.bootstrapCI(jj,1) = ...
                    prctile(dataSet{nDataSets}.condition{whichCondition}.bootstrap.returnedParams(:,jj),100*params.CIlo);
                dataSet{nDataSets}.condition{whichCondition}.bootstrapCI(jj,2) = ...
                    prctile(dataSet{nDataSets}.condition{whichCondition}.bootstrap.returnedParams(:,jj),100*params.CIhi);
            end
        end
    end
    
    %% Show results
    if showOutcome
        fprintf('Data Set %d\n', whichDataSet)
        fprintf('Bootstrapped weight %.2f, CI = [%.2f, %.2f] \n', dataSet{nDataSets}.condition{whichCondition}.bootstrapMeans(end-1), ...
            dataSet{nDataSets}.condition{whichCondition}.bootstrapCI(end-1,1),...
            dataSet{nDataSets}.condition{whichCondition}.bootstrapCI(end-1,2));
    end
end
% Save in the right folder.
cd(dataDir)
save([subjectName '-' num2str(nRepetitions) 'BootstrapResults.mat'],  'dataSet');
cd(codeDir)