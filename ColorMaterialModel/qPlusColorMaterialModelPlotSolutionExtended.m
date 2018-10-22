function qPlusColorMaterialModelPlotSolutionExtended(theDataProb, predictedProbabilitiesBasedOnSolution, nTrialsPerPair, returnedModelParams,...
    params, figDir, saveFigs, colorMaterialData, colorOnlyData, materialOnlyData)
%function qPlusColorMaterialModelPlotSolutionExtended(theDataProb, predictedProbabilitiesBasedOnSolution, nTrialsPerPair, returnedModelParams,...
%    params, figDir, saveFigs, colorMaterialData, colorOnlyData, materialOnlyData)
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
%   colorMaterialData - measuredProbabilities for color-material functions (importnat:
%            rows are color levels (M0), columns are material levels (C0) 
%   colorOnlyData - measuredProbabilities for the color only (within axis) functions 
%   materialOnlyData - measuredProbabilities for material only functions 

% 05/30/18 ar Adapted the previous color-material model code for the
%               qPlus implementation

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

% Find a cubic fit to the data for both color and material. 
FColor = griddedInterpolant(params.materialMatchColorCoords, returnedMaterialMatchColorCoords,'cubic');
FMaterial = griddedInterpolant(params.colorMatchMaterialCoords, returnedColorMatchMaterialCoords,'cubic');


% Plot predictions of the model through the actual data

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
        % modelPredictions(whichColorCoordinate, whichMaterialCoordinate) = ColorMaterialModelComputeProb(params.targetColorCoord,params.targetMaterialCoord, ...
        %    returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
        %    returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord, returnedW, returnedSigma);
        modelPredictions(whichColorCoordinate, whichMaterialCoordinate) = ColorMaterialModelGetProbabilityFromLookupTable(params.F,...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord,returnedW);
    end
end
rangeOfMaterialMatchColorCoordinates = repmat(rangeOfMaterialMatchColorCoordinates,[1, length(params.materialMatchColorCoords)]);
[thisFig3, thisAxis3] = ColorMaterialModelPlotFit(rangeOfMaterialMatchColorCoordinates, modelPredictions, params.materialMatchColorCoords, ...
    colorMaterialData, ...
    'whichMatch', 'colorMatch', 'whichFit', 'MLDS','returnedWeight', returnedW, ...
    'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
ax(1)=thisAxis3;

%FigureSave([params.subjectName, 'ModelFitColorXAxis'], thisFig3, 'pdf');

% Make a plot only for color variation: 
% x axis - second competitor, target material, color variation 
% y axis - first chosen (target material, color variation)
for firstColorCoordinate = 1:length(params.materialMatchColorCoords)
    % Get the inferred color position for a range of other color coords that are the same material as the target.
    returnedFirstColorCoord(firstColorCoordinate) = FColor(params.materialMatchColorCoords(firstColorCoordinate));
    
    for secondColorCoordinate = 1:length(rangeOfMaterialMatchColorCoordinates)
        % Get the position of second competitor using FColor function
        returnedSecondColorCoord(secondColorCoordinate) = FColor(rangeOfMaterialMatchColorCoordinates(secondColorCoordinate));
        % Model p first chosen
        modelPredictionsColorVaryOnly(firstColorCoordinate, secondColorCoordinate) = ColorMaterialModelGetProbabilityFromLookupTable(params.F,...
            returnedFirstColorCoord(firstColorCoordinate),returnedSecondColorCoord(secondColorCoordinate),...
            returnedMaterialMatchMaterialCoord, returnedMaterialMatchMaterialCoord,returnedW);
    end
end
[thisFig4, thisAxis4] = ColorMaterialModelPlotFit(rangeOfMaterialMatchColorCoordinates, ...
    modelPredictionsColorVaryOnly', params.materialMatchColorCoords, colorOnlyData, ...
    'whichMatch', 'colorVariationOnly', 'whichFit', 'MLDS','returnedWeight', returnedW, ...
    'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
ax(2)=thisAxis4;

% Make analoguous plot only for material variation: 
for firstMaterialCoordinate = 1:length(params.colorMatchMaterialCoords)
    % Get the inferred material position for a range of other material coords that are the same color as the target.
    returnedFirstMaterialCoord(firstMaterialCoordinate) = FMaterial(params.colorMatchMaterialCoords(firstMaterialCoordinate));
    
    for secondMaterialCoordinate = 1:length(rangeOfColorMatchMaterialCoordinates)
        returnedSecondMaterialCoord(secondMaterialCoordinate) = FMaterial(rangeOfColorMatchMaterialCoordinates(secondMaterialCoordinate));
        % Model p first chosen
        modelPredictionsMaterialVaryOnly(firstMaterialCoordinate, secondMaterialCoordinate) = ...
            ColorMaterialModelGetProbabilityFromLookupTable(params.F,...
            returnedColorMatchColorCoord,returnedColorMatchColorCoord,...
            returnedFirstMaterialCoord(firstMaterialCoordinate), returnedSecondMaterialCoord(secondMaterialCoordinate),returnedW);
    end
end
rangeOfColorMatchMaterialCoordinates = repmat(rangeOfColorMatchMaterialCoordinates,[1, length(params.colorMatchMaterialCoords)]);
[thisFig5, thisAxis5] = ColorMaterialModelPlotFit(rangeOfColorMatchMaterialCoordinates, ...
    modelPredictionsMaterialVaryOnly', params.colorMatchMaterialCoords, materialOnlyData, ...
    'whichMatch', 'materialVariationOnly', 'whichFit', 'MLDS','returnedWeight', returnedW, ...
    'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
ax(3)=thisAxis5;

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
    axis([params.colorMatchMaterialCoords(1) params.colorMatchMaterialCoords(end) 0 1.05])
    set(gca, 'XTick', [-3:3])
    %text(-30, 23, 'A')
    %text(24, 23, 'B')
    %text(77.5, 23, 'C')
end
FigureSave([params.subjectName, 'Functions'], gcf, 'pdf');

end