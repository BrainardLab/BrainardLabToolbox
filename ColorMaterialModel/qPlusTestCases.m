

% Initialize
clear; close all; 

% Define relevant directories and load the test case
demoDir = getpref('ColorMaterial', 'demoDataDir'); 
analysisDir = [getpref('ColorMaterial', 'mainCodeDir'), '/analysis'];
cd(demoDir)
filename = 'TESTCASEqpQuestPlusColorMaterialCubicModelDemo';
load(filename)

%qPlus fitting
% Get stim counts
stimCounts = qpCounts(qpData(questDataAllTrials.trialData),questDataAllTrials.nOutcomes);

% Find out QUEST+'s estimate of the stimulus parameters, obtained
% on the gridded parameter domain.
psiParamsIndex = qpListMaxArg(questDataAllTrials.posterior);
psiParamsQuest(ss,:) = questDataAllTrials.psiParamsDomain(psiParamsIndex,:);
fprintf('Simulated parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
    simulatedPsiParams(1),simulatedPsiParams(2),simulatedPsiParams(3),simulatedPsiParams(4), ...
    simulatedPsiParams(5),simulatedPsiParams(6),simulatedPsiParams(7));
fprintf('Log likelihood of data given simulated params: %0.2f\n', ...
    -qpLogLikelihood(stimCounts,questDataAllTrials.qpPF,simulatedPsiParams));
fprintf('Max posterior QUEST+ parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
    psiParamsQuest(ss,1),psiParamsQuest(ss,2),psiParamsQuest(ss,3),psiParamsQuest(ss,4), ...
    psiParamsQuest(ss,5),psiParamsQuest(ss,6),psiParamsQuest(ss,7));
fprintf('Log likelihood of data max posterior params: %0.4f\n', ...
    -qpLogLikelihood(stimCounts,questDataAllTrials.qpPF, psiParamsQuest));

% Maximum likelihood fit.  Use psiParams from QUEST+ as the starting
% parameter for the search, and impose as parameter bounds the range
% provided to QUEST+.
psiParamsFit(ss,:) = qpFit(questDataAllTrials.trialData,questDataAllTrials.qpPF,psiParamsQuest(ss,:),questDataAllTrials.nOutcomes,...
    'lowerBounds', [1/upperLin -upperQuad -upperCubic 1/upperLin -upperQuad -upperCubic 0], ...
    'upperBounds',[upperLin upperQuad upperCubic upperLin upperQuad upperCubic 1]);
fprintf('Maximum likelihood fit parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
    psiParamsFit(ss,1),psiParamsFit(ss,2),psiParamsFit(ss,3),psiParamsFit(ss,4), ...
    psiParamsFit(ss,5),psiParamsFit(ss,6),psiParamsFit(ss,7));
fprintf('Log likelihood of data max likelihood params: %0.4f\n', ...
    -qpLogLikelihood(stimCounts,questDataAllTrials.qpPF, psiParamsFit));
fprintf('\n');

% Color material model fit. 

% Set params

% Set up some params
% Here we use the example structure that matches the experimental design of
% our initial experiments.
cd(analysisDir)

params = getqPlusPilotExpParams;

% Set up initial modeling paramters (add on)
params = getqPlusPilotModelingParams(params);

% Set up more modeling parameters
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'smoothSpacing';
params.smoothOrder = 3; 

% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% setIndices for concatinating trial data
indices.stimPairs = 1:4; 
indices.response1 = 5; 
indices.nTrials = 6; 

% load the data set
warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
thisTempSet = load([demoDir '/' filename]);
%thisSet = thisTempSet.questDataAllTrials;
warning(warnState);
thisSet.trialData = [];
for t = 1:length(thisTempSet.questDataAllTrials.trialData)
    thisSet.trialData = [thisSet.trialData; ...
        thisTempSet.questDataAllTrials.trialData(t).stim, thisTempSet.questDataAllTrials.trialData(t).outcome];
end
clear thisTempSet;
% concatenate across blocks
thisSet.nTrials = size(thisSet.trialData);
thisSet.rawTrialData = thisSet.trialData;
thisSet.newTrialData = qPlusConcatenateRawData(thisSet.rawTrialData, indices);

% Convert the information about pairs to 'our prefered representation'
thisSet.pairColorMatchColorCoords = thisSet.newTrialData(:,1);
thisSet.pairMaterialMatchColorCoords = thisSet.newTrialData(:,3);
thisSet.pairColorMatchMaterialCoords = thisSet.newTrialData(:,2);
thisSet.pairMaterialMatchMaterialCoords = thisSet.newTrialData(:,4);
thisSet.firstChosen = thisSet.newTrialData(:,5);
thisSet.newNTrials = thisSet.newTrialData(:,6);
thisSet.pFirstChosen = thisSet.firstChosen./thisSet.newNTrials;

[a, b, c, d] = ColorMaterialModelXToParams([simulatedPsiParams, 1], params);

[thisSet.initialLogLikely, thisSet.predictedResponses] = ...
    ColorMaterialModelComputeLogLikelihood(thisSet.pairColorMatchColorCoords, ...
    thisSet.pairMaterialMatchColorCoords,...
    thisSet.pairColorMatchMaterialCoords, ...
    thisSet.pairMaterialMatchMaterialCoords,...
    thisSet.firstChosen, thisSet.newNTrials, ...
    a(params.targetIndex), b(params.targetIndex), ...
    c, d, 'whichMethod', params.whichMethod, 'Fobj', params.F);

%model
[thisSet.returnedParams, thisSet.logLikelyFit, thisSet.predictedProbabilitiesBasedOnSolution] = ...
    FitColorMaterialModelMLDS(thisSet.pairColorMatchColorCoords, ...
    thisSet.pairMaterialMatchColorCoords,...
    thisSet.pairColorMatchMaterialCoords, ...
    thisSet.pairMaterialMatchMaterialCoords,...
    thisSet.firstChosen, thisSet.newNTrials, params);

% extract parameters
[thisSet.returnedMaterialMatchColorCoords, thisSet.returnedColorMatchMaterialCoords, ...
    thisSet.returnedW, thisSet.returnedSigma]  = ColorMaterialModelXToParams(thisSet.returnedParams, params);
