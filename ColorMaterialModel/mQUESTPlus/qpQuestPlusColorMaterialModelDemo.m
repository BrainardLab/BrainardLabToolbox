function qpQuestPlusColorMaterialModelDemo
%qpQuestPlusCircularCatDemo  Demonstrate/test QUEST+ at work on the color material model.
%
% Description:
%    This script shows QUEST+ employed to estimate the parameters of the linear
%    version of the color material model.

% 07/08/17  dhb  Created.

%% Close out stray figures
close all;

%% We need the lookup table.  Load it.
theLookupTable = load('../colorMaterialInterpolateFunLineareuclidean');

%% Define psychometric function in terms of lookup table
qpPFFun = @(stimParams,psiParams) qpPFColorMaterialModel(stimParams,psiParams,theLookupTable.colorMaterialInterpolatorFunction);

%% qpRun estimating color material model parameters.
fprintf('*** qpRun, Estimate color material parameters:\n');
rng(3010);
simulatedPsiParams = [-2 1 0.2];
questData = qpRun(128, ...
    'stimParamsDomainList',{-3:3, -3:3, -3:3, -3:3}, ...
    'psiParamsDomainList',{-5:1:5 -5:1:5 0:0.2:1}, ...
    'qpPF',qpPFFun, ...
    'qpOutcomeF',@(x) qpSimulatedObserver(x,qpPFFun,simulatedPsiParams), ...
    'nOutcomes', 2, ...
    'chooseRule','randomFromBestN','chooseRuleN',3, ...
    'verbose',true);
psiParamsIndex = qpListMaxArg(questData.posterior);
psiParamsQuest = questData.psiParamsDomain(psiParamsIndex,:);
fprintf('Simulated parameters: %0.1f, %0.1f, %0.1f\n', ...
    simulatedPsiParams(1),simulatedPsiParams(2),simulatedPsiParams(3));
fprintf('Max posterior QUEST+ parameters: %0.1f, %0.1f, %0.1f\n', ...
    psiParamsQuest(1),psiParamsQuest(2),psiParamsQuest(3));
% psiParamsCheck = [30000 20944 38397];
% assert(all(psiParamsCheck == round(10000*psiParamsQuest)),'No longer get same QUEST+ estimate for this case');

% Maximum likelihood fit.  Use psiParams from QUEST+ as the starting
% parameter for the search, and impose as parameter bounds the range
% provided to QUEST+.
psiParamsFit = qpFit(questData.trialData,questData.qpPF,psiParamsQuest,questData.nOutcomes,...
    'lowerBounds', [-5 -5 0],'upperBounds',[5 5 1]);
fprintf('Maximum likelihood fit parameters: %0.1f, %0.1f, %0.1f\n', ...
    psiParamsFit(1),psiParamsFit(2),psiParamsFit(3));
% psiParamsCheck = [38831 21951 37488];
% assert(all(psiParamsCheck == round(10000*psiParamsFit)),'No longer get same ML estimate for this case');
 
%% Plot trial locations
%
% Point transparancy visualizes number of trials (more opaque -> more
% trials), while point color visualizes dominant response.  The proportion plotted
% for each angle is the proportion of the dominant response.  This isn't as fancy
% as the Mathematica plot showin in Figure 17 of the paper, but conveys the same
% general idea of what happened.
figure; clf; hold on
stimCounts = qpCounts(qpData(questData.trialData),questData.nOutcomes);
stimProportions = qpProportions(stimCounts,questData.nOutcomes);
stim = zeros(length(stimCounts),questData.nStimParams);
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
xlabel('Color Cooridnate');
ylabel('Material Coordinate');
zlabel('Stim Indicator');
title({'Color Material Model',''});
drawnow;

%% Plot of posterior entropy versus trial number
figure; clf; hold on
plot(questData.entropyAfterTrial,'ro','MarkerSize',8,'MarkerFaceColor','r');
ylim([0 ceil(max(questData.entropyAfterTrial))]);
xlabel('Trial Number')
ylabel('Entropy')
title({'Color Material Model',''});

%% Plot some cuts through the QUEST+ posterior
%
% Posterior versus material slope and weight
figure; clf; hold on;
index1 = find(questData.psiParamsDomain(:,1) == psiParamsQuest(1));
posterior1 = questData.posterior(index1);
plotX = questData.psiParamsDomainList{2};
plotY = questData.psiParamsDomainList{3};
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
index1 = find(questData.psiParamsDomain(:,2) == psiParamsQuest(2));
posterior1 = questData.posterior(index1);
plotX = questData.psiParamsDomainList{1};
plotY = questData.psiParamsDomainList{3};
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
index1 = find(questData.psiParamsDomain(:,3) == psiParamsQuest(3));
posterior1 = questData.posterior(index1);
plotX = questData.psiParamsDomainList{1};
plotY = questData.psiParamsDomainList{2};
plotZ = reshape(posterior1,length(plotY),length(plotX));
surf(plotX',plotY',plotZ);
shading interp
xlabel('Color Coordinate Slope')
ylabel('Material Coordinate Slope');
zlabel('Posterior');
title({'Color Material Model',''});
set(gca,'View',[20 80]);





