% ColorMaterialModelqPlusTestProgram
% Compare the outputs of qPlus and our fitting routine in terms of
% likelihoods of the initial set data set as well as the solution. 

% Initialize
clear; close all; 

% Define relevant directories and load the test case
demoDir = getpref('ColorMaterial', 'demoDataDir'); 
analysisDir = [getpref('ColorMaterial', 'mainCodeDir'), '/analysis'];
cd(demoDir)
filename = 'TESTCASEqpQuestPlusColorMaterialCubicModelDemo';
load(filename)

%% qPlus fitting
%
% Get stim counts
stimCounts = qpCounts(qpData(questDataAllTrials.trialData),questDataAllTrials.nOutcomes);

% Find out QUEST+'s estimate of the stimulus parameters, obtained
% on the gridded parameter domain.
psiParamsIndex = qpListMaxArg(questDataAllTrials.posterior);
psiParamsQuest = questDataAllTrials.psiParamsDomain(psiParamsIndex,:);
fprintf('Simulated parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
    simulatedPsiParams(1),simulatedPsiParams(2),simulatedPsiParams(3),simulatedPsiParams(4), ...
    simulatedPsiParams(5),simulatedPsiParams(6),simulatedPsiParams(7));
fprintf('Log 10 likelihood of data given simulated params: %0.2f\n', ...
    qpLogLikelihood(stimCounts,questDataAllTrials.qpPF,simulatedPsiParams)/log(10));
fprintf('Max posterior QUEST+ parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
    psiParamsQuest(1),psiParamsQuest(2),psiParamsQuest(3),psiParamsQuest(4), ...
    psiParamsQuest(5),psiParamsQuest(6),psiParamsQuest(7));
fprintf('Log 10 likelihood of data quest''s max posterior params: %0.2f\n', ...
    qpLogLikelihood(stimCounts,questDataAllTrials.qpPF, psiParamsQuest)/log(10));

% Maximum likelihood fit.  Use psiParams from QUEST+ as the starting
% parameter for the search, and impose as parameter bounds the range
% provided to QUEST+.
psiParamsFit = qpFit(questDataAllTrials.trialData,questDataAllTrials.qpPF,psiParamsQuest(:),questDataAllTrials.nOutcomes,...
    'lowerBounds', [1/upperLin -upperQuad -upperCubic 1/upperLin -upperQuad -upperCubic 0], ...
    'upperBounds',[upperLin upperQuad upperCubic upperLin upperQuad upperCubic 1]);
fprintf('Maximum likelihood fit parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
    psiParamsFit(1),psiParamsFit(2),psiParamsFit(3),psiParamsFit(4), ...
    psiParamsFit(5),psiParamsFit(6),psiParamsFit(7));
fprintf('Log 10 likelihood of data fit max likelihood params: %0.2f\n', ...
    qpLogLikelihood(stimCounts,questDataAllTrials.qpPF, psiParamsFit)/log(10));
fprintf('\n');

%% Color material model fit. 
%
% Set up some params
%
% Here we use the example structure that matches the experimental design of
% our initial experiments.
cd(analysisDir)
params = getqPlusPilotExpParams;
params.whichDistance = 'euclidean'; 
params.interpCode = 'Cubic';
% Set up initial modeling paramters (add on)
params = getqPlusPilotModelingParams(params);

% Set up more modeling parameters
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'full';
params.smoothOrder = 3; 

% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% setIndices for concatinating trial data
indices.stimPairs = 1:4; 
indices.response1 = 5; 
indices.nTrials = 6; 

% load the data set and assign to a variable that works with
% the main fitting code.
warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
thisTempSet = load([demoDir '/' filename]);
warning(warnState);

% get the quest plus data and massage format
thisSet.trialData = [];
for t = 1:length(thisTempSet.questDataAllTrials.trialData)
    thisSet.trialData = [thisSet.trialData; ...
        thisTempSet.questDataAllTrials.trialData(t).stim, thisTempSet.questDataAllTrials.trialData(t).outcome];
end
clear thisTempSet;


% compute likelihood on a unconcatenated version of what quest kicks out
fprintf('Get likelihood of an unconcatenated version. \n');
thisSet.pairColorMatchColorCoords = thisSet.trialData(:,1);
thisSet.pairMaterialMatchColorCoords = thisSet.trialData(:,2);
thisSet.pairColorMatchMaterialCoords = thisSet.trialData(:,3);
thisSet.pairMaterialMatchMaterialCoords = thisSet.trialData(:,4);
thisSet.firstChosen = thisSet.trialData(:,5) == 1;
thisSet.newNTrials = ones(size(thisSet.firstChosen));
thisSet.pFirstChosen = thisSet.firstChosen./thisSet.newNTrials;
[thisSet.initialLogLikely, thisSet.predictedResponses] = ...
    ColorMaterialModelComputeLogLikelihood(...
    simulatedPsiParams(1)*thisSet.pairColorMatchColorCoords + simulatedPsiParams(2)*thisSet.pairColorMatchColorCoords.^2+ simulatedPsiParams(3)*thisSet.pairColorMatchColorCoords.^3, ...
    simulatedPsiParams(1)*thisSet.pairMaterialMatchColorCoords + simulatedPsiParams(2)*thisSet.pairMaterialMatchColorCoords.^2+simulatedPsiParams(3)*thisSet.pairMaterialMatchColorCoords.^3,...
    simulatedPsiParams(4)*thisSet.pairColorMatchMaterialCoords + simulatedPsiParams(5)*thisSet.pairColorMatchMaterialCoords.^2 + simulatedPsiParams(6)*thisSet.pairColorMatchMaterialCoords.^3, ...
    simulatedPsiParams(4)*thisSet.pairMaterialMatchMaterialCoords + simulatedPsiParams(5)*thisSet.pairMaterialMatchMaterialCoords.^2 +simulatedPsiParams(6)*thisSet.pairMaterialMatchMaterialCoords.^3,...
    thisSet.firstChosen, thisSet.newNTrials, ...
    0, 0, ...
    simulatedPsiParams(7), 1, 'whichMethod', params.whichMethod, 'Fobj', params.F);
fprintf('Main fitting log 10 likelihood of data given simulated params, trial-by-trial data: %0.2f\n', ...
    thisSet.initialLogLikely);

fprintf('Get likelihood of an concatenated version. \n');
% concatenate across blocks
thisSet.rawTrialData = thisSet.trialData;
thisSet.newTrialData = qPlusConcatenateRawData(thisSet.rawTrialData, indices);

% Convert the information about pairs to 'our prefered representation'
thisSet.pairColorMatchColorCoords = thisSet.newTrialData(:,1);
thisSet.pairMaterialMatchColorCoords = thisSet.newTrialData(:,2);
thisSet.pairColorMatchMaterialCoords = thisSet.newTrialData(:,3);
thisSet.pairMaterialMatchMaterialCoords = thisSet.newTrialData(:,4);
thisSet.firstChosen = thisSet.newTrialData(:,5);
thisSet.newNTrials = thisSet.newTrialData(:,6);
thisSet.pFirstChosen = thisSet.firstChosen./thisSet.newNTrials;

% Get the parameters that were simulated
[thisSet.initialLogLikely, thisSet.predictedResponses] = ...
    ColorMaterialModelComputeLogLikelihood(...
    simulatedPsiParams(1)*thisSet.pairColorMatchColorCoords + simulatedPsiParams(2)*thisSet.pairColorMatchColorCoords.^2+ simulatedPsiParams(3)*thisSet.pairColorMatchColorCoords.^3, ...
    simulatedPsiParams(1)*thisSet.pairMaterialMatchColorCoords + simulatedPsiParams(2)*thisSet.pairMaterialMatchColorCoords.^2+simulatedPsiParams(3)*thisSet.pairMaterialMatchColorCoords.^3,...
    simulatedPsiParams(4)*thisSet.pairColorMatchMaterialCoords + simulatedPsiParams(5)*thisSet.pairColorMatchMaterialCoords.^2 + simulatedPsiParams(6)*thisSet.pairColorMatchMaterialCoords.^3, ...
    simulatedPsiParams(4)*thisSet.pairMaterialMatchMaterialCoords + simulatedPsiParams(5)*thisSet.pairMaterialMatchMaterialCoords.^2 +simulatedPsiParams(6)*thisSet.pairMaterialMatchMaterialCoords.^3,...
    thisSet.firstChosen, thisSet.newNTrials, ...
    0, 0, ...
    simulatedPsiParams(7), 1, 'whichMethod', params.whichMethod, 'Fobj', params.F);
fprintf('Main fitting log 10 likelihood of data given simulated params: %0.2f\n', ...
    thisSet.initialLogLikely);

% Model
[thisSet.returnedParams, thisSet.logLikelyFit, thisSet.predictedProbabilitiesBasedOnSolution] =  FitColorMaterialModelMLDS(thisSet.pairColorMatchColorCoords, ...
    thisSet.pairMaterialMatchColorCoords,...
    thisSet.pairColorMatchMaterialCoords, ...
    thisSet.pairMaterialMatchMaterialCoords,...
    thisSet.firstChosen, thisSet.newNTrials, params);

% extract parameters
[thisSet.returnedMaterialMatchColorCoords, thisSet.returnedColorMatchMaterialCoords, ...
    thisSet.returnedW, thisSet.returnedSigma]  = ColorMaterialModelXToParams(thisSet.returnedParams, params);
fprintf('Log 10 likelihood of data fit our model: %0.2f\n', ...
    thisSet.logLikelyFit);
