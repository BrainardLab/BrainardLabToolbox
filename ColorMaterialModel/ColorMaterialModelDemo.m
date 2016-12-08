% ColorMaterialModelDemo.m
%
% Demonstrates color material MLDS model fitting procedure for a data set.
% Initially used as a test bed for testing and improving search algorithm.
%
% The work is done by other routines in this folder.
%
% Requires optimization toolbox.
%
% 11/18/16  ar  Wrote from color selection model version

%% Initialize and parameter set
clear ; close all;

% Simulate up some data, or read in data.  DEMO means simulate.
DEMO = false;

% Make plots with descriptive Weibull fits to the data?
plotWeibullFitsToData = true; 

% What sort of position fitting are we doing, and if smooth
% the order of the polynomial.
% Options:
%  'full' - Weights vary
%  'smoothSpacing' - Weights computed according to a polynomial fit.
whichPositions = 'full';
smoothOrder = 2;

% Initial position spacing values to try.
trySpacingValues = [0.5 1 2];

% Does material/color weight vary in fit?
%  'weightVary' - yes, it does.
%  'weightFixed' - fix weight to specified value in tryWeightValues(1);
whichWeight = 'weightFixed';
tryWeightValues = [0.5 0.2 0.8];

%% Load structure giving experiment design parameters. 
% Here we use the example structure that mathes the experimental design of
% our initial experiments. 
load('ColorMaterialExampleStructure.mat')

% Make a stimulus list and set underlying parameters.
targetMaterialCoord = 0;
targetColorCoord = 0;
stimuliMaterialMatch = [];
stimuliColorMatch = [];
scalePositions = 1; % scaling factor for input positions (we can try different ones to match our noise i.e. sigma of 1).
materialMatchColorCoords = scalePositions*[-3, -2, -1, 0, 1, 2, 3];
colorMatchMaterialCoords = scalePositions*[-3, -2, -1, 0, 1, 2, 3];
targetIndex = 4;
params.materialMatchColorCoords  =  materialMatchColorCoords; 
params.colorMatchMaterialCoords  =  colorMatchMaterialCoords; 

% Set figure directories
figDir = pwd; 
saveFig = 0; 

%% We can use simulated data (DEMO == true) or some real data (DEMO == false)
if (DEMO)
    
    % Make the random number generator seed start at the same place each
    % time we do this.
    rng('default');
    
    sigma = 1;   
    w = 0.5;
    params.subjectName = 'demo'; 
    % These are the coordinates of the color matches.  The color coordinate always matches the
    % target and the matrial coordinate varies.
    for i = 1:length(colorMatchMaterialCoords)
        stimuliColorMatch = [stimuliColorMatch, {[targetColorCoord, colorMatchMaterialCoords(i)]}];
    end
    
    % These are the coordinates of the material matches.  The color
    % coordinate varies and the material coordinate always matches the
    % target.
    for i = 1:length(materialMatchColorCoords)
        stimuliMaterialMatch = [stimuliMaterialMatch, {[materialMatchColorCoords(i), targetMaterialCoord]}];
    end
    
    % Simulate the data
    %
    % Initialize the response structure
    colorCoordIndex = 1;
    materialCoordIndex = 2;
    colorMatchIndexInPair = 1;
    materialMatchIndexInPair = 2;
    nBlocks = 100;
    responseFromSimulatedData  = zeros(length(materialMatchColorCoords),length(colorMatchMaterialCoords));
    probabilitiesComputedForSimulatedData  = zeros(length(materialMatchColorCoords),length(colorMatchMaterialCoords));
    
    % Loop over blocks and stimulus pairs and simulate responses
    %
    % We pair each color-difference stimulus with each material-difference stimulus
    for b = 1:nBlocks
        for whichColorOfTheMaterialMatch = 1:length(materialMatchColorCoords)
            for whichMaterialOfTheColorMatch = 1:length(colorMatchMaterialCoords)
                
                % The pair is a cell array containing two vectors.  The
                % first vector is the coordinates of the color match, the
                % second is the coordinates of the material match.  There
                % is one such pair for each trial type.
                pair = {stimuliColorMatch{whichMaterialOfTheColorMatch},stimuliMaterialMatch{whichColorOfTheMaterialMatch}};
                
                % Set up matrices of indices that will allow us to relate
                % entries of the response matrix to the indices of the
                % stimuli.
                % stimuli and the reponse matrix.We only need to do this on the first block,
                % since it is the same on each block in this simulation.
                if b == 1
                    pairColorMatchMatrialCoordIndexMatrix(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = whichMaterialOfTheColorMatch;
                    pairMaterialMatchColorCoordIndexMatrix(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = whichColorOfTheMaterialMatch;
                end
                
                % Simulate out what the response is for this pair in this
                % block.
                %
                % Note that the first competitor passed is always a color
                % match that differs in material. so the response1 == 1
                % means that the color match was chosen
                response1(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, ...
                    pair{colorMatchIndexInPair}(colorCoordIndex), pair{materialMatchIndexInPair}(colorCoordIndex), pair{colorMatchIndexInPair}(materialCoordIndex), pair{materialMatchIndexInPair}(materialCoordIndex), w, sigma);
            end
        end
        
        % Track cummulative response over blocks
        responseFromSimulatedData = responseFromSimulatedData+response1;
        clear response1
    end
    
    % compute response probabilities
    theDataProb = responseFromSimulatedData./nBlocks;
    
    % Use identical loop to compute probabilities, based on our function.
    for whichColorOfTheMaterialMatch = 1:length(materialMatchColorCoords)
        for whichMaterialOfTheColorMatch = 1:length(colorMatchMaterialCoords)
            clear pair
            pair = {stimuliColorMatch{whichMaterialOfTheColorMatch},stimuliMaterialMatch{whichColorOfTheMaterialMatch}};
            
            % compute probabilities from simulated data using our function
            probabilitiesComputedForSimulatedData(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                ColorMaterialModelComputeProb(targetColorCoord, targetMaterialCoord, ...
                pair{colorMatchIndexInPair}(colorCoordIndex), pair{materialMatchIndexInPair}(colorCoordIndex), pair{colorMatchIndexInPair}(materialCoordIndex), pair{materialMatchIndexInPair}(materialCoordIndex), w, sigma);
        end
    end
    
    % String the response matrix as well as the pairMatrices out as vectors.
    theResponsesFromSimulatedData = responseFromSimulatedData(:);
    probabilitiesFromSimulatedDataMatrix = responseFromSimulatedData./nBlocks; 
    probabilitiesComputedForSimulatedData = probabilitiesComputedForSimulatedData(:);
    pairColorMatchMatrialCoordIndices = pairColorMatchMatrialCoordIndexMatrix(:);
    pairMaterialMatchColorCoordIndices = pairMaterialMatchColorCoordIndexMatrix(:);
    
    % Total number of trials run for every row of competitorIndices.
    % Number of columns here should match the number of columns in
    % someData.
    nTrials = nBlocks*ones(size(theResponsesFromSimulatedData));
    logLikely = ColorMaterialModelComputeLogLikelihood(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponsesFromSimulatedData,nTrials,colorMatchMaterialCoords,materialMatchColorCoords,targetIndex,w,sigma);
    fprintf('Initial log likelihood %0.2f.\n', logLikely);
    
    
    % Here you could enter some real data and work on figuring out why a model
    % fit was going awry.
else
    
    % Set up some params
    % All this should be in the pair indices matrix. 
    colorCoordIndex = 1;
    materialCoordIndex = 2;
    colorMatchIndexInPair = 1;
    materialMatchIndexInPair = 2;
    load('pairIndices.mat')
    
    whichOption = 'option2'; 
    
    switch whichOption
        case 'option1'
            theResponsesFromSimulatedData = [ 21    21    24    24    24    24    20
                18    15    16    23    22    18    12
                1     0     2    15     6     1     1
                0     0     1    11     4     0     0
                14    19    17    24    22    15     3
                23    24    24    24    24    22    22
                24    23    24    24    24    24    23  ];
            nBlocks = 24;
            nTrials = nBlocks*[ones(size(theResponsesFromSimulatedData))];
        case 'option2'
            %
            theResponsesFromSimulatedData = [   23    24    25    25    25    23    23
                21    25    24    25    22    23    22
                6    10    21    25    18     8     8
                0     1     1   12     0     0     0
                1     2    15    22     6     3     3
                10    10    21    25    18    12     8
                24    25    25    25    24    25    24 ];
            nBlocks = 25;
            nTrials = nBlocks*[ones(size(theResponsesFromSimulatedData))];
    end
    theDataProb = theResponsesFromSimulatedData./nTrials;
    params.subjectName = whichOption; 
end

%% Extract parameters and other useful things from the solution
%
% Put the method into the params structure, so it flows to where we need
% it.  This isn't beautiful, but saves us figuring out how to pass the
% various key value pairs all the way down into the functions called by
% fmincon, which is actually somewhat hard to do in a more elegant way.
params.whichPositions = whichPositions;
params.smoothOrder = smoothOrder;
[returnedParams, logLikelyFit, predictedProbabilitiesBasedOnSolution, k] = ColorMaterialModelMain(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponsesFromSimulatedData,nTrials,params, ...
    'whichPositions',whichPositions,'whichWeight',whichWeight,'tryWeightValues',tryWeightValues,'trySpacingValues',trySpacingValues); %#ok<SAGROW>
[returnedMaterialMatchColorCoords,returnedColorMatchMaterialCoords,returnedW,returnedSigma]  = ColorMaterialModelXToParams(returnedParams, params); 
fprintf('Returned weigth: %0.2f.\n', returnedW);  
fprintf('Log likelyhood of the solution: %0.2f.\n', logLikelyFit);

% Check that the returned target coordinate is 0.
% Here we need to add the target index. 
% tolerance = 1e-7; 
% if (abs(returnedMaterialMatchMaterialCoord) > tolerance)
%     error('Target material coordinate did not map to zero.')
% end
% if (abs(returnedColorMatchColorCoord) > tolerance)
%     error('Target color coordinates did not map to zero.')
% end

ColorMaterialPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, returnedParams, params, figDir, saveFig); % probabilitiesComputedForSimulatedData); 

%% Check that we can get the same predictions directly from the solution in ways we might want to do it
% [logLikelyFit2,predictedProbabilitiesBasedOnSolution2] = ColorMaterialModelComputeLogLikelihood(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponsesFromSimulatedData,nTrials,...
%     returnedColorMatchMaterialCoords,returnedMaterialMatchColorCoords,params.targetIndex,...
%     returnedW, returnedSigma);
% [negLogLikelyFit3,predictedProbabilitiesBasedOnSolution3] = FitColorMaterialScalingFun(returnedParams,pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponsesFromSimulatedData,nTrials,params);
% if (any(predictedProbabilitiesBasedOnSolution ~= predictedProbabilitiesBasedOnSolution3))
%     error('Cannot recover the predictions 3 from the parameters right after we found them!');
% end
% if (any(predictedProbabilitiesBasedOnSolution ~= predictedProbabilitiesBasedOnSolution2))
%     error('Cannot recover the predictions 2 from the parameters right after we found them!');
% end
% if debugging
% [~,modelPredictions2] = ColorMaterialModelComputeLogLikelihood(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponsesFromSimulatedData,nTrials,...
%     returnedColorMatchMaterialCoords,returnedMaterialMatchColorCoords,params.targetIndex,...
%     returnedW, returnedSigma);
% end
%% Make sure the numbers we compute from the model now match those we computed in the demo program
%if debugging
%figure; clf; hold on
%plot(predictedProbabilitiesBasedOnSolution(:),modelPredictions(:),'ro','MarkerSize',12,'MarkerFaceColor','r');
%plot(predictedProbabilitiesBasedOnSolution(:),modelPredictions2(:),'bo','MarkerSize',12,'MarkerFaceColor','b');
%xlim([0 1]); ylim([0,1]); axis('square');
%end