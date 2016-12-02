% PlotsWithSavedParams
%
% Plot out the results of a fit to simulated data, based on parameters
% we saved by hand after running a long demo fit.

%% Clear and close and load
clear; close all; 
DEMO = false; 
if DEMO
    load('returnedParamsTemp.mat')
else
    load('solutionIfjWFixed.mat');  materialMatchColorCoords = -3:3; colorMatchMaterialCoords = -3:3; targetColorCoord = 0; targetMaterialCoord = 0;
    simulatedProbabilities = theDataProb; 
end
plotWeibullFitsToData = 1; 

%% Plot measured vs. predicted probabilities
theDataProb = theResponsesFromSimulatedData./nTrials;
figure; hold on
if DEMO
    plot(theDataProb,predictedProbabilitiesBasedOnSolution,'ro','MarkerSize',12,'MarkerFaceColor','r');
    plot(theDataProb,probabilitiesComputedForSimulatedData,'bo','MarkerSize',12,'MarkerFaceColor','b');
else
    plot(theDataProb(:),predictedProbabilitiesBasedOnSolution(:),'ro','MarkerSize',12,'MarkerFaceColor','r');
end
line([0, 0], [1,1],'color','k'); 
if DEMO
    legend('Fit Parameters', 'Actual Parameters', 'Location', 'NorthWest')
else
    legend('Actual Parameters', 'Location', 'NorthWest')
end
axis('square')
axis([0 1 0 1]);
set(gca,  'FontSize', 18);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);

%% Fit cubic spline to the data
% We do this separately for color and material dimension
ppColor = spline(materialMatchColorCoords, returnedMaterialMatchColorCoords);
ppMaterial = spline(colorMatchMaterialCoords, returnedColorMatchMaterialCoords);
xMinTemp = floor(min([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))-0.5; 
xMaxTemp = ceil(max([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))+0.5;
xTemp = max(abs([xMinTemp xMaxTemp]));
xMin = -xTemp;
xMax = xTemp;
yMin = xMin; 
yMax = xMax;
splineOverX = linspace(xMin,xMax,1000);
inferredPositionsColor = ppval(splineOverX,ppColor); 
inferredPositionsMaterial  = ppval(splineOverX,ppMaterial); 
splineOverX(splineOverX>max(materialMatchColorCoords))=NaN;
splineOverX(splineOverX<min(materialMatchColorCoords))=NaN;

%% Plot positions from fit versus actual simulated positions 
figure; 
subplot(1,2,1); hold on % plot of material positions
plot(materialMatchColorCoords,returnedMaterialMatchColorCoords,'ro',splineOverX, inferredPositionsColor, 'r');
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
plot(colorMatchMaterialCoords,returnedColorMatchMaterialCoords,'bo',splineOverX,inferredPositionsMaterial, 'b');
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', 1, 'color', [0.5 0.5 0.5]);
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', 18);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', 18);

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

%% Plot descriptive Weibull fits to the data
%simulatedProbabilities = theDataProb; 
if plotWeibullFitsToData
    for i = 1:size(theDataProb,2);
        if i == 4
            fixPoint = 1;
        else
            fixPoint = 0;
        end
        [theSmoothPreds(:,i), theSmoothVals(:,i)] = ColorMaterialModelGetValuesFromFits(simulatedProbabilities(:,i)',colorMatchMaterialCoords, fixPoint);
    end
    ColorMaterialModelPlotFits(theSmoothVals, theSmoothPreds, materialMatchColorCoords, simulatedProbabilities);
end

%% Plot predictions of the model through the actual data 
%
% First check the positions of color (material) match on color (material) axis.  
% Signal if there is an error. 
tolerance = 1e-7; 
returnedMaterialMatchMaterialCoord = ppval(targetMaterialCoord, ppMaterial);
returnedColorMatchColorCoord =  ppval(targetColorCoord, ppColor);
if (abs(returnedMaterialMatchMaterialCoord) > tolerance)
    error('Target material coordinate did not map to zero.')
end
if (abs(returnedColorMatchColorCoord) > tolerance)
    error('Target color coordinates did not map to zero.')
end

% Find the predicted probabilities for a range of possible color coordinates 
rangeOfMaterialMatchColorCoordinates = linspace(min(materialMatchColorCoords), max(materialMatchColorCoords), 100)';

% Loop over each material coordinate of the color match, to get a predicted
% curve for each one.
for whichMaterialCoordinate = 1:length(colorMatchMaterialCoords)
    % Get the inferred material position for this color match
    returnedColorMatchMaterialCoord(whichMaterialCoordinate) = ppval(colorMatchMaterialCoords(whichMaterialCoordinate), ppMaterial);
    
    % Get the inferred color position for a range of material matches
    for whichColorCoordinate = 1:length(rangeOfMaterialMatchColorCoordinates)
        % Get the position of the material match
        returnedMaterialMatchColorCoord(whichColorCoordinate) = ppval(rangeOfMaterialMatchColorCoordinates(whichColorCoordinate), ppColor);
                
        % Compute the model predictions
        modelPredictions(whichColorCoordinate, whichMaterialCoordinate) = ColorMaterialModelComputeProb(targetColorCoord,targetMaterialCoord, ...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord, returnedW, returnedSigma);
    end
end
% if debugging
% [~,modelPredictions2] = ColorMaterialModelComputeLogLikelihood(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices,theResponsesFromSimulatedData,nTrials,...
%     returnedColorMatchMaterialCoords,returnedMaterialMatchColorCoords,params.targetIndex,...
%     returnedW, returnedSigma);
% end
%% Make sure the numbers we compute from the model now match those we computed in the demo program
%if debugging
%figure; clf; hold on
%plot(predictedProbabilitiesBasedOnSolution(:),modelPredictions(:),'ro','MarkerSize',12,'MarkerFaceColor','r');
%plot(predictedProbabilitiesBasedOnSolution(:),modelPredictions2(:),'bo','MarkerSize',12,'MarkerFaceColor','b');
%xlim([0 1]); ylim([0,1]); axis('square');
%end
rangeOfMaterialMatchColorCoordinates = repmat(rangeOfMaterialMatchColorCoordinates,[1, length(materialMatchColorCoords)]);
ColorMaterialModelPlotFits(rangeOfMaterialMatchColorCoordinates, modelPredictions, materialMatchColorCoords, simulatedProbabilities, min(materialMatchColorCoords)-0.5, max(materialMatchColorCoords)+0.5);