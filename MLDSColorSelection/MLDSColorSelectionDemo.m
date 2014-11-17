% MLDSColorSelectionDemo.m
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
    % THIS IS JUST A HARDCODED DATASET.
    % Here we pass the combinations of competitors presented with the
    % target, the responses (number of trials the first competitor is
    % chosen), the total number of trials completed.
    %
    % These data correspond to color selection Experiment 1, Subject udm,
    % bluish illuminant-change, target rose. 
    
    % specify indices of competitors that follow the presentation used on
    % each trial type.  Here it is all pairwise combinations of integers
    % 1-6.
    competitorIndices = [ ...
        1     2
        1     3
        1     4
        1     5
        1     6
        2     3
        2     4
        2     5
        2     6
        3     4
        3     5
        3     6
        4     5
        4     6
        5     6];
    
    % Number of trials first competitor in each
    % row of competitorIndices was chosen as closest
    % to the target.  One row here for every row 
    % of competitorIndices.
    %
    % You can have more than one column here if you want,
    % as long as all the columns correspond to the same nominal
    % pairing provided in competitorIndices above.
    someData = [...
        8
        0
        0
        6
        28
        8
        15
        26
        28
        10
        19
        30
        29
        29
        27];
    
    % Total number of trials run for every row of competitorIndices.
    % Number of columns here should match the number of columns in
    % someData.
    nTrials = [...
        30
        30
        30
        30
        30
        30
        30
        30
        30
        30
        30
        30
        30
        30
        30];
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

% Fit data for each target (column of someData) and then, plot the results. 
nTargets = size(someData,2);
lengthLinY = max(competitorIndices(:));
for j = 1:nTargets
    nTrialsPerPair = nTrials(:,j); 
    theResponses = someData(:,j);   
    [targetCompetitorFit{j}, logLikelyFit{j}, predictedResponses{j}] = MLDSColorSelection(competitorIndices,theResponses,nTrialsPerPair, lengthLinY); %#ok<SAGROW>
    MLDSColorSelectionPlot(competitorIndices,theResponses,nTrialsPerPair,targetCompetitorFit{j},predictedResponses{j}, saveFig);
    clear theResponses nTrialsPerPair
end

