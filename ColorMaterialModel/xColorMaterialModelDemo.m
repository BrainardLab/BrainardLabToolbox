% ColorMaterialModelDemoGeneralize
%
% Demonstrates color material MLDS model fitting procedure for a data set.
% Initially used as a test bed for testing and improving search algorithm.
%
% The work is done by other routines in this folder.
%
% Requires optimization toolbox.
%
% 11/18/16  ar  Wrote from color selection model version
% 01/xx/17  ar  Modified it for the Generalize code branch
% 02/17/17  ar  Streamline and organize

%% Initialize and set directories and some plotting params.
clear; close all;
currentDir = pwd;
figDir = ['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots'];
saveFig = 0;
weibullplots = 0;

%% Load structure giving experiment design parameters.
% Here we use the example structure that mathes the experimental design of
% our initial experiments.
load('ColorMaterialExampleStructure.mat')

%% Set parameters for probability computation
params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
params.nSimulate = 1000; % for method 'simulate'
lookupTable = 'cubic';
params.whichDistance = 'euclidean'; % define distance for the model and simulated data. 
nBlocks = 24;

% Load lookup table
switch lookupTable
    case  'linear'
        load colorMaterialInterpolateFunctionLinear.mat
        colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
        interpCode = 'L';
    case 'cubic'
        load colorMaterialInterpolateFunctionCubic.mat
        colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
        interpCode = 'C';
end
params.F = colorMaterialInterpolatorFunction; % for lookup.


%% Other parameters
% After iniatial parameters are imported we need to specify the following info
% and add it to the params structure
%
% Initial material and color positions.  If we don't at some point muck
% with the example structure, these go from -3 to 3 in steps of 1 for a
% total of 7 stimuli arrayed along each dimension.
params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);

% What sort of position fitting are we doing, and if smooth the order of the polynomial.
% Options:
%  'full' - Weights vary
%  'smoothSpacing' - Weights computed according to a polynomial fit.
params.whichPositions = 'smoothSpacing';
params.smoothOrder = 3; % this option is only for smoothSpacing

% Initial position spacing values to try.
params.trySpacingValues = [0.5 1 2];
params.maxPositionValue = 20;
% Does material/color weight vary in fit?
%  'weightVary' - yes, it does.
%  'weightFixed' - fix weight to specified value in tryWeightValues(1);
params.whichWeight = 'weightFixed';
tryWeightValues = [0.5 0.2 0.8];
params.addNoise = true;
% Make a stimulus list and set underlying parameters.
targetMaterialCoord = 0;
targetColorCoord = 0;
stimuliMaterialMatch = [];
stimuliColorMatch = [];
sigma = 1;
scalePositions = 2; % scaling factor for input positions (we can try different ones to match our noise i.e. sigma of 1).
w = 0.5;

params.scalePositions  = scalePositions;
NONLINEAR = 1; % flag - should we have non-lin position spacing or not. 
if NONLINEAR
    params.materialMatchColorCoords = [-5 -1 -0.5 0 2.3 2.5 3]; %scalePositions*params.materialMatchColorCoords;
    params.colorMatchMaterialCoords = [-6.4 -5 -3 0 0.1 0.8 4.9]; %scalePositions*params.colorMatchMaterialCoords;
else
    params.materialMatchColorCoords = scalePositions*params.materialMatchColorCoords;
    params.colorMatchMaterialCoords = scalePositions*params.colorMatchMaterialCoords;
end

% Parameters for structufing pairs.
colorCoordIndex = 1;
materialCoordIndex = 2;
colorMatchIndexInPair = 1;
materialMatchIndexInPair = 2;

%% We can use simulated data (DEMO == true) or some real data (DEMO == false)
% Make the random number generator seed start at the same place each
% time we do this.
rng('default');
params.conditionCode = 'demo';

%% This part of the code creates pairs.
% These are the coordinates of the color matches.  The color coordinate always matches the
% target and the matrial coordinate varies.
for i = 1:length(params.colorMatchMaterialCoords)
    stimuliColorMatch = [stimuliColorMatch, {[targetColorCoord, params.colorMatchMaterialCoords(i)]}];
end

% These are the coordinates of the material matches.  The color
% coordinate varies and the material coordinate always matches the
% target.
for i = 1:length(params.materialMatchColorCoords)
    stimuliMaterialMatch = [stimuliMaterialMatch, {[params.materialMatchColorCoords(i), targetMaterialCoord]}];
end
pair = [];

% Loop over blocks and stimulus pairs and simulate responses
% We pair each color-difference stimulus with each material-difference stimulus
n = 0;
matIndex = [];
colIndex = [];
overallColorMaterialPairIndices = [];
rowIndex = [];
columnIndex = [];
clear rowIndex columnIndex overallIndex
for whichColorOfTheMaterialMatch = 1:length(params.materialMatchColorCoords)
    for whichMaterialOfTheColorMatch = 1:length(params.colorMatchMaterialCoords)
        rowIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = [whichColorOfTheMaterialMatch];
        columnIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = [whichMaterialOfTheColorMatch];
        n = n + 1;
        overallColorMaterialPairIndices(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = n;
        
        % The pair is a cell array containing two vectors.  The
        % first vector is the coordinates of the color match, the
        % second is the coordinates of the material match.  There
        % is one such pair for each trial type.
        pair = [pair; ...
            {stimuliColorMatch{whichMaterialOfTheColorMatch}, ...
            stimuliMaterialMatch{whichColorOfTheMaterialMatch} }];
        if whichMaterialOfTheColorMatch == 4
            matIndex = [matIndex, n];
        end
        if whichColorOfTheMaterialMatch == 4
            colIndex = [colIndex, n];
        end
    end
end

% Within color category (so material cooredinate == target material coord)
withinCategoryPairsColor  =  nchoosek(setdiff(1:length(params.materialMatchColorCoords), params.targetIndex),2);

for whichWithinColorPair = 1:size(withinCategoryPairsColor,1)
    if whichWithinColorPair ~= 4
        n = n+1;
        pair = [pair; ...
            {[params.materialMatchColorCoords(withinCategoryPairsColor(whichWithinColorPair, 1)), targetMaterialCoord]}, ...
            {[params.materialMatchColorCoords(withinCategoryPairsColor(whichWithinColorPair, 2)), targetMaterialCoord]}];
        colIndex = [colIndex, n];
    end
end

% Within material category (so color cooredinate == target color coord)
withinCategoryPairsMaterial  =  nchoosek(setdiff(1:length(params.colorMatchMaterialCoords), params.targetIndex),2);
for whichWithinMaterialPair = 1:size(withinCategoryPairsMaterial,1)
    n = n+1;
    pair = [pair; ...
        {[targetColorCoord, params.colorMatchMaterialCoords(withinCategoryPairsMaterial(whichWithinMaterialPair, 1))]}, ...
        {[targetColorCoord, params.colorMatchMaterialCoords(withinCategoryPairsMaterial(whichWithinMaterialPair, 2))]}];
    matIndex = [matIndex, n];
end
overallColorMaterialPairIndices = overallColorMaterialPairIndices(:);
rowIndex = rowIndex(:);
columnIndex = columnIndex(:);
nPairs = size(pair,1);

params.subjectName = ['demo' interpCode num2str(nBlocks) 'Scale' num2str(scalePositions) 'demoVary' num2str(w)];
params.tryWeightValues = tryWeightValues;

% Simulate out  what the response is for this pair in this
% block.
%
% Note that the first competitor passed is always a color
% match that differs in material. so the response1 == 1
% means that the color match was chosen
responsesFromSimulatedData  = zeros(nPairs,1);
for b = 1:nBlocks
    responsesForOneBlock = zeros(nPairs,1);
    for whichPair = 1:nPairs
        
        % Get the color and material coordiantes for each member of
        % this pair.
        pairColorMatchColorCoords(whichPair) = pair{whichPair, 1}(colorCoordIndex);
        pairMaterialMatchColorCoords(whichPair) = pair{whichPair, 2}(colorCoordIndex);
        pairColorMatchMaterialCoords(whichPair) = pair{whichPair, 1}(materialCoordIndex);
        pairMaterialMatchMaterialCoords(whichPair) = pair{whichPair, 2}(materialCoordIndex);
        
        % Simulate one response.
        responsesForOneBlock(whichPair) = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, ...
            pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
            pairColorMatchMaterialCoords(whichPair), pairMaterialMatchMaterialCoords(whichPair), w, sigma, ...
            'addNoiseToTarget', params.addNoise, 'whichDistance', params.whichDistance);
    end
    responsesAcrossBlocks(:, b) = responsesForOneBlock; 
    % Track cummulative response over blocks
    responsesFromSimulatedData = responsesFromSimulatedData+responsesForOneBlock;
end
if NONLINEAR
    save(['demoSimulatedDataNonLin-' date])
else
    save(['demoSimulatedData-' date])
end
clear probabilitiesFromSimulatedData
% Compute response probabilities for each pair, just divide by nBlocks
probabilitiesFromSimulatedData = responsesFromSimulatedData ./ nBlocks;

% Use identical loop to compute probabilities, based on our analytic
% function.  These ought to be close to the simulated probabilities.
% This mainly serves as a check that our analytic function works
% correctly.  Note that analytic is a bit too strong, there is some
% numerical integration and approximation involved.
probabilitiesForActualPositions = zeros(nPairs,1);
for whichPair = 1:nPairs
    switch params.whichMethod
        case 'lookup'
            probabilitiesForActualPositions(whichPair) = colorMaterialInterpolatorFunction(pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
                pairColorMatchMaterialCoords(whichPair) , pairMaterialMatchMaterialCoords(whichPair), w);
        case 'analytic'
            probabilitiesComputedForSimulatedData(whichPair) = ColorMaterialModelComputeProb(targetColorCoord, targetMaterialCoord, ...
                pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
                pairColorMatchMaterialCoords(whichPair) , pairMaterialMatchMaterialCoords(whichPair), w, sigma);
        otherwise
            error('This method is not implemented here.')
    end
end
clear nTrials
nTrials = nBlocks*ones(size(responsesFromSimulatedData));

[logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
    responsesFromSimulatedData, nTrials,...
    params.materialMatchColorCoords(params.targetIndex), params.colorMatchMaterialCoords(params.targetIndex), ...
    w,sigma,'Fobj', colorMaterialInterpolatorFunction, 'whichMethod', 'lookup');
fprintf('True position log likelihood %0.2f.\n', logLikely);
clear logLikely predictedResponses

%% Fit the data and extract parameters and other useful things from the solution
%
% We put the method into the params structure, so it flows to where we need
% it.  This isn't beautiful, but saves us figuring out how to pass the
% various key value pairs all the way down into the functions called by
% fmincon, which is actually somewhat hard to do in a more elegant way.
clear returnedParams logLikelyFit predictedProbabilitiesBasedOnSolution k returnedMaterialMatchColorCoords
clear returnedColorMatchMaterialCoords returnedW returnedSigma
[returnedParams, logLikelyFit, predictedProbabilitiesBasedOnSolution, k] = FitColorMaterialModelMLDS(...
    pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
    responsesFromSimulatedData,nTrials,params, ...
    'whichPositions',params.whichPositions,'whichWeight',params.whichWeight, ...
    'tryWeightValues',params.tryWeightValues,'trySpacingValues',params.trySpacingValues, 'maxPositionValue', params.maxPositionValue); %#ok<SAGROW>
saveRetParams = returnedParams;
[returnedMaterialMatchColorCoords,returnedColorMatchMaterialCoords,returnedW,returnedSigma]  = ColorMaterialModelXToParams(returnedParams, params);
fprintf('Returned weight: %0.2f.\n', returnedW);
fprintf('Log likelyhood of the solution: %0.2f.\n', logLikelyFit);

%% Plot the solution
% Reformat probabilities to look only at color/material tradeoff
clear resizedDataProb resizedSolutionProb resizedProbabilitiesForActualPositions
for i = 1:length(rowIndex)
    resizedDataProb(rowIndex((i)), columnIndex((i))) = probabilitiesFromSimulatedData(overallColorMaterialPairIndices(i));
    resizedSolutionProb(rowIndex((i)), columnIndex((i))) = predictedProbabilitiesBasedOnSolution(overallColorMaterialPairIndices(i));
    resizedProbabilitiesForActualPositions(rowIndex((i)), columnIndex((i))) = probabilitiesForActualPositions(overallColorMaterialPairIndices(i));
end

% compute RMSEs
rmse= ComputeRealRMSE(probabilitiesFromSimulatedData, predictedProbabilitiesBasedOnSolution);

ColorMaterialModelPlotSolution(probabilitiesFromSimulatedData,predictedProbabilitiesBasedOnSolution, ...
    resizedDataProb, resizedSolutionProb, ...
    returnedParams, params, params.subjectName, params.conditionCode, figDir, ...
    saveFig, weibullplots,probabilitiesForActualPositions, resizedProbabilitiesForActualPositions);