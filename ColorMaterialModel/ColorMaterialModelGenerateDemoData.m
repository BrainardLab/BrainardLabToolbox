% ColorMaterialModelGenerateDemoData
%
% Simulate a set of demo data for color-material study. 
%
% 11/18/16  ar  Pulled from the model demo code. 

%% Initialize and set directories and some plotting params.
clear; close all;
currentDir = pwd;

%% Set relevant preferences and directories. 
setpref('ColorMaterialModel','demoDataDir','/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/');
%setpref('ColorMaterialModel','demoDataDir','/Users/dhb/Documents/Matlab/toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/');
MAINDEMO = true; % Main demo for the toolbox and larger audience. 
if MAINDEMO
    dataDir = '/Users/ana/Documents/MATLAB/toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData';
else
    dataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots';
end

%% Explicitely state all underlying parameters that we need to generate/fit the data. 
% Experimental parameters (that capture the design of our experiment)
params.targetIndex = 4; % positino of the target (order in the vector) in the competitor space. Note: the target position is the same in both color and material space. 
params.competitorsRangePositive = [1 3]; % number of competitors on the positive end (in case we ever want to change this)
params.competitorsRangeNegative = [-3 -1];  % number of competitors on the negative end (in case we ever want to change this, independent of number on the positive end)
params.targetMaterialCoord = 0; % nominal position of the target within material dimension.  
params.targetColorCoord = 0; % nominal position of the target within  a color dimension. 
params.sigma = 1; % standard deviation. 
params.sigmaFactor = 4; % factor by which we divide the standard deviation to enforce minimal spacing. 

params.targetIndexColor =  11; % target position on the color dimension in the set of all paramters. 
params.targetIndexMaterial = 4; % target position on the material dimension in the set of all paramters. 

% Initial material and color positions.  These go from -3 to 3 in steps of 1 for a
% total of 7 stimuli arrayed along each dimension.
params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
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
load colorMaterialInterpolateFunCubiceuclidean.mat
params.F = colorMaterialInterpolatorFunction; % for lookup.
params.conditionCode = 'demo'; 
params.addNoise = true;
params.whichDistance = 'euclidean';

% Parameters needed for simulation only. 
% Set up parameters for this particular data set. 
fprintf('Set up parameters for simulation \n'); 
params.seedFixed = GetWithDefault('Fix random seed?',0); % Fix random seed or not. 
nBlocks = GetWithDefault('How many blocks of trials?',24); % Set the number of blocks of trials in an experiment.
params.w = GetWithDefault('Set underlying weigth: ',0.5);  % Set up the underlying weight for simulation
nDataSets = GetWithDefault('How many data sets to simulate?',1); 
params.scalePositions  = 2.5; % current simulated spacing. 
params.materialMatchColorCoords = params.scalePositions*params.materialMatchColorCoords;
params.colorMatchMaterialCoords = params.scalePositions*params.colorMatchMaterialCoords;
dataSetName = ['DemoData' num2str(params.w) 'W' num2str(nBlocks) 'Blocks' num2str(nDataSets) 'New.mat']; 
%% Create stimulus pairs (presented at each trial)
stimuliMaterialMatch = [];
stimuliColorMatch = [];
pair = [];
% Initialize info about pairs
n = 0;
% materialIndex = [];
% colorIndex = [];
columnIndex = [];
rowIndex = [];
overallColorMaterialPairIndices = [];

% These are the coordinates of the color matches.  The color coordinate always matches the
% target and the material coordinate varies.
for i = 1:length(params.colorMatchMaterialCoords)
    stimuliColorMatch = [stimuliColorMatch, {[params.targetColorCoord, params.colorMatchMaterialCoords(i)]}];
end

% These are the coordinates of the material matches.  The color
% coordinate varies and the material coordinate always matches the
% target.
for i = 1:length(params.materialMatchColorCoords)
    stimuliMaterialMatch = [stimuliMaterialMatch, {[params.materialMatchColorCoords(i), params.targetMaterialCoord]}];
end

% We pair each color-difference stimulus with each material-difference
% stimulus, unless we are only doing the color-vary stimuli.
clear rowIndex columnIndex overallIndex
for whichColorOfTheMaterialMatch = 1:length(params.materialMatchColorCoords)
    for whichMaterialOfTheColorMatch = 1:length(params.colorMatchMaterialCoords)
        % here we keep track of the indexing, so we could recover
        % ColorVary x MatVary matrix of responses separately from
        rowIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = whichColorOfTheMaterialMatch;
        columnIndex(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = whichMaterialOfTheColorMatch;
        n = n + 1;
        overallColorMaterialPairIndices(whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch) = n;
        
        % The pair is a cell array containing two vectors.  The
        % first vector is the coordinates of the color match, the
        % second is the coordinates of the material match.  There
        % is one such pair for each trial type.
        pair = [pair; ...
            {stimuliColorMatch{whichMaterialOfTheColorMatch}, ...
            stimuliMaterialMatch{whichColorOfTheMaterialMatch} }];
        %             if whichMaterialOfTheColorMatch == 4
        %                 materialIndex = [materialIndex, n];
        %             end
        %             if whichColorOfTheMaterialMatch == 4
        %                 colorIndex = [colorIndex, n];
        %             end
    end
end


% Within color category (so material cooredinate == target material coord)
% Make sure not to include any elements that are including the target
% (i.e., that are included in the previous Color x Material matrix)
withinCategoryPairsColor  =  nchoosek(setdiff(1:length(params.materialMatchColorCoords), params.targetIndex),2);

for whichWithinColorPair = 1:size(withinCategoryPairsColor,1)
        n = n+1;
        pair = [pair; ...
            {[params.materialMatchColorCoords(withinCategoryPairsColor(whichWithinColorPair, 1)), params.targetMaterialCoord]}, ...
            {[params.materialMatchColorCoords(withinCategoryPairsColor(whichWithinColorPair, 2)), params.targetMaterialCoord]}];
    %    colorIndex = [colorIndex, n];
end

% Within material category (so color cooredinate == target color coord)
withinCategoryPairsMaterial  =  nchoosek(setdiff(1:length(params.colorMatchMaterialCoords), params.targetIndex),2);
for whichWithinMaterialPair = 1:size(withinCategoryPairsMaterial,1)
    n = n+1;
    pair = [pair; ...
        {[params.targetColorCoord, params.colorMatchMaterialCoords(withinCategoryPairsMaterial(whichWithinMaterialPair, 1))]}, ...
        {[params.targetColorCoord, params.colorMatchMaterialCoords(withinCategoryPairsMaterial(whichWithinMaterialPair, 2))]}];
    %    materialIndex = [materialIndex, n];
end

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
for whichSet = 1:nDataSets
    % Lock the random seed if this option is selected. 
    if ~ params.seedFixed
    else
        rng('default'); 
    end
    % Initialize the data set. 
    dataSet{whichSet}.responsesFromSimulatedData  = zeros(nPairs,1);
    for b = 1:nBlocks
        responsesForOneBlock = zeros(nPairs,1);
        for whichPair = 1:nPairs
            % Get the color and material coordiantes for each member of
            % this pair.
            pairColorMatchColorCoords(whichPair) = pair{whichPair, 1}(params.colorCoordIndex);
            pairMaterialMatchColorCoords(whichPair) = pair{whichPair, 2}(params.colorCoordIndex);
            pairColorMatchMaterialCoords(whichPair) = pair{whichPair, 1}(params.materialCoordIndex);
            pairMaterialMatchMaterialCoords(whichPair) = pair{whichPair, 2}(params.materialCoordIndex);
            
            % Simulate one response.
            responsesForOneBlock(whichPair) = ColorMaterialModelSimulateResponse(params.targetColorCoord, params.targetMaterialCoord, ...
                pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
                pairColorMatchMaterialCoords(whichPair), pairMaterialMatchMaterialCoords(whichPair), params.w, params.sigma, ...
                'addNoiseToTarget', params.addNoise, 'whichDistance', params.whichDistance);
        end
        
        % Track cummulative response over blocks
        dataSet{whichSet}.responsesFromSimulatedData = dataSet{whichSet}.responsesFromSimulatedData + responsesForOneBlock;
        dataSet{whichSet}.responsesAcrossBlocks(:,b) = responsesForOneBlock;
    end
    % Compute probabilities. 
    dataSet{whichSet}.probabilitiesFromSimulatedData = dataSet{whichSet}.responsesFromSimulatedData./nBlocks;
    
    % For all pairs also compute probabilities based on our analytic
    % function.  These ought to be close to the simulated probabilities.
    % This mainly serves as a check that our analytic function works
    % correctly.  Note that term "analytic" is a bit too strong, there is some
    % numerical integration and approximation involved.
    dataSet{whichSet}.probabilitiesForActualPositions = zeros(nPairs,1);
    for whichPair = 1:nPairs
        dataSet{whichSet}.probabilitiesForActualPositions(whichPair) = colorMaterialInterpolatorFunction(pairColorMatchColorCoords(whichPair), pairMaterialMatchColorCoords(whichPair), ...
            pairColorMatchMaterialCoords(whichPair) , pairMaterialMatchMaterialCoords(whichPair), params.w);
    end
    dataSet{whichSet}.rmseSimulatedVsComputedProbabilities = ComputeRealRMSE(dataSet{whichSet}.probabilitiesForActualPositions,...
            dataSet{whichSet}.probabilitiesFromSimulatedData);
end

% Assign pair data and index data to structures that need to be saved and
% passed. 
pairInfo.pairColorMatchColorCoords = pairColorMatchColorCoords;
pairInfo.pairMaterialMatchColorCoords = pairMaterialMatchColorCoords; 
pairInfo.pairColorMatchMaterialCoords = pairColorMatchMaterialCoords; 
pairInfo.pairMaterialMatchMaterialCoords = pairMaterialMatchMaterialCoords; 
   
indexMatrix.rowIndex = rowIndex; 
indexMatrix.columnIndex = columnIndex; 
indexMatrix.overallColorMaterialPairIndices = overallColorMaterialPairIndices; 

cd(dataDir);
save(dataSetName, 'dataSet', 'params', 'pairInfo', 'indexMatrix');
cd(currentDir);