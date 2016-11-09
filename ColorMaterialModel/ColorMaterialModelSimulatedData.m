% % ColorMaterialModelSimulatedData

% Initialize
clear; close all;

% Set params. 
cDistances = [-3, -2, -1, 0, 1, 2, 3].*2;
mDistances = [-3, -2, -1, 0, 1, 2, 3].*2;
sigma = 1;
tryWeigths = [0.1, 0.5, 0.9];

% target position
targetC = 0;
targetM = 0;

% make a stimulus list
stimuliC = [];
stimuliM = [];
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
paired = 0; % plot step pairs if set to 1. 

for whichWeigth = 1:length(tryWeigths)
    w = tryWeigths(whichWeigth);
    response  = zeros(length(cDistances),length(mDistances));

    % simulate the experiment.
    for b = 1:nBlocks
        for whichColor = 1:length(cDistances)
            for whichMaterial = 1:length(mDistances)
                % pair all material matches with all color matches.
                clear pair
                pair = {stimuliM{whichMaterial},stimuliC{whichColor}};
                
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
    responseProbabilities = response./nBlocks;
end
save('simulatedData.mat','responseProbabilities');  