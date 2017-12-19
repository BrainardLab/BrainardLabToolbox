function qpQuestPlusColorMaterialQuadModelDemo
% Demonstrate/test QUEST+ at work on the color material model, quadratic
%
% Description:
%    This script shows QUEST+ employed to estimate the parameters of the
%    quadratic version of the color material model.

% 12/19/17  dhb, ar  Created.

%% Close out stray figures
close all;

%% Change to our pwd
cd(fileparts(mfilename('fullpath')));

%% We need the lookup table.  Load it.
theLookupTable = load('../colorMaterialInterpolateFunLineareuclidean');

%% Define psychometric function in terms of lookup table
qpPFFun = @(stimParams,psiParams) qpPFColorMaterialQuadModel(stimParams,psiParams,theLookupTable.colorMaterialInterpolatorFunction);

%% Initialize three QUEST+ structures
%
% Each one has a different upper end of stimulus regime
% The last of these should be the most inclusive, and
% include stimuli that could come from any of them.
DO_INITIALIZE = false;
if (DO_INITIALIZE)
    stimUpperEnds = [1 2 3];
    nQuests = length(stimUpperEnds);
    for qq = 1:nQuests
        fprintf('Initializing quest structure %d\n',qq)
        qTemp = qpParams( ...
            'qpPF',qpPFFun, ...
            'stimParamsDomainList',{-stimUpperEnds(qq):stimUpperEnds(qq), -stimUpperEnds(qq):stimUpperEnds(qq), -stimUpperEnds(qq):stimUpperEnds(qq), -stimUpperEnds(qq):stimUpperEnds(qq)}, ...
            'psiParamsDomainList',{[1/6 0.5 1 2 6] [-1 0 1] [1/6 0.5 1 2 6] [-1 0 1] [0.05:0.15:0.95]} ...
            );
        questData{qq} = qpInitialize(qTemp);
    end
    
    %% Define a questStructure that has all the stimuli
    %
    % We use this as a simple way to account for every
    % stimulus in the analysis at the end.
    questDataAllTrials = questData{end};
    
    %% Save out initialized quests
    save(fullfile(tempdir,'initalizedQuests'),'questData','questDataAllTrials');
    
    % Load in saved initialized thingy's
else
    load(fullfile(tempdir,'initalizedQuests'),'questData','questDataAllTrials');
end

%% Set up simulated observer function
simulatedPsiParams = [2 0.2 0.7 -0.3 0.8];
simulatedObserverFun = @(x) qpSimulatedObserver(x,qpPFFun,simulatedPsiParams);

%% Run multiple simulations
nSimulations = 1;
nTrialsPerQuest = 30;
questOrderIn = [0 0 1 2 3 3 3 3];
histFigure = figure; clf;
for ss = 1:nSimulations
    % Load in the initialized quest structures
    fprintf('Simulation %d of %d\n',ss,nSimulations);
    clear questData questDataAllTrials
    load(fullfile(tempdir,'initalizedQuests'));
    
    % Run simulated trials, using QUEST+ to tell us what contrast to
    %
    % Define how many of each type of trial selection we'll do each time through.
    % 0 -> choose at random from all trials.
    for tt = 1:nTrialsPerQuest
        fprintf('\tTrial block %d of %d\n',tt,nTrialsPerQuest');
        
        % Set the order for the specified quests and random
        questOrder = randperm(length(questOrderIn));
        for qq = 1:length(questOrder)
            theQuest = questOrderIn(questOrder(qq));
            
            % Get stimulus for this trial, either from one of the quests or at random.
            if (theQuest > 0)
                stim = qpQuery(questData{theQuest});
            else
                nStimuli = size(questDataAllTrials.stimParamsDomain,1);
                stim = questDataAllTrials.stimParamsDomain(randi(nStimuli),:);
            end
            
            % Simulate outcome
            outcome = simulatedObserverFun(stim);
            
            % Update quest data structure, if not a randomly inserted trial
            tic
            if (theQuest > 0)
                questData{theQuest} = qpUpdate(questData{theQuest},stim,outcome);
            end
            
            % This data structure tracks all of the trials run in the
            % experiment.  We never query it to decide what to do, but we
            % will use it to fit the data at the end.
            questDataAllTrials = qpUpdate(questDataAllTrials,stim,outcome);
            toc
        end
    end
    
    % Find out QUEST+'s estimate of the stimulus parameters, obtained
    % on the gridded parameter domain.
    psiParamsIndex = qpListMaxArg(questDataAllTrials.posterior);
    psiParamsQuest(ss,:) = questDataAllTrials.psiParamsDomain(psiParamsIndex,:);
    fprintf('Simulated parameters: %0.1f, %0.1f, %0.1f, %0.1f, %0.2f\n', ...
        simulatedPsiParams(1),simulatedPsiParams(2),simulatedPsiParams(3),simulatedPsiParams(4),simulatedPsiParams(5));
    fprintf('Max posterior QUEST+ parameters: %0.1f, %0.1f, %0.2f, %0.1f, %0.2f\n', ...
        psiParamsQuest(ss,1),psiParamsQuest(ss,2),psiParamsQuest(ss,3),psiParamsQuest(ss,4),psiParamsQuest(ss,5));
    
    % Maximum likelihood fit.  Use psiParams from QUEST+ as the starting
    % parameter for the search, and impose as parameter bounds the range
    % provided to QUEST+.
    psiParamsFit(ss,:) = qpFit(questDataAllTrials.trialData,questDataAllTrials.qpPF,psiParamsQuest(ss,:),questDataAllTrials.nOutcomes,...
        'lowerBounds', [-5 -1 -5 -1 0],'upperBounds',[5 1 5 1 1]);
    fprintf('Maximum likelihood fit parameters: %0.1f, %0.1f, %0.2f, %0.1f, %0.2f\n', ...
        psiParamsFit(ss,1),psiParamsFit(ss,2),psiParamsFit(ss,3),psiParamsFit(ss,4),psiParamsFit(ss,5));
    fprintf('\n');
    
    % Make a histogram of the fit parameters
    figure(histFigure); clf;
    subplot(1,3,1); hold on;
    hist(psiParamsFit(:,1));
    plot(simulatedPsiParams(1),2,'r*','MarkerSize',12);
    xlim([0 5]);
    xlabel('First Slope');
    ylabel('Count');
    
    subplot(1,3,2); hold on;
    hist(psiParamsFit(:,2));
    plot(simulatedPsiParams(2),2,'r*','MarkerSize',12);
    xlim([0 5]);
    xlabel('Second Slope');
    ylabel('Count');
    
    subplot(1,3,3); hold on;
    hist(psiParamsFit(:,5));
    plot(simulatedPsiParams(5),2,'r*','MarkerSize',12);
    xlim([0 1]);
    xlabel('Weight');
    ylabel('Count');
    drawnow;
end

%% Save
save qpQuestPlusColorMaterialModelDemo

%% Plot for last run
%
% Point transparancy visualizes number of trials (more opaque -> more
% trials), while point color visualizes dominant response.  The proportion plotted
% for each angle is the proportion of the dominant response.  This isn't as fancy
% as the Mathematica plot showin in Figure 17 of the paper, but conveys the same
% general idea of what happened.
figure; clf; hold on
stimCounts = qpCounts(qpData(questDataAllTrials.trialData),questDataAllTrials.nOutcomes);
stimProportions = qpProportions(stimCounts,questDataAllTrials.nOutcomes);
stim = zeros(length(stimCounts),questDataAllTrials.nStimParams);
for cc = 1:length(stimCounts)
    stim(cc,:) = stimCounts(cc).stim;
    nTrials(cc) = sum(stimCounts(cc).outcomeCounts);
end
for cc = 1:length(stimCounts)
    % Connect color and material match points.
    h = plot3([stim(cc,1) stim(cc,2)],[stim(cc,2) stim(cc,4)],[0 1],'-','LineWidth',3,'Color',[stimProportions(cc).outcomeProportions(1) 1-stimProportions(cc).outcomeProportions(1) 0]);
    
    % Plot the color match point as a square. Red versus green indictes proportion of color match points chosen,
    % transparency indicates number of trials.
    scatter3(stim(cc,1),stim(cc,3),0,100,'s', ...
        'MarkerEdgeColor',[stimProportions(cc).outcomeProportions(1) 1-stimProportions(cc).outcomeProportions(1) 0], ...
        'MarkerFaceColor',[stimProportions(cc).outcomeProportions(1) 1-stimProportions(cc).outcomeProportions(1) 0], ...
        'MarkerFaceAlpha',nTrials(cc)/max(nTrials),'MarkerEdgeAlpha',nTrials(cc)/max(nTrials));
    
    % Plot the material point as a circle.Red versus green indictes proportion of color match points chosen,
    % transparency indicates number of trials.
    scatter3(stim(cc,2),stim(cc,4),1,100,'o', ...
        'MarkerEdgeColor',[stimProportions(cc).outcomeProportions(1) 1-stimProportions(cc).outcomeProportions(1) 0], ...
        'MarkerFaceColor',[stimProportions(cc).outcomeProportions(1) 1-stimProportions(cc).outcomeProportions(1) 0], ...
        'MarkerFaceAlpha',nTrials(cc)/max(nTrials),'MarkerEdgeAlpha',nTrials(cc)/max(nTrials));
end
xlim([-3 3]);
ylim([-3 3]);
zlim([0 1]);
xlabel('Color Coordinate');
ylabel('Material Coordinate');
zlabel('Stim Indicator');
title({'Color Material Model',''});
drawnow;

%% Plot of posterior entropy versus trial number
figure; clf; hold on
plot(questDataAllTrials.entropyAfterTrial,'ro','MarkerSize',8,'MarkerFaceColor','r');
ylim([0 ceil(max(questDataAllTrials.entropyAfterTrial))]);
xlabel('Trial Number')
ylabel('Entropy')
title({'Color Material Model',''});

%% Plot some cuts through the QUEST+ posterior
%
% Posterior versus material slope and weight
figure; clf; hold on;
index1 = find(questDataAllTrials.psiParamsDomain(:,1) == psiParamsQuest(end,1));
posterior1 = questDataAllTrials.posterior(index1);
plotX = questDataAllTrials.psiParamsDomainList{2};
plotY = questDataAllTrials.psiParamsDomainList{5};
plotZ = reshape(posterior1,length(plotY),length(plotX));
surf(plotX',plotY',plotZ);
shading interp
xlabel('Material Coordinate Slope');
ylabel('Weight');
zlabel('Posterior');
title({'Color Material Model',''});
set(gca,'View',[20 80]);

% Posterior versus color slope and weight
figure; clf; hold on;
index1 = find(questDataAllTrials.psiParamsDomain(:,2) == psiParamsQuest(end,2));
posterior1 = questDataAllTrials.posterior(index1);
plotX = questDataAllTrials.psiParamsDomainList{1};
plotY = questDataAllTrials.psiParamsDomainList{5};
plotZ = reshape(posterior1,length(plotY),length(plotX));
surf(plotX',plotY',plotZ);
shading interp
xlabel('Color Coordinate Slope');
ylabel('Weight');
zlabel('Posterior');
title({'Color Material Model',''});
set(gca,'View',[20 80]);

% Posterior versus color slope and material slope
figure; clf; hold on;
index1 = find(questDataAllTrials.psiParamsDomain(:,3) == psiParamsQuest(end,3));
posterior1 = questDataAllTrials.posterior(index1);
plotX = questDataAllTrials.psiParamsDomainList{1};
plotY = questDataAllTrials.psiParamsDomainList{2};
plotZ = reshape(posterior1,length(plotY),length(plotX));
surf(plotX',plotY',plotZ);
shading interp
xlabel('Color Coordinate Slope')
ylabel('Material Coordinate Slope');
zlabel('Posterior');
title({'Color Material Model',''});
set(gca,'View',[20 80]);





