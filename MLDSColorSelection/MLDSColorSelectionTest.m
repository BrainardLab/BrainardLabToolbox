% MLDSColorSelectionTest.m
%
% Tests MLDS Fitting procedure for a data set.
% Initially used as a test bed for improving search algorithm.
% Currently used to test the algorithm for any "problematic data set".
%
% NOTE.  This should be integrated with teaching/crossContextMLDSScalingTutorial,
% and vice versa.  The tutorial should probably call routines in this folder,
% and perhaps the simulation should be added here in some integrated way.
%
% 5/3/12  dhb  Wrote it. Added scatterplot of predicted versus measured probs added.
% 6/13/13  ar  Clean up, added comments

% Initialize
clear ; close all;
DEMO = 0;
saveFig = 0; 
if (DEMO)
    % THIS IS JUST A HARDCODED AND DEPENDS ON THE EXPERIMENT
    % Here we pass the combinations of competitors presented with the
    % target, the responses (number of trials the first competitor is
    % chosen), the total number of trials completed. 
    competitorIndices = [1	2; 1 3; 1 5; 1 4; 2 3; 2 4; 2 5; 3 4; 3	5; 4 5];
    lengthLinY = max(competitorIndices(:));
    someData = [...
        11	7	5	5	4	5	5	9
        8	4	5	2	5	0	7	5
        2	3	4	1	1	1	1	1
        4	1	3	0	2	2	2	2
        11	7	7	4	7	7	10	7
        7	2	3	2	1	3	7	1
        3	1	0	2	2	1	4	1
        10	7	4	5	5	6	7	9
        7	0	1	1	2	2	4	1
        5	4	9	5	5	10	7	6];
    nTrials = [...
        25	21	19	21	19	24	18	23
        25	28	20	26	21	20	24	26
        26	25	26	24	26	25	26	27
        27	22	24	26	26	26	22	22
        28	25	25	23	26	28	17	23
        28	24	26	25	27	25	26	24
        26	24	24	24	28	22	25	24
        24	25	25	20	22	26	23	24
        27	26	19	23	21	25	20	23
        27	18	23	21	23	24	23	24];
else
    % For testing purposes, enter your data. 
    % specify indexes of competitors that follow the presentation pattern over trials.
    %competitorIndices = [1	2; 1 3; 1 5; 1 4; 2 3; 2 4; 2 5; 3 4; 3	5; 4 5];
    competitorIndices = [     1     2
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
    lengthLinY = max(competitorIndices(:));
    % paste in the some response sets
    someData = [  
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
    27

        ];
    % paste the total number of trials from which the responses are
    % obtained. 
    nTrials = [30
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
end

% Fit data for each target-competitor set (a single column in the set of data above). 
% Plot the results
nTargets = size(someData,2);

for j = 1:nTargets
    nTrialsPerPair = nTrials(:,j); % get the relevant number of trials. 
    theResponses = someData(:,j);   % get the relevant set of responses across competitor pairs. 
    [targetCompetitorFit{j}, logLikelyFit{j}, predictedResponses{j}] = MLDSColorSelection(competitorIndices,theResponses,nTrialsPerPair, lengthLinY); %#ok<SAGROW>
    MLDSColorSelectionPlot(competitorIndices,theResponses,nTrialsPerPair,targetCompetitorFit{j},predictedResponses{j}, saveFig);
    clear theResponses nTrialsPerPair
end

