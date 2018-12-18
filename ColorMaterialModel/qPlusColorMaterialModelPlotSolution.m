function [colorSlope, materialSlope] = qPlusColorMaterialModelPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, nTrialsPerPair, returnedModelParams,...
    params, figDir, saveFigs, colorMaterialData)
% qPlusColorMaterialModelPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, returnedModelParams,...
%    indexMatrix, params, figDir, saveFig, weibullplots, actualProbs)
% Plot model solution for the experiments that use qPlus in stimulus
% selection. 
%
% Outputs: 
% colorSlope - the slope of positions of the stimuli on the color
%               dimension (model solution) vs. nominal color positions
% materialSlope - the slope of positions of the stimuli on the material
%               dimension (model solution) vs. nominal color positions 
% Inputs:
%   theDataProb - the data probabilities measured in the experiment
%   predictedProbabilitiesBasedOnSolution - predictions based on solutions
%   nTrialsPerPair - number of trials for each pair for which we have
%                    measured/predicted probability
%   returnedModelParams - returned model parameters
%   params -  standard experiment specifications structure
%   figDir -  specify figure directory
%   saveFigs - save intermediate figures? main figure is going to be saved by default. 
%              This option is obsolete, but we want to keep that flag for just 
%              in case we change how we plot the data.    
%   colorMaterialData - measuredProbabilities for color-material functions (importnat:
%            rows are color levels (M0), columns are material levels (C0) 
%
% 05/30/18 ar Adapted the previous color-material model code for the
%               qPlus implementation
% 07/11/18 ar Added the color-material data matrix, extracted from qPlus data 

% Close all open figures; 
close all; 

% Move to the directory in which we will save figures. 
cd (figDir)
% Set plot parameters. 
% Note: parameters this small will not look nice in single figures, but will
% look nice in the main combo-figure. 
thisFontSize = 6; 
thisMarkerSize = 6; 
thisLineWidth = 1; 

% Unpack model parameters.  
[returnedMaterialMatchColorCoords,returnedColorMatchMaterialCoords,returnedW, returnedSigma]  = ColorMaterialModelXToParams(returnedModelParams, params); 

% Check that the solution is valid: if the minimal enforced step is
% enforced, if the solution is monotonic (in terms of returned positions)
tolerance = 1e-4; 
minimalEnforcedStep = (params.sigma/params.sigmaFactor)-tolerance;  
if (any(diff(returnedMaterialMatchColorCoords) < minimalEnforcedStep)) || (any(diff(returnedColorMatchMaterialCoords) < minimalEnforcedStep))
    error('Either minimal step or monotonicity constraint are not enforced.');
end
if size(returnedMaterialMatchColorCoords,2)==7
    colorSlope = regress(returnedMaterialMatchColorCoords', params.colorMatchMaterialCoords');
    materialSlope = regress(returnedColorMatchMaterialCoords', params.materialMatchColorCoords');
else
    colorSlope = regress(returnedMaterialMatchColorCoords, params.colorMatchMaterialCoords');
    materialSlope = regress(returnedColorMatchMaterialCoords, params.materialMatchColorCoords');
end

%% Figure 1. Plot measured vs. predicted probabilities
figure; hold on
index = find(nTrialsPerPair > 1); % Only plot trials that have been repeated more than once.  
scatter(theDataProb(index), predictedProbabilitiesBasedOnSolution(index)',nTrialsPerPair(index), 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
line([0, 1], [0,1], 'color', 'k');
axis('square'); axis([0 1 0 1]);
set(gca,  'FontSize', thisFontSize);
xlabel('Measured proportions');
ylabel('Predicted proportions');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);
% Set position of this figure in the main figure. 
ax(2)=gca;

% Prepare values for figure 2. Fit cubic spline to the data
% We do this separately for color and material dimension
xMin = -params.maxPositionValue;
xMax = params.maxPositionValue;
yMin = -params.maxPositionValue; 
yMax = params.maxPositionValue;

splineOverX = linspace(xMin,xMax,1000);
splineOverX(splineOverX>max(params.materialMatchColorCoords)) = NaN;
splineOverX(splineOverX<min(params.materialMatchColorCoords)) = NaN; 

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
plot(params.colorMatchMaterialCoords,returnedColorMatchMaterialCoords,'bo')
plot(splineOverX,inferredPositionsMaterial, 'b', 'MarkerSize', thisMarkerSize);
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
%title('Color dimension')
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('Color/Material "true" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);

%% Plot the color and material of the stimuli obtained from the fit in the 2D representational space
f2 = figure; hold on; 
blue = [28, 134, 238]./255; 
red = [238, 59, 59]./255; 
green = [34, 139, 34]./255.*1.2; 
stepColors = {red, green, blue, 'k', blue, green, red};
for i = 1:length(returnedMaterialMatchColorCoords)
    if i > 3
        plot(returnedMaterialMatchColorCoords(i), zeros(size(returnedMaterialMatchColorCoords(i))),'o', ...
            'MarkerFaceColor', stepColors{i}, 'MarkerEdgeColor', stepColors{i}, 'MarkerSize', thisMarkerSize, 'LineWidth', thisLineWidth);
        plot(zeros(size(returnedColorMatchMaterialCoords(i))), returnedColorMatchMaterialCoords(i), 'o',...
            'MarkerFaceColor', stepColors{i}, 'MarkerEdgeColor', stepColors{i}, 'MarkerSize', thisMarkerSize, 'LineWidth', thisLineWidth);
    else
        plot(returnedMaterialMatchColorCoords(i), zeros(size(returnedMaterialMatchColorCoords(i))),'o', ...
            'MarkerEdgeColor', stepColors{i}, 'MarkerSize', thisMarkerSize, 'LineWidth', thisLineWidth);
        plot(zeros(size(returnedColorMatchMaterialCoords(i))), returnedColorMatchMaterialCoords(i), 'o',...
            'MarkerEdgeColor', stepColors{i}, 'MarkerSize', thisMarkerSize, 'LineWidth', thisLineWidth);
    end
end
axis([xMin, xMax,yMin, yMax])
line([xMin, xMax], [0,0],'color', 'k');    
line([0,0],[yMin, yMax],  'color', 'k'); 
axis('square')
xlabel('Color', 'FontSize', thisFontSize);
ylabel(['Observer ' params.subjectName; '  Material  '],'FontSize', thisFontSize);
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisMarkerSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisMarkerSize);
ax(1)=gca;

%% Plot predictions of the model through the actual data

% These are the target color and material coordinates. 
returnedColorMatchColorCoord =  FColor(params.targetColorCoord);
returnedMaterialMatchMaterialCoord = FMaterial(params.targetMaterialCoord);

% Find the predicted probabilities for a range of possible color coordinates
% (for when we plot a range of color variation values for a fixed material level).  
rangeOfMaterialMatchColorCoordinates =  linspace(min(params.materialMatchColorCoords), max(params.materialMatchColorCoords), 100)';

% Find the predicted probabilities for a range of possible material coordinates
% (when we plot the range of material variations for a fixed color level) 
rangeOfColorMatchMaterialCoordinates =  linspace(min(params.colorMatchMaterialCoords), max(params.colorMatchMaterialCoords), 100)';

% Plot for the material match vs. color match 
% Loop over each material coordinate of the color match to get a predicted curve for each one.
for whichMaterialCoordinate = 1:length(params.colorMatchMaterialCoords)
    
    % Get the inferred material position for the color match of fixed
    % material level (read from cubic spline fit).
    returnedColorMatchMaterialCoord(whichMaterialCoordinate) = FMaterial(params.colorMatchMaterialCoords(whichMaterialCoordinate));
    
    % Get the inferred color position for a range of material matches that
    % can take range of different values on color dimension. 
    for whichColorCoordinate = 1:length(rangeOfMaterialMatchColorCoordinates)
        % Get the position of the material match using our FColor function
        returnedMaterialMatchColorCoord(whichColorCoordinate) = FColor(rangeOfMaterialMatchColorCoordinates(whichColorCoordinate));
        
        % Compute the model predictions
        modelPredictions(whichColorCoordinate, whichMaterialCoordinate) = ColorMaterialModelGetProbabilityFromLookupTable(params.F,...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord,returnedW);
    end
end
rangeOfMaterialMatchColorCoordinates = repmat(rangeOfMaterialMatchColorCoordinates,[1, length(params.materialMatchColorCoords)]);

% We can either not plot color-material data or we can include then in the graph 
if isempty (colorMaterialData)
    [thisFig3, thisAxis3] = ColorMaterialModelPlotFitNoData(rangeOfMaterialMatchColorCoordinates, modelPredictions, params.materialMatchColorCoords, ...
        'whichMatch', 'colorMatch', 'whichFit', 'MLDS','returnedWeight', returnedW, ...
        'fontSize', thisFontSize, 'lineWidth', thisLineWidth);
else
    [thisFig3, thisAxis3] = ColorMaterialModelPlotFit(rangeOfMaterialMatchColorCoordinates, modelPredictions, params.materialMatchColorCoords, colorMaterialData, ...
        'whichMatch', 'colorMatch', 'whichFit', 'MLDS','returnedWeight', returnedW, ...
        'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
end
ax(3)=thisAxis3;
%FigureSave([params.subjectName, 'ModelFitColorXAxis'], thisFig3, 'pdf');

% Combine all figures into a combo-figure.
nImagesPerRow = 3;
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
    if i > 2
        axis([params.colorMatchMaterialCoords(1) params.colorMatchMaterialCoords(end) 0 1.05])
        set(gca, 'XTick', [-3:3])
    elseif i == 2
        axis([0 1.05 0 1.05])
    end
    %text(-30, 23, 'A')
    if i == 1
        text(-19, 21, ['w = ' num2str(round(returnedW,2))])
    end
    %text(24, 23, 'B')
    %text(77.5, 23, 'C')
end
FigureSave([params.subjectName, 'Main'], gcf, 'pdf');
%fixed weight option
%FigureSave([params.subjectName, num2str(round(returnedW,2)) 'Main'], gcf, 'pdf');

end