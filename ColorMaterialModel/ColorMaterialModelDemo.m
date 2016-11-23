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
saveFig = 0;

%% We can use simulated data (DEMO == true) or some real data (DEMO == false)
if (DEMO)
    
    % Make a stimulus list and set underlying parameters.
    targetMaterialCoord = 0; 
    targetColorCoord = 0; 
    stimuliMaterialMatch = [];
    stimuliColorMatch = [];
    scalePositions = 1; % scaling factor for input positions (we're trying different ones to adjust our noise of 1). 
    colorPositionsOfMaterialMatch = scalePositions*[-3, -2, -1, 0, 1, 2, 3];
    materialPositionsOfColorMatch = scalePositions*[-3, -2, -1, 0, 1, 2, 3];
    targetIndex = 1; 
    sigma = 1;
    w = 0.5; 
    
    % These are the material matches that vary in color.
    for i = 1:length(colorPositionsOfMaterialMatch)   
        stimuliMaterialMatch = [stimuliMaterialMatch, {[colorPositionsOfMaterialMatch(i), targetMaterialCoord]}];
    end
    % These are the color matches that vary in material
    for i = 1:length(materialPositionsOfColorMatch)
        stimuliColorMatch = [stimuliColorMatch, {[targetColorCoord, materialPositionsOfColorMatch(i)]}];
    end
    
    % Simulate the data
    %
    % Initialize the response structure
    cIndex = 1; 
    mIndex = 2;
    nBlocks = 24;
    response  = zeros(length(colorPositionsOfMaterialMatch),length(materialPositionsOfColorMatch));
    computedPs  = zeros(length(colorPositionsOfMaterialMatch),length(materialPositionsOfColorMatch));
    
    pairIndices = []; 
    
    % Loop over blocks and stimulus pairs and simulate responses
    %
    % We pair each color-difference stimulus with each material-difference stimulus
    for b = 1:nBlocks
        for whichColorOfTheMaterialMatch = 1:length(colorPositionsOfMaterialMatch)
            for whichMaterialOfTheColorMatch = 1:length(materialPositionsOfColorMatch)
                clear pair
                pair = {stimuliColorMatch{whichMaterialOfTheColorMatch},stimuliMaterialMatch{whichColorOfTheMaterialMatch}};
                
                % Set up matrices of indices that will allow us to relate the
                % stimuli and the reponse matrix.
                % We only need to do this on the first block,
                % since it is the same on each block in this simulation.
                if b == 1
                    pairColorMatrix(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = whichColorOfTheMaterialMatch;
                    pairMaterialMatrix(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = whichMaterialOfTheColorMatch;
                end
                
                % Simulate out what the response is for this pair in this
                % block.
                %
                % Note that the first competitor passed is always a color
                % match that differs in material. so the response1 == 1
                % means that the color match was chosen
                response1(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, pair{1}(cIndex), pair{2}(cIndex), pair{1}(mIndex), pair{2}(mIndex), w, sigma);
            end
        end
        
        % Track cummulative response over blocks
        response = response+response1;
        clear response1
    end
    
   % compute response probabilities
    responseProbabilities = response./nBlocks;
   
    % Plot fits for each curve.
    % Fit each data run separately
    % CURRENTLY COMMENTED OUT, UNTIL THESE FUNCTIONS ARE CLEANED UP
    % COMMENTED AND MOVED TO THE TOOLBOX
%     for i = 1:size(response,2);
%         if i == 4
%             fixPoint = 1;
%         else
%             fixPoint = 0;
%         end
%         [theSmoothPreds(:,i), theSmoothVals, ~,~] = ...
%     %        getValuesFromFitsCM(responseProbabilities(:,i)',cDistances, fixPoint);
%     end
%     plotCMFitsSimForMODEL(theSmoothVals, theSmoothPreds, cDistances, responseProbabilities)
    
    % Use identical loop to compute probabilities, based on our function. 
    for whichColorOfTheMaterialMatch = 1:length(colorPositionsOfMaterialMatch)
        for whichMaterialOfTheColorMatch = 1:length(materialPositionsOfColorMatch)
            clear pair
            pair = {stimuliColorMatch{whichMaterialOfTheColorMatch},stimuliMaterialMatch{whichColorOfTheMaterialMatch}};
            % compute probabilities
            computedPs(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ColorMaterialModelComputeProb(targetColorCoord,targetMaterialCoord, pair{1}(cIndex), pair{2}(cIndex), pair{1}(mIndex), pair{2}(mIndex), w, sigma);
        end
    end
        
    % String the response matrix as well as the pairMatrices out as vectors. 
    theResponses = response(:);
    computedPs = computedPs(:);
    pairIndices(:,1) = pairColorMatrix(:);
    pairIndices(:,2) = pairMaterialMatrix(:);
    
    % Total number of trials run for every row of competitorIndices.
    % Number of columns here should match the number of columns in
    % someData.
    nTrials = nBlocks*ones(size(theResponses)); 
    logLikely = ColorMaterialModelComputeLogLikelihood(pairIndices,theResponses,nTrials, colorPositionsOfMaterialMatch,materialPositionsOfColorMatch, 4, w, sigma);
    ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials, materialPositions, colorPositions,targetIndex, w, sigma)
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
[returnParams, logLikelyFit, predictedResponses] = ColorMaterialModelMain(pairIndices,theResponses,nTrials); %#ok<SAGROW>

%% Plot measured vs. predicted probabilities 
theDataProb = theResponses./nTrials; 

figure; hold on
plot(theDataProb,predictedResponses,'ro','MarkerSize',12,'MarkerFaceColor','r');
plot(theDataProb,computedPs,'bo','MarkerSize',12,'MarkerFaceColor','b');

plot([0 1],[0 1],'k');
axis('square')
axis([0 1 0 1]);
set(gca,  'FontSize', 18);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);