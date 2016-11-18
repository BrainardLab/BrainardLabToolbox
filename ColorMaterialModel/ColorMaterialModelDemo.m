% ColorMaterialModelDemo.m
%
% Demonstrates MLDS Fitting procedure for a data set.
% Initially used as a test bed for improving search algorithm.
% Currently used as demo and also to debug the algorithm for
% any "problematic data set".
%
% The work is done by other routines in this folder. 
%
% Requires optimization toolbox.
%
% 5/3/12  dhb  Wrote it. Added scatterplot of predicted versus measured probs added.
% 6/13/13  ar  Clean up, added comments

% Initialize
clear ; close all;
DEMO = true;
saveFig = 0;
if (DEMO)
    % make a stimulus list
    targetM = 0; 
    targetC = 0; 
    stimuliC = [];
    stimuliM = [];
    cDistances = [-3, -2, -1, 0, 1, 2, 3];
    mDistances = [-3, -2, -1, 0, 1, 2, 3];
    sigma = 1;
    w = 0.5; 
    for i = 1:length(cDistances)
        % these are the material matches that vary in color.
        stimuliC = [stimuliC, {[cDistances(i), targetM]}];
    end
    for i = 1:length(mDistances)
        % these are the color matches that vary in material
        stimuliM = [stimuliM, {[targetC, mDistances(i)]}];
    end
    % Initialize the response structure
    cIndex = 1;
    mIndex = 2;
    nBlocks = 24;
    
    response  = zeros(length(cDistances),length(mDistances));
    pairIndices = []; 
    pairSpecs = []; 
    % simulate the experiment.
    for b = 1:nBlocks
        for whichColor = 1:length(cDistances)
            for whichMaterial = 1:length(mDistances)
                % pair all material matches with all color matches.
                clear pair
                pair = {stimuliM{whichMaterial},stimuliC{whichColor}};
                if b == 1
                    pairIndices = [pairIndices; whichColor, whichMaterial];
                    % pair1: color, material; pair2: color, material
                    pairSpecs = [pairSpecs; [stimuliM{whichMaterial},stimuliC{whichColor}]];
                end
                % compute probability using this function
                % CMModelSimulateResponse(xC,xM, cy1,cy2,my1, my2, sigma, w)
                
                response1(whichColor,whichMaterial) = ColorMaterialModelSimulateResponse(targetC,targetM, pair{1}(cIndex), pair{2}(cIndex), pair{1}(mIndex),pair{2}(mIndex), sigma, w);
                % note that the first competitor passed is always a
                % color match that differs in materia. 
                % so the response 1 == 1 is the color match is chosen
                
                % note that in the response column shows the probability of material match being chosen rows are
                % colorMatches and the columns are material matches. 
            end
        end
        % track cummulative response
        response = response+response1;
        clear response1
    end
    
    % compute response probabilities
    % responseProbabilities = response./nBlocks;
    
    % Number of trials first competitor in each
    % row of competitorIndices was chosen as closest
    % to the target.  One row here for every row 
    % of competitorIndices.
    %
    % You can have more than one column here if you want,
    % as long as all the columns correspond to the same nominal
    % pairing provided in competitorIndices above.
    theResponses = response(:);
    
    % Total number of trials run for every row of competitorIndices.
    % Number of columns here should match the number of columns in
    % someData.
    nTrials = nBlocks*ones(size(theResponses)); 
else
    % You can put your own data here and change DEMO flag above to
    % false, to see what happens for a different dataset.
    competitorIndices = [
        ];
    
    someData = [
        ];

    nTrials = [
        ];
end

% Need to unpack this here!
[returnParams, logLikelyFit, predictedResponses] = ColorMaterialModelMain(pairIndices,theResponses,nTrials); %#ok<SAGROW>


