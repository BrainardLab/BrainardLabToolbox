function ColorMaterialModelPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, ...
    modelParams, params, subjectName, conditionCode, figDir, saveFig, weibullplots, actualProbs)
% ColorMaterialModelPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, modelParams, params,  figDir, saveFig, weibullplots, actualProbs)
%
% Make a nice plot of the data and MLDS-based model fit.
%
% Inputs:
%   theDataProb - the data probabilities measured in the experiment
%   predictedProbabilitiesBasedOnSolution - predictions based on solutions
%   modelParams - set of model parameters
%   params - exp. specifications
%   subjectName - which subject to plot 
%   conditionCode - which condition to plot
%   figDir -  specify figure directory
%   saveFig - save figure or not
%   weibullplots - flag indicating whether to save weibullplots or not
%   actualProbs -  probabilities for actual parameters (ground truth) which
%                  we know when we do the simulation

% Unpack passed params. Set tolerance for recovered target position. 
[returnedMaterialMatchColorCoords,returnedColorMatchMaterialCoords,returnedW,returnedSigma]  = ColorMaterialModelXToParams(modelParams, params); 

%% Figure 1. Plot measured vs. predicted probabilities
% figure; hold on
% plot(theDataProb(:),predictedProbabilitiesBasedOnSolution(:),'ro','MarkerSize',12,'MarkerFaceColor','r');
% rmse = ComputeRealRMSE(theDataProb(:),predictedProbabilitiesBasedOnSolution(:)); 
% text(0.07, 0.87, sprintf('RMSEFit = %.4f', rmse), 'FontSize', 12); 
% 
% if nargin > 9
%     plot(theDataProb(:),actualProbs(:),'bo','MarkerSize',12,'MarkerFaceColor','b');
%     rmseComp = ComputeRealRMSE(theDataProb(:),actualProbs(:)); 
%     text(0.07, 0.82, sprintf('RMSEActual = %.4f', rmseComp), 'FontSize', 12); 
% 
%     legend('Fit Parameters', 'Actual Parameters', 'Location', 'NorthWest')
%     legend boxoff
% else
%     legend('Fit Parameters', 'Location', 'NorthWest')
%     legend boxoff
% end

thisFontSize = 12; 
line([0, 1], [0,1], 'color', 'k');
axis('square')
axis([0 1 0 1]);
set(gca,  'FontSize', thisFontSize);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);
if saveFig
    cd(figDir)
    FigureSave([subjectName, conditionCode, 'MeasuredVsPredictedProb'], gcf, 'pdf'); 
end

%% Prepare for figure 2. Fit cubic spline to the data
% We do this separately for color and material dimension
xMinTemp = floor(min([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))-0.5; 
xMaxTemp = ceil(max([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))+0.5;
xTemp = max(abs([xMinTemp xMaxTemp]));
% xMin = -xTemp;
% xMax = xTemp;
% yMin = xMin; 
% yMax = xMax;

yMin = -10; 
yMax = 10; 
xMin = -10; 
xMax = 10; 

splineOverX = linspace(xMin,xMax,1000);
splineOverX(splineOverX>max(params.materialMatchColorCoords))=NaN;
splineOverX(splineOverX<min(params.materialMatchColorCoords))=NaN; 

% Find a linear fit to the data for both color and material. 
FColor = griddedInterpolant(params.materialMatchColorCoords, returnedMaterialMatchColorCoords,'linear');
FMaterial = griddedInterpolant(params.colorMatchMaterialCoords, returnedColorMatchMaterialCoords,'linear');

% We evaluate this function at all values of X we're interested in. 
inferredPositionsColor = FColor(splineOverX); 
inferredPositionsMaterial  = FMaterial(splineOverX); 

%% Figure 2. Plot positions from fit versus actual simulated positions 
figure; 
subplot(1,2,1); hold on % plot of material positions
plot(params.materialMatchColorCoords,returnedMaterialMatchColorCoords,'ro',splineOverX, inferredPositionsColor, 'r');
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', 1, 'color', [0.5 0.5 0.5]);
title('Color dimension')
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);

% Set large range of values for fittings
subplot(1,2,2); hold on % plot of material positions
title('Material dimension')
plot(params.colorMatchMaterialCoords,returnedColorMatchMaterialCoords,'bo',splineOverX,inferredPositionsMaterial, 'b');
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', 1, 'color', [0.5 0.5 0.5]);
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
if saveFig
    FigureSave([subjectName, conditionCode, 'RecoveredPositionsSpline'], gcf, 'pdf'); 
end

%% Plot the color and material of the stimuli obtained from the fit in the 2D representational space
figure; hold on; 
plot(returnedMaterialMatchColorCoords, zeros(size(returnedMaterialMatchColorCoords)),'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 12); 
line([xMin, xMax], [0,0],'color', 'k'); 
plot(zeros(size(returnedColorMatchMaterialCoords)), returnedColorMatchMaterialCoords, 'bo','MarkerFaceColor', 'b', 'MarkerSize', 12); 
axis([xMin, xMax,yMin, yMax])
line([0,0],[yMin, yMax],  'color', 'k'); 
axis('square')
xlabel('color positions', 'FontSize', thisFontSize);
ylabel('material positions','FontSize', thisFontSize);
if saveFig
    FigureSave([subjectName, conditionCode, 'RecoveredPositions2D'], gcf, 'pdf'); 
end
%% Figure 3. Plot descriptive Weibull fits to the data. 
if weibullplots
    for i = 1:size(theDataProb,2);
        if i == 4
            fixMidPoint = 1;
        else
            fixMidPoint = 0;
        end
        
        % here we plot proportion of color match chosen for different color
        % -diffence steps of the material match.
        [theSmoothPreds(:,i), theSmoothVals(:,i)] = FitColorMaterialModelWeibull(theDataProb(:,i)',...
            params.materialMatchColorCoords, fixMidPoint);
        
        % this is the reverse fit: we're plotting the proportion of time
        % material match is chosen for different material-difference steps of
        % the color match.
        [theSmoothPredsReverseModel(:,i), theSmoothValsReverseModel(:,i)] = FitColorMaterialModelWeibull(1-theDataProb(i,:),...
            params.colorMatchMaterialCoords, fixMidPoint);
    end
    
    thisFig1 = ColorMaterialModelPlotFit(theSmoothVals, theSmoothPreds, params.colorMatchMaterialCoords, theDataProb,...
           'whichMatch', 'colorMatch', 'whichFit', 'weibull');
    thisFig2 = ColorMaterialModelPlotFit(theSmoothValsReverseModel, theSmoothPredsReverseModel, params.materialMatchColorCoords, 1-theDataProb', ...
          'whichMatch', 'materialMatch', 'whichFit', 'weibull');
    
    if saveFig
        FigureSave([subjectName, conditionCode, 'WeibullFitColorXAxis'], thisFig1, 'pdf');
        FigureSave([subjectName, conditionCode, 'WeibullFitMaterialXAxis'],thisFig2, 'pdf');
    end
end
%% Plot predictions of the model through the actual data
% Version 1: color for the x-axis
% First check the positions of color (material) match on color (material) axis.  
% Signal if there is an error.
returnedColorMatchColorCoord =  FColor(params.targetColorCoord);
returnedMaterialMatchMaterialCoord = FMaterial(params.targetMaterialCoord);

% Find the predicted probabilities for a range of possible color coordinates 
rangeOfMaterialMatchColorCoordinates =  linspace(min(params.materialMatchColorCoords), max(params.materialMatchColorCoords), 100)';
% Find the predicted probabilities for a range of possible material
% coordinates - for the reverse model.

rangeOfColorMatchMaterialCoordinates =  linspace(min(params.colorMatchMaterialCoords), max(params.colorMatchMaterialCoords), 100)';
% Loop over each material coordinate of the color match, to get a predicted
% curve for each one.

for whichMaterialCoordinate = 1:length(params.colorMatchMaterialCoords)

    % Get the inferred material position for this color match
    % Note that this is read from cubic spline fit.  
    returnedColorMatchMaterialCoord(whichMaterialCoordinate) = FMaterial(params.colorMatchMaterialCoords(whichMaterialCoordinate));
    
    % Get the inferred color position for a range of material matches
    for whichColorCoordinate = 1:length(rangeOfMaterialMatchColorCoordinates)
        % Get the position of the material match using our FColor function
        returnedMaterialMatchColorCoord(whichColorCoordinate) = FColor(rangeOfMaterialMatchColorCoordinates(whichColorCoordinate));
        
        % Compute the model predictions
        modelPredictions(whichColorCoordinate, whichMaterialCoordinate) = ColorMaterialModelComputeProb(params.targetColorCoord,params.targetMaterialCoord, ...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord, returnedW, returnedSigma);
        % Compute the model predictions
        
    end
end
rangeOfMaterialMatchColorCoordinates = repmat(rangeOfMaterialMatchColorCoordinates,[1, length(params.materialMatchColorCoords)]);
thisFig3 = ColorMaterialModelPlotFit(rangeOfMaterialMatchColorCoordinates, modelPredictions, params.materialMatchColorCoords, theDataProb, ...
    'whichMatch', 'colorMatch', 'whichFit', 'MLDS','returnedWeight', returnedW);

% Get values for reverse plotting
for whichColorCoordinate = 1:length(params.materialMatchColorCoords)

    % Get the inferred material position for this color match
    % Note that this is read from cubic spline fit.  
    returnedMaterialMatchColorCoord(whichColorCoordinate) = FColor(params.materialMatchColorCoords(whichColorCoordinate));
    
    % Get the inferred color position for a range of material matches
    for whichMaterialCoordinate = 1:length(rangeOfColorMatchMaterialCoordinates)
        % Get the position of the material match using our FColor function
        returnedColorMatchMaterialCoord(whichMaterialCoordinate) = FMaterial(rangeOfColorMatchMaterialCoordinates(whichMaterialCoordinate));
                
        % Compute the model predictions
        modelPredictions2(whichMaterialCoordinate, whichColorCoordinate) = 1-ColorMaterialModelComputeProb(params.targetColorCoord,params.targetMaterialCoord, ...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord, ...
            returnedW, returnedSigma);
    end
end
rangeOfColorMatchMaterialCoordinates = repmat(rangeOfColorMatchMaterialCoordinates,[1, length(params.colorMatchMaterialCoords)]);
thisFig4 = ColorMaterialModelPlotFit(rangeOfColorMatchMaterialCoordinates, modelPredictions2, params.colorMatchMaterialCoords, 1-theDataProb', ...
    'whichMatch', 'materialMatch', 'whichFit', 'MLDS','returnedWeight', returnedW);

 if saveFig
     FigureSave([subjectName, conditionCode, 'ModelFitColorXAxis'], thisFig3, 'pdf');
     FigureSave([subjectName, conditionCode, 'ModelFitMaterialXAxis'], thisFig4, 'pdf');
 end

end