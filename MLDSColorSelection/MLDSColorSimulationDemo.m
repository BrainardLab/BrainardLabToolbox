% MLDSColorSimulationDemo.m
%
% To estimate the precision of our MLDS method
% we will simulate a set of responses for a series of hypothetical targets positioned
% somewhere along the space of competitors. 
% Then we will use our MLDS method to infer the target position
% given the simulated set of responses. 
%
% We will do this for a number of different linear spacings between the
% competitors. The range of possible spacings is determined based on the 
% range of competitors recovered from our experimental data.  

% 10/22/14  ar  Wrote it, using the MLDSColorSelectionDemo.m
% 10/27/14  ar  Included option to simulate multiple spacings and targets. Added comments. 

% Initialize
clear ; close all;

% Set up some parameters that resemble our experiment.
nCompetitors = 5;
nTrials = 30; % number of simulated trials
sigma = 0.1; % used for simulation. 

% spacingRange = [0.15, 0.5, 1, 3, 5]; old spacing range. 
spacingRange = [0.15, 5];
nSimulations = 100;

% create competitor pairs for a given set of competitors. 
thePairs = nchoosek(1:nCompetitors,2); 
nPairs = size(thePairs,1);
nTrials = nTrials.*ones(nPairs,1);

for trySpacing = 1:length(spacingRange)
    % create competitor pairs for a given set of competitors. 
    % spacing range is from 1 to 1+ range (rather than from 0).
    linY = linspace(1,spacingRange(trySpacing)+1,nCompetitors); 
    y = MLDSIdentityMap(linY); % assume identity mapping, as we applied in the toolbox.
    
    % add some targets which fall between the competitors. 
    if nCompetitors == 5
        targets = [linY, linspace(1,spacingRange(trySpacing)+1,50)];
    elseif nCompetitors == 6
        targets = [linY, linspace(1,spacingRange(trySpacing)+1,50)];
    end
    
    for whichTarget = 1:length(targets);
        for whichSim = 1:nSimulations
            % Simulate responses
            for i = 1:length(thePairs)
                n1 = 0;
                for j = 1:nTrials(i) %nSimulatePerPair
                    if (MLDSSimulateResponse(targets(whichTarget),y(thePairs(i,1)),y(thePairs(i,2)),sigma,@MLDSIdentityMap));
                        n1 = n1 + 1;
                    end
                end
                theResponses(i) = n1;
            end
            % then recover the solution from these responses.
            [targetCompetitorFit{whichTarget}(whichSim, :), logLikelyFit{whichTarget}(whichSim), predictedResponses{whichTarget}(whichSim, :)] = MLDSColorSelection(thePairs,theResponses',nTrials, nCompetitors); %#ok<SAGROW>
            % MLDSColorSelectionPlot(thePairs,theResponses,nTrialsPerPair,targetCompetitorFit{whichTarget}(whichSim),predictedResponses{whichTarget}(whichSim), saveFig);
            position{whichTarget}(whichSim) = MLDSInferPosition(targetCompetitorFit{whichTarget}(whichSim, :), nCompetitors);
            clear theResponses
        end
        % recover actual targetPosition from spacings. 
        realPosition(whichTarget)  =  MLDSInferPosition([targets(whichTarget), linY], nCompetitors);
    end
    if nCompetitors == 5
        save(['simulatedRecoverySpacingNew' num2str(trySpacing)], 'position', 'realPosition')
        
    % old simulation   
    % save(['simulatedRecoverySpacing5C' num2str(trySpacing)], 'position', 'realPosition')
    
    elseif nCompetitors == 6
        save(['simulatedRecoverySpacingZaidi' num2str(trySpacing)], 'position', 'realPosition')
    end
end