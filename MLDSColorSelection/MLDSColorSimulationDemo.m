% MLDSSimulationDemo.m
%
% We want to simulate a set of responses and see whether our routines extract the right response.
%
% 10/22/13  ar  Wrote it, using the MLDSColorSelectionDemo.m

% Initialize
clear ; close all;

% Set up some parameters that resemble our experiment.
lengthLinY = 6;  % number of competitors
nTrials = 30; % number of simulated trials
sigma = 0.1; % used for simulation. CHECK.

% if trySpacing == 1
%     spacingFactor = 1;
% elseif trySpacing == 2
%     spacingFactor = 0.5;
% elseif trySpacing == 3
%     spacingFactor = 2;
% end
spacingFactor = 2;
nSimulations = 1000; 
linY = linspace(1,spacingFactor*lengthLinY,lengthLinY); 
% linearly space the competitors to preserve their "linear spacing in color space".
y = MLDSIdentityMap(linY); % assume identitiy mapping, as we applied in the toolbox.

% create competitor pairs
thePairs = nchoosek(1:lengthLinY,2);
nPairs = size(thePairs,1);
nTrials = nTrials*ones(nPairs,1);

for whichTarget = 1:6;
    for whichSim = 1:nSimulations
        % Simulate responses
        for i = 1:length(thePairs)
            n1 = 0;
            for j = 1:nTrials(i) %nSimulatePerPair
                if (MLDSSimulateResponse(linY(whichTarget),y(thePairs(i,1)),y(thePairs(i,2)),sigma,@MLDSIdentityMap))
                    n1 = n1 + 1;
                end
            end
            theResponses(i) = n1;
        end
        % then recover the solution from these responses.
        [targetCompetitorFit{whichTarget}(whichSim, :), logLikelyFit{whichTarget}(whichSim), predictedResponses{whichTarget}(whichSim, :)] = MLDSColorSelection(thePairs,theResponses',nTrials, lengthLinY); %#ok<SAGROW>
        % MLDSColorSelectionPlot(thePairs,theResponses,nTrialsPerPair,targetCompetitorFit{whichTarget}(whichSim),predictedResponses{whichTarget}(whichSim), saveFig);
        position{whichTarget}(whichSim) = MLDSInferPosition(targetCompetitorFit{whichTarget}(whichSim, :), lengthLinY);
        clear theResponses
    end
    fprintf(['done target' num2str(whichTarget) '\n']);
end
save(['simulatedRecoverySpacing' num2str(spacingFactor)], 'position')
% plot results
% 
% sp{1} = load('simulatedRecoverySpacing1.mat'); 
% sp{2} = load('simulatedRecoverySpacingHalf.mat'); 
% sp{3} = load('simulatedRecoverySpacing2.mat'); 
% figure; clf; hold on;
% %title('Recovered solution (spacing 1)')
% 
% for whichTarget = 1:6%lengthLinY
%     plot((whichTarget), mean(sp{1}.position{whichTarget}),'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 16);
%     plot((whichTarget), mean(sp{2}.position{whichTarget}),'go', 'MarkerFaceColor', 'g',  'MarkerSize', 15);
%     plot((whichTarget), mean(sp{3}.position{whichTarget}),'bo', 'MarkerFaceColor', 'b',  'MarkerSize', 14);
% end
% axis square
% axis([1 6 1 6])
% line([1 6], [1 6], 'color', 'k')
% set(gca, 'Ytick', 1:1:6, 'FontSize', 20);
% xlabel('Simulated target position', 'FontSize',20)
% ylabel('Inferred target position', 'FontSize', 20)
% savefigghost('RecoveredSolutionSpacing1',gcf,'pdf')
% 
