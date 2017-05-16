% ColorMaterialModelGenerateDemoData
%
% Simulate a set of demo data for color-material study. 
%
% 11/18/16  ar  Pulled from the model demo code. 

%% Initialize and set directories and some plotting params.
clear; close all;
currentDir = pwd;

%% Set relevant preferences
%setpref('ColorMaterialModel','demoDataDir','/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/');
setpref('ColorMaterialModel','demoDataDir','/Users/dhb/Documents/Matlab/toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/');

%% Explicitely state all underlying parameters that we need to generate/fit the data. 
params.targetIndex = 4; 
params.competitorsRangePositive = [1 3]; 
params.competitorsRangeNegative = [-3 -1]; 
params.targetMaterialCoord = 0;
params.targetColorCoord = 0;
params.sigma = 1; 
params.sigmaFactor = 4; 
params.targetPosition = 0; 
params.targetIndexColor =  11; 
params.targetIndexMaterial = 4; 
params.scalePositions  = 2;

%% This lets us only generate stimuli that vary along the color dimension
params.colorStimOnly = true;

% Initial material and color positions.  If we don't at some point muck
% with the example structure, these go from -3 to 3 in steps of 1 for a
% total of 7 stimuli arrayed along each dimension.
params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.materialMatchColorCoords = params.scalePositions*params.materialMatchColorCoords;
params.colorMatchMaterialCoords = params.scalePositions*params.colorMatchMaterialCoords;
params.numberOfMaterialCompetitors = length(params.colorMatchMaterialCoords); 
params.numberOfColorCompetitors = length(params.materialMatchColorCoords); 
params.numberOfCompetitorsPositive = length(params.competitorsRangePositive(1):params.competitorsRangePositive(end)); 
params.numberOfCompetitorsNegative = length(params.competitorsRangeNegative(1):params.competitorsRangeNegative(end)); 

% Parameters for structuring pairs.
params.colorCoordIndex = 1;
params.materialCoordIndex = 2;
params.colorMatchIndexInPair = 1;
params.materialMatchIndexInPair = 2;

% Load lookup table
load colorMaterialInterpolateFunctionCubic.mat
params.F = colorMaterialInterpolatorFunction; % for lookup.
params.conditionCode = 'demo'; 
params.addNoise = true;
params.whichDistance = 'euclidean';

% Set up parameters for this particular data set. 
fprintf('Set up parameters for simulation \n'); 
params.seedFixed = GetWithDefault('Fix random seed?',0); % Fix random seed or not. 
nBlocks = GetWithDefault('How many blocks of trials?',24); % Set the number of blocks of trials in an experiment.
params.w = GetWithDefault('Set underlying weigth: ',0.5);  % Set up the underlying weight for simulation
nDataSets = GetWithDefault('How many data sets to simulate?',1); 


%% Create pairs.
stimuliMaterialMatch = [];
stimuliColorMatch = [];

% These are the coordinates of the color matches.  The color coordinate always matches the
% target and the matrial coordinate varies.
for i = 1:length(params.colorMatchMaterialCoords)
    stimuliColorMatch = [stimuliColorMatch, {[params.targetColorCoord, params.colorMatchMaterialCoords(i)]}];
end

% These are the coordinates of the material matches.  The color
% coordinate varies and the material coordinate always matches the
% target.
for i = 1:length(params.materialMatchColorCoords)
    stimuliMaterialMatch = [stimuliMaterialMatch, {[params.materialMatchColorCoords(i), params.targetMaterialCoord]}];
end
pair = [];

% Initialize info about pairs
n = 0;
materialIndex = [];
colorIndex = [];
columnIndex = [];
rowIndex = [];
overallColorMaterialPairIndices = [];

% We pair each color-difference stimulus with each material-difference
% stimulus, unless we are only doing the color-vary stimuli.
if (~params.colorStimOnly)
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
                materialIndex = [materialIndex, n];
            end
            if whichColorOfTheMaterialMatch == 4
                colorIndex = [colorIndex, n];
            end
        end
    end
end

% Within color category (so material cooredinate == target material coord)
if (params.colorStimOnly)
    withinCategoryPairsColor  =  nchoosek(1:length(params.materialMatchColorCoords),2);
else
    withinCategoryPairsColor  =  nchoosek(setdiff(1:length(params.materialMatchColorCoords), params.targetIndex),2);
end
for whichWithinColorPair = 1:size(withinCategoryPairsColor,1)
    if (whichWithinColorPair ~= 4 | params.colorStimOnly)
        n = n+1;
        pair = [pair; ...
            {[params.materialMatchColorCoords(withinCategoryPairsColor(whichWithinColorPair, 1)), targetMaterialCoord]}, ...
            {[params.materialMatchColorCoords(withinCategoryPairsColor(whichWithinColorPair, 2)), targetMaterialCoord]}];
        colorIndex = [colorIndex, n];
    end
end

% Within material category (so color cooredinate == target color coord)
%if (~params.colorStimOnly)
    withinCategoryPairsMaterial  =  nchoosek(setdiff(1:length(params.colorMatchMaterialCoords), params.targetIndex),2);
    for whichWithinMaterialPair = 1:size(withinCategoryPairsMaterial,1)
        n = n+1;
        pair = [pair; ...
            {[targetColorCoord, params.colorMatchMaterialCoords(withinCategoryPairsMaterial(whichWithinMaterialPair, 1))]}, ...
            {[targetColorCoord, params.colorMatchMaterialCoords(withinCategoryPairsMaterial(whichWithinMaterialPair, 2))]}];
        materialIndex = [materialIndex, n];
    end
%end

% Update bookkeeping
overallColorMaterialPairIndices = overallColorMaterialPairIndices(:);
rowIndex = rowIndex(:);
columnIndex = columnIndex(:);
nPairs = size(pair,1);

% Simulate out what the response is for this pair in this
% block.
%
% Note that the first competitor passed is always a color
% match that differs in material. so the response1 == 1
% means that the color match was chosen

% Initialize the counter
for whichSet = 1:nDataSets
    if ~ params.seedFixed
    else
        rng('default');
    end
    dataSet{whichSet}.responsesFromSimulatedData  = zeros(nPairs,1);
    for b = 1:nBlocks
        dataSet{whichSet}.responsesForOneBlock = zeros(nPairs,1);
        for whichPair = 1:nPairs
            
            % Get the color and material coordiantes for each member of
            % this pair.
            pairColorMatchColorCoords(whichPair) = pair{whichPair, 1}(params.colorCoordIndex);
            pairMaterialMatchColorCoords(whichPair) = pair{whichPair, 2}(params.colorCoordIndex);
            pairColorMatchMaterialCoords(whichPair) = pair{whichPair, 1}(params.materialCoordIndex);
            pairMaterialMatchMaterialCoords(whichPair) = pair{whichPair, 2}(params.materialCoordIndex);
            
            % Simulate one response.
            dataSet{whichSet}.responsesForOneBlock(whichPair) = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, ...
                pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
                pairColorMatchMaterialCoords(whichPair), pairMaterialMatchMaterialCoords(whichPair), params.w, params.sigma, ...
                'addNoiseToTarget', params.addNoise, 'whichDistance', params.whichDistance);
        end
        
        % Track cummulative response over blocks
        dataSet{whichSet}.responsesFromSimulatedData = dataSet{whichSet}.responsesFromSimulatedData + dataSet{whichSet}.responsesForOneBlock;
        dataSet{whichSet}.responsesAcrossBlocks(:,b) = dataSet{whichSet}.responsesForOneBlock; 
    
    end
    
    dataSet{whichSet}.probabilitiesFromSimulatedData = dataSet{whichSet}.responsesFromSimulatedData./nBlocks;
    % Use identical loop to compute probabilities, based on our analytic
    % function.  These ought to be close to the simulated probabilities.
    % This mainly serves as a check that our analytic function works
    % correctly.  Note that analytic is a bit too strong, there is some
    % numerical integration and approximation involved.
    dataSet{whichSet}.probabilitiesForActualPositions = zeros(nPairs,1);
    for whichPair = 1:nPairs
        dataSet{whichSet}.probabilitiesForActualPositions(whichPair) = colorMaterialInterpolatorFunction(pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
            pairColorMatchMaterialCoords(whichPair) , pairMaterialMatchMaterialCoords(whichPair), params.w);
    end
    dataSet{whichSet}.rmseSimulatedVsComputedProbabilities = ComputeRealRMSE(dataSet{whichSet}.probabilitiesForActualPositions,...
            dataSet{whichSet}.probabilitiesFromSimulatedData);
end
curDir = pwd;
cd(getpref('ColorMaterialModel','demoDataDir'));
if (params.colorStimOnly)
    save(['DemoData' num2str(params.w) 'W' num2str(nBlocks) 'Blocks' num2str(nDataSets) 'LinColorOnly.mat']);
else
    save(['DemoData' num2str(params.w) 'W' num2str(nBlocks) 'Blocks' num2str(nDataSets) 'Lin.mat']);
end
cd(curDir);
