function MLDSColorSelectionPlot(thePairs,theResponses,nTrialsPerPair,targetCompetitorFit,predictedResponses, saveFig)
% function MLDSColorSelectionPlot(thePairs,theResponses,nTrialsPerPair,targetCompetitorFit,predictedResponses)
%
% Plots the inferred position of the target and all the competitors. 
% If the theoretical probabilities are passed, they are plotted against the actual probabilities
% computed from the data. 
%
%
% 5/3/12  dhb  Optional scatterplot of theory against measurements.
% 6/12/13 ar   Changed function names and added comments. 
% 4/07/14 ar   Option to save the figures. 
% 7/27/14 dhb  Update savefig to use more portable FigureSave.

% Plot theoretical vs. actual probabilities? 
if (nargin < 5 || isempty(predictedResponses))
    SCATTERPLOT = 0;
else
    SCATTERPLOT = 1;
end

% Display data and the fits. 
theData = [thePairs theResponses./nTrialsPerPair];
fprintf('\n Target data set\n');
%disp(theData); 
fprintf('\n Target fits\n');
%disp(targetCompetitorFit);  

% Plot the inferred position of the target and the competitors. 
f = figure; clf;
if (SCATTERPLOT)
    subplot(1,2,1);  hold on
end
set(gca,  'FontSize', 12);
axis([0 6 0 max(targetCompetitorFit)]);
plot(1:length(targetCompetitorFit(2:end)),targetCompetitorFit(2:end),'ro','MarkerSize',8,'MarkerFaceColor','r');
plot(1:length(targetCompetitorFit(2:end)),targetCompetitorFit(1)*ones(size(targetCompetitorFit(2:end))),'k','LineWidth',2);
title(sprintf('Inferred Target Position'));
set(gca, 'xTick', [0:6]); 
xlabel('Competitor #');
ylabel('Representation');
axis('square');

% Compute the probabilities from the data.  
% Plot them vs. predicted probabilites from the fit.  
if (SCATTERPLOT)
     subplot(1,2,2);  hold on
    theDataProb = theResponses./ nTrialsPerPair;
    plot(theDataProb,predictedResponses,'ro','MarkerSize',12,'MarkerFaceColor','r');
    plot([0 1],[0 1],'k');
    axis('square')
    axis([0 1 0 1]);
    set(gca,  'FontSize', 18);
   % title(sprintf('Quality of MLDS model'));
    xlabel('Measured p');
    ylabel('Predicted p');
    set(gca, 'xTick', [0, 0.5, 1]); 
    set(gca, 'yTick', [0, 0.5, 1]); 
end
if saveFig
    FigureSave('MLDSOutput', f, 'pdf');
end
end