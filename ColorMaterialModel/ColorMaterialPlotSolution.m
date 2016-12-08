function ColorMaterialPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, returnedParams, params,  figDir, saveFig)
% function ColorMaterialPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, returnedParams, params,  figDir, saveFig)
%

% Unpack passed params. Set tolerance for recovered target position. 
[returnedMaterialMatchColorCoords,returnedColorMatchMaterialCoords,returnedW,returnedSigma]  = ColorMaterialModelXToParams(returnedParams, params); 

%% Figure 1. Plot measured vs. predicted probabilities
figure; hold on
plot(theDataProb(:),predictedProbabilitiesBasedOnSolution(:),'ro','MarkerSize',12,'MarkerFaceColor','r');
%     case 'demo'
%         plot(theDataProb(:),probabilitiesComputedForSimulatedData(:),'bo','MarkerSize',12,'MarkerFaceColor','b');
%         legend('Fit Parameters', 'Actual Parameters', 'Location', 'NorthWest')
%     otherwise
legend('Fit Parameters', 'Location', 'NorthWest')

line([0, 1], [0,1], 'color', 'k'); 
axis('square')
axis([0 1 0 1]);
set(gca,  'FontSize', 18);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);
if saveFig
    cd(figDir)
    saveFigure([params.subjectName, 'MeasuredVsPredictedProb'], 'pdf'); 
end

%% Prepare for figure 2. Fit cubic spline to the data
% We do this separately for color and material dimension
xMinTemp = floor(min([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))-0.5; 
xMaxTemp = ceil(max([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))+0.5;
xTemp = max(abs([xMinTemp xMaxTemp]));
xMin = -xTemp;
xMax = xTemp;
yMin = xMin; 
yMax = xMax;

splineOverX = linspace(xMin,xMax,1000);
splineOverX(splineOverX>max(params.materialMatchColorCoords))=NaN;
splineOverX(splineOverX<min(params.materialMatchColorCoords))=NaN; 
% We fit a cubic spline to the data for both color and material. 
ppColor = spline(params.materialMatchColorCoords, returnedMaterialMatchColorCoords);
ppMaterial = spline(params.colorMatchMaterialCoords, returnedColorMatchMaterialCoords);

% We evaluate this function at all values of X we're interested in. 
inferredPositionsColor = ppval(splineOverX,ppColor); 
inferredPositionsMaterial  = ppval(splineOverX,ppMaterial); 

% We do the same thing, just using the interp1 function, to make the plots
% less wavy. In Figure 2 we plot the interp1 values. 
inferredPositionsColorInterp = interp1(params.materialMatchColorCoords, returnedMaterialMatchColorCoords,splineOverX); 
inferredPositionsMaterialInterp  = interp1(params.colorMatchMaterialCoords, returnedColorMatchMaterialCoords,splineOverX); 

%% Figure 2. Plot positions from fit versus actual simulated positions 
figure; 
subplot(1,2,1); hold on % plot of material positions
plot(params.materialMatchColorCoords,returnedMaterialMatchColorCoords,'ro',splineOverX, inferredPositionsColorInterp, 'r');
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', 1, 'color', [0.5 0.5 0.5]);
title('Color dimension')
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', 18);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', 18);

% Set large range of values for fittings
subplot(1,2,2); hold on % plot of material positions
title('Material dimension')
plot(params.colorMatchMaterialCoords,returnedColorMatchMaterialCoords,'bo',splineOverX,inferredPositionsMaterialInterp, 'b');
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', 1, 'color', [0.5 0.5 0.5]);
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', 18);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', 18);
if saveFig
    saveFigure([params.subjectName, 'RecoveredPositionsSpline'], 'pdf'); 
end
%% Plot the color and material of the stimuli obtained from the fit in the 2D representational space
figure; hold on; 
plot(returnedMaterialMatchColorCoords, zeros(size(returnedMaterialMatchColorCoords)),'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 12); 
line([xMin, xMax], [0,0],'color', 'k'); 
plot(zeros(size(returnedColorMatchMaterialCoords)), returnedColorMatchMaterialCoords, 'bo','MarkerFaceColor', 'b', 'MarkerSize', 12); 
axis([xMin, xMax,yMin, yMax])
line([0,0],[yMin, yMax],  'color', 'k'); 
axis('square')
xlabel('color positions', 'FontSize', 18);
ylabel('material positions','FontSize', 18);
if saveFig
    saveFigure([params.subjectName, 'RecoveredPositions2D'], 'pdf'); 
end
%% Figure 3. Plot descriptive Weibull fits to the data. Optional. 
if params.plotWeibullFitsToData
    for i = 1:size(theDataProb,2);
        if i == 4
            fixMidPoint = 1;
        else
            fixMidPoint = 0;
        end
        [theSmoothPreds(:,i), theSmoothVals(:,i)] = ColorMaterialModelGetValuesFromFits(theDataProb(:,i)',params.materialMatchColorCoords, fixMidPoint);
        [theSmoothPreds2(:,i), theSmoothVals2(:,i)] = ColorMaterialModelGetValuesFromFits(1-theDataProb(i,:),params.colorMatchMaterialCoords, fixMidPoint);
    end
    ColorMaterialModelPlotFits(theSmoothVals, theSmoothPreds, params.colorMatchMaterialCoords, theDataProb);
   ColorMaterialModelPlotFits(theSmoothVals2, theSmoothPreds2, materialMatchColorCoords, 1-theDataProb');
end
if saveFig
    saveFigure([params.subjectName, 'WeibullFitColorXAxis'], 'pdf'); 
end
%% Plot predictions of the model through the actual data 
%
% First check the positions of color (material) match on color (material) axis.  
% Signal if there is an error. 
returnedMaterialMatchMaterialCoord = ppval(params.targetMaterialCoord, ppMaterial);
returnedColorMatchColorCoord =  ppval(params.targetColorCoord, ppColor);

% Find the predicted probabilities for a range of possible color coordinates 
rangeOfMaterialMatchColorCoordinates = linspace(min(params.materialMatchColorCoords), max(params.materialMatchColorCoords), 100)';

% Loop over each material coordinate of the color match, to get a predicted
% curve for each one.
for whichMaterialCoordinate = 1:length(params.colorMatchMaterialCoords)

    % Get the inferred material position for this color match
    % Note that this is read from cubic spline fit.  
    returnedColorMatchMaterialCoord(whichMaterialCoordinate) = ppval(params.colorMatchMaterialCoords(whichMaterialCoordinate), ppMaterial);
    
    % Get the inferred color position for a range of material matches
    for whichColorCoordinate = 1:length(rangeOfMaterialMatchColorCoordinates)
        % Get the position of the material match 
        % To avoid a wavy spline, here we use interp1 
        returnedMaterialMatchColorCoord(whichColorCoordinate) = interp1(params.materialMatchColorCoords, returnedColorMatchMaterialCoords, rangeOfMaterialMatchColorCoordinates(whichColorCoordinate));
                
        % Compute the model predictions
        modelPredictions(whichColorCoordinate, whichMaterialCoordinate) = ColorMaterialModelComputeProb(params.targetColorCoord,params.targetMaterialCoord, ...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord, returnedW, returnedSigma);
    end
end
rangeOfMaterialMatchColorCoordinates = repmat(rangeOfMaterialMatchColorCoordinates,[1, length(params.materialMatchColorCoords)]);
ColorMaterialModelPlotFits(rangeOfMaterialMatchColorCoordinates, modelPredictions, params.materialMatchColorCoords, theDataProb, min(params.materialMatchColorCoords)-0.5, max(params.materialMatchColorCoords)+0.5);
if saveFig
    saveFigure([params.subjectName, 'ModelFitColorXAxis'], 'pdf');
end
end