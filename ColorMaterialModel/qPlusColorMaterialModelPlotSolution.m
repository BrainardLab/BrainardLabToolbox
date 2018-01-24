function ColorMaterialModelPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, returnedModelParams,...
    params, figDir, saveFigs)
% ColorMaterialModelPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, returnedModelParams,...
%    indexMatrix, params, figDir, saveFig, weibullplots, actualProbs)
% Make a nice plot of the data and MLDS-based model fit.
%
% Inputs:
%   theDataProb - the data probabilities measured in the experiment
%   predictedProbabilitiesBasedOnSolution - predictions based on solutions
%   returnedModelParams - returned model parameters
%   params -  standard experiment specifications structure
%   figDir -  specify figure directory
%   saveFigs - save intermediate figures? main figure is going to be saved by default. 

% 06/15/2017 ar Added comments and made small changes to the code. 

% Close all open figures; 
close all; 

% Reformat probabilities to look only at color/material tradeoff
% Indices that reformating is based on are saved in the data matrix
% that we loaded.
subjectName = params.subjectName; 
cd (figDir)

% tempFS= 20; 
% tempMS = 20; 
% tempLW = 3; 

% Unpack passed params.  
[returnedMaterialMatchColorCoords,returnedColorMatchMaterialCoords,returnedW,returnedSigma]  = ColorMaterialModelXToParams(returnedModelParams, params); 

% Set plot parameters. 
% Note: paramters this small will not look nice in single figures, but will
% look nice in the main combo-figure. 
thisFontSize = 6; 
thisMarkerSize = 6; 
thisLineWidth = 1; 

%% Figure 1. Plot measured vs. predicted probabilities
figure; hold on
plot(theDataProb, predictedProbabilitiesBasedOnSolution,'ro','MarkerSize',thisMarkerSize-2,'MarkerFaceColor','r');
rmse = ComputeRealRMSE(theDataProb,predictedProbabilitiesBasedOnSolution);
text(0.07, 0.92, sprintf('rmseFit = %.4f', rmse), 'FontSize', thisFontSize);
legend('Fit Parameters', 'Location', 'NorthWest')
legend boxoff
line([0, 1], [0,1], 'color', 'k');
axis('square'); axis([0 1 0 1]);
set(gca,  'FontSize', thisFontSize);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);
ax(1)=gca;

% Prepare for figure 2. Fit cubic spline to the data
% We do this separately for color and material dimension
xMin = -params.maxPositionValue;
xMax = params.maxPositionValue;
yMin = -params.maxPositionValue; 
yMax = params.maxPositionValue;

splineOverX = linspace(xMin,xMax,1000);
splineOverX(splineOverX>max(params.materialMatchColorCoords))=NaN;
splineOverX(splineOverX<min(params.materialMatchColorCoords))=NaN; 

% Find a cubic fit to the data for both color and material. 
FColor = griddedInterpolant(params.materialMatchColorCoords, returnedMaterialMatchColorCoords,'cubic');
FMaterial = griddedInterpolant(params.colorMatchMaterialCoords, returnedColorMatchMaterialCoords,'cubic');

% We evaluate this function at all values of X we're interested in. 
inferredPositionsColor = FColor(splineOverX); 
inferredPositionsMaterial  = FMaterial(splineOverX); 

%% Figure 2. Plot positions from fit versus actual simulated positions 
fColor = figure; hold on; 
plot(params.materialMatchColorCoords,returnedMaterialMatchColorCoords,'ro'); 
plot(splineOverX, inferredPositionsColor, 'r', 'MarkerSize', thisMarkerSize);
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
%title('Color dimension')
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('Color "true" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
ax(2)=gca;

%% Figure 2. Plot positions from fit versus actual simulated positions 
fMaterial = figure; hold on; 
plot(params.colorMatchMaterialCoords,returnedColorMatchMaterialCoords,'bo')
plot(splineOverX,inferredPositionsMaterial, 'b', 'MarkerSize', thisMarkerSize);
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
%title('Material dimension')
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('Material "true" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
ax(3)=gca;
if saveFigs
    FigureSave([subjectName, 'RecoveredPositionsSpline'], fColor, 'pdf'); 
    FigureSave([subjectName, 'RecoveredPositionsSpline'], fMaterial, 'pdf'); 
end

%% Plot the color and material of the stimuli obtained from the fit in the 2D representational space
f2 = figure; hold on; 
plot(returnedMaterialMatchColorCoords, zeros(size(returnedMaterialMatchColorCoords)),'ko', ...
    'MarkerFaceColor', 'k', 'MarkerSize', thisMarkerSize, 'LineWidth', thisLineWidth); 
line([xMin, xMax], [0,0],'color', 'k'); 
plot(zeros(size(returnedColorMatchMaterialCoords)), returnedColorMatchMaterialCoords, 'ko',...
    'MarkerFaceColor', 'k', 'MarkerSize', thisMarkerSize, 'LineWidth', thisLineWidth); 
axis([xMin, xMax,yMin, yMax])
line([0,0],[yMin, yMax],  'color', 'k'); 
axis('square')
xlabel('Color', 'FontSize', thisFontSize);
ylabel('Material','FontSize', thisFontSize);
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisMarkerSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisMarkerSize);
ax(4)=gca;

if saveFigs
    savefig(f2, [subjectName, 'RecoveredPositions2D.fig'])
    FigureSave([subjectName, 'RecoveredPositions2D'], f2, 'pdf'); 
end

% Combine all figures into a combo-figure.
nImagesPerRow = 2;
nImages = length(ax);
figure;
for i=1:nImages
    % Create and get handle to the subplot axes
    sPlot(i) = subplot(ceil(nImages/nImagesPerRow),nImagesPerRow,i);
    % Get handle to all the children in the figure
    aux=get(ax(i),'children');
    for j=1:size(aux)
        tmpFig(i) = aux(j);
        copyobj(tmpFig(i),sPlot(i));
        hold on
    end
    % Copy children to new parent axes i.e. the subplot axes
    xlabel(get(get(ax(i),'xlabel'),'string'));
    ylabel(get(get(ax(i),'ylabel'),'string'));
    title(get(get(ax(i),'title'),'string'));
    axis square
    if i > 4
        axis([params.colorMatchMaterialCoords(1) params.colorMatchMaterialCoords(end) 0 1.05])
    elseif i == 1
        axis([0 1.05 0 1.05])
    end
end
FigureSave([params.subjectName, 'Main'], gcf, 'pdf');
end