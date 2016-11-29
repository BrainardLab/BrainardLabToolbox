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
DEMO = true;
plotWeibullFitsToData = 1; 
%% Load structure giving experiment design parameters. 
% Here we use the example structure that mathes the experimental design of
% our initial experiments. 
load('ColorMaterialExampleStructure.mat')
%% We can use simulated data (DEMO == true) or some real data (DEMO == false)
if (DEMO)
    
    % Make the random number generator seed start at the same place each
    % time we do this.
    rng('default');
    
    % Make a stimulus list and set underlying parameters.
    targetMaterialCoord = 0;
    targetColorCoord = 0;
    stimuliMaterialMatch = [];
    stimuliColorMatch = [];
    scalePositions = 1; % scaling factor for input positions (we can try different ones to match our noise i.e. sigma of 1).
    materialMatchColorCoords = scalePositions*[-3, -2, -1, 0, 1, 2, 3];
    colorMatchMaterialCoords = scalePositions*[-3, -2, -1, 0, 1, 2, 3];
    targetIndex = 4;
    sigma = 1;
    w = 0.5;
    
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
    response  = zeros(length(materialMatchColorCoords),length(colorMatchMaterialCoords));
    computedProbatilities  = zeros(length(materialMatchColorCoords),length(colorMatchMaterialCoords));
    pairIndices = [];
    
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
        response = response+response1;
        clear response1
    end
    
    % compute response probabilities
    responseProbabilities = response./nBlocks;
    
    % Use identical loop to compute probabilities, based on our function.
    for whichColorOfTheMaterialMatch = 1:length(materialMatchColorCoords)
        for whichMaterialOfTheColorMatch = 1:length(colorMatchMaterialCoords)
            clear pair
            pair = {stimuliColorMatch{whichMaterialOfTheColorMatch},stimuliMaterialMatch{whichColorOfTheMaterialMatch}};
            
            % compute probabilities
            computedProbatilities(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ColorMaterialModelComputeProb(targetColorCoord, targetMaterialCoord, ...
                pair{colorMatchIndexInPair}(colorCoordIndex), pair{materialMatchIndexInPair}(colorCoordIndex), pair{colorMatchIndexInPair}(materialCoordIndex), pair{materialMatchIndexInPair}(materialCoordIndex), w, sigma);
        end
    end
    
    % String the response matrix as well as the pairMatrices out as vectors.
    theResponses = response(:);
    computedProbabilitiesMatrix = response./nBlocks; 
    computedProbatilities = computedProbatilities(:);
    pairColorMatchMatrialCoordIndices = pairColorMatchMatrialCoordIndexMatrix(:);
    pairMaterialMatchColorCoordIndices = pairMaterialMatchColorCoordIndexMatrix(:);
    
    % Total number of trials run for every row of competitorIndices.
    % Number of columns here should match the number of columns in
    % someData.
    nTrials = nBlocks*ones(size(theResponses));
    logLikely = ColorMaterialModelComputeLogLikelihood(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponses,nTrials,colorMatchMaterialCoords,materialMatchColorCoords,targetIndex,w,sigma);
    fprintf('Initial log likelihood %0.2f.\n', logLikely);
    % Here you could enter some real data and work on figuring out why a model
    % fit was going awry.
else
    
    pairIndices = [
        ];
    
    theResponses = [
        ];
    
    nTrials = [
        ];
end

% Need to unpack this here!
[returnedParams, logLikelyFit, predictedResponses] = ColorMaterialModelMain(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponses,nTrials, params); %#ok<SAGROW>
[returnedMaterialCoords,returnedColorCoords,returnedW,returnedSigma]  = ColorMaterialModelXToParams(returnedParams', params); 

%% Plot measured vs. predicted probabilities
theDataProb = theResponses./nTrials;

figure; hold on
plot(theDataProb,predictedResponses,'ro','MarkerSize',12,'MarkerFaceColor','r');
plot(theDataProb,computedProbatilities,'bo','MarkerSize',12,'MarkerFaceColor','b');

plot([0 1],[0 1],'k');
axis('square')
axis([0 1 0 1]);
set(gca,  'FontSize', 18);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);

%% Fit cubic spline to the data
% We do this separately for color and material dimension
ppColor = spline(materialMatchColorCoords, returnedColorCoords);
ppMaterial = spline(colorMatchMaterialCoords, returnedMaterialCoords);
xMinTemp = floor(min([returnedColorCoords, returnedMaterialCoords]))-0.5; 
xMaxTemp = ceil(max([returnedColorCoords, returnedMaterialCoords]))+0.5;
xTemp = max(abs([xMinTemp xMaxTemp]));
xMin = -xTemp;
xMax = xTemp;
yMin = xMin; 
yMax = xMax;
splineOverX = linspace(xMin,xMax,1000);
inferredPositionsColor = ppval(splineOverX,ppColor); 
inferredPositionsMaterial  = ppval(splineOverX,ppMaterial); 

%% Plot found vs predicted positions. 
figure; 
subplot(1,2,1); hold on % plot of material positions
plot(materialMatchColorCoords,returnedColorCoords,'ro',splineOverX, inferredPositionsColor, 'r');
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', 1, 'color', [0.5 0.5 0.5]);
title('Color dimension')
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', 18);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', 18);

% Set large range of values for fittings
subplot(1,2,2); hold on % plot of material positions
title('Material dimension')
plot(colorMatchMaterialCoords,returnedMaterialCoords,'bo',splineOverX,inferredPositionsMaterial, 'b');
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', 1, 'color', [0.5 0.5 0.5]);
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', 18);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', 18);

%% Another way to plot the data
figure; hold on; 
plot(returnedColorCoords, zeros(size(returnedColorCoords)),'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 12); 
line([xMin, xMax], [0,0],'color', 'k'); 
plot(zeros(size(returnedMaterialCoords)), returnedMaterialCoords, 'bo','MarkerFaceColor', 'b', 'MarkerSize', 12); 
axis([xMin, xMax,yMin, yMax])
line([0,0],[yMin, yMax],  'color', 'k'); 
axis('square')
xlabel('color positions', 'FontSize', 18);
ylabel('material positions','FontSize', 18);

%% Plot Weibull fits to the data
if plotWeibullFitsToData
    for i = 1:size(response,2);
        if i == 4
            fixPoint = 1;
        else
            fixPoint = 0;
        end
        [theSmoothPreds(:,i), theSmoothVals(:,i)] = ColorMaterialModelGetValuesFromFits(responseProbabilities(:,i)',colorMatchMaterialCoords, fixPoint);
    end
    ColorMaterialModelPlotFits(theSmoothVals, theSmoothPreds, materialMatchColorCoords, responseProbabilities);
end

%% Plot model predictions 
% First check the positions of color (material) match on color (material) axis.  
% Signal if there is an error. 
returnedMaterialMatchMaterialCoord = ppval(targetMaterialCoord, ppMaterial);
returnedColorMatchColorCoord =  ppval(targetColorCoord, ppColor);
if ~(returnedMaterialMatchMaterialCoord == 0)
    error('Target material coordinate did not map to zero.')
end
if ~(returnedColorMatchColorCoord == 0)
    error('Target color coordinates did not map to zero.')
end

% Find the predicted probabilities for a range of possible color coordinates 
rangeOfColorCoordinates = linspace(xMin, xMax, 100)';   
for whichMaterialCoordinate = 1:length(materialMatchColorCoords)
    returnedColorMatchMaterialCoord(whichMaterialCoordinate) = ppval(colorMatchMaterialCoords(whichMaterialCoordinate), ppMaterial);
    for whichColorCoordinate = 1:length(rangeOfColorCoordinates)
        returnedMaterialMatchColorCoord(whichColorCoordinate) = ppval(rangeOfColorCoordinates(whichColorCoordinate), ppColor);
        modelPredictions(whichColorCoordinate, whichMaterialCoordinate) = ColorMaterialModelComputeProb(targetColorCoord,targetMaterialCoord, ...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord, returnedW, returnedSigma);
    end
end
%remap the intial Color Values
rangeOfColorCoordinates = repmat(rangeOfColorCoordinates,[1, length(materialMatchColorCoords)]);
ColorMaterialModelPlotFits(rangeOfColorCoordinates, modelPredictions, returnedColorCoords, responseProbabilities, xMin, xMax);





