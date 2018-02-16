function ColorMaterialModelPlotDataOnly(theDataProb, ...
    indexMatrix, params, figDir, saveFigs, weibullplots)
%function ColorMaterialModelPlotDataOnly(theDataProb, ...
%    indexMatrix, params, figDir, saveFigs, weibullplots)
% Make a nice plot of the data or data+weibull based fit. 
%
% Inputs:
%   theDataProb - the data probabilities measured in the experiment
%   indexMatrix - matrix of indices needed for extracting only the
%                 probabilities for color/material trade-off
%   params -  standard experiment specifications structure
%   figDir -  specify figure directory
%   saveFigs - save intermediate figures? main figure is going to be saved by default. 
%   weibullplots - flag indicating whether to save weibullplots or not

% 06/15/2017 ar Added comments and made small changes to the code. 
% 02/15/2017 ar Adapted it from the function that plots both the model and
%               the data. 

% Close all open figures; 
close all; 

% Reformat probabilities to look only at color/material tradeoff
% Indices that reformating is based on are saved in the data matrix
% that we loaded.
colorMaterialDataProb = ColorMaterialModelResizeProbabilities(theDataProb, indexMatrix);
subjectName = params.subjectName; 
cd (figDir)

% Set plot parameters. 
% Note: paramters this small will not look nice in single figures, but will
% look nice in the main combo-figure. 
thisFontSize = 20; 
thisMarkerSize = 16; 
thisLineWidth = 2; 

%% Figure 3. Plot descriptive Weibull fits to the data. 
if weibullplots
    % We loop through the matrix that contains probabilities for color
    % match being chosen. Each column is a fixed material step (i.e., color
    % varies across). Each row is a fixed color step (material varies). 
    % We plot column by column (i.e. each column is going to be one line in
    % the plot). This line shows how the probability of choosing a color match  
    % of a fixed material step (index i below) varies for different degrees of 
    % color variation of the material match (x axis). Each line (column) is a fixed
    % material step. 
    for i = 1:size(colorMaterialDataProb,2);
        if i == 4
            fixMidPoint = 1;
        else
            fixMidPoint = 0;
        end
        % Plot proportion of color match chosen for different 
        % color-diffence steps of the material match.
        [theSmoothPreds(:,i), theSmoothVals(:,i)] = FitColorMaterialModelWeibull(colorMaterialDataProb(:,i)',...
            params.materialMatchColorCoords, fixMidPoint);
        
        % This is the reverse fit: we're plotting the proportion of time
        % material match is chosen for different material-difference steps of
        % the color match.
        [theSmoothPredsReverseModel(:,i), theSmoothValsReverseModel(:,i)] = FitColorMaterialModelWeibull(1-colorMaterialDataProb(i,:),...
            params.colorMatchMaterialCoords, fixMidPoint);
    end
    thisFig1 = ColorMaterialModelPlotFit(theSmoothVals, theSmoothPreds, params.colorMatchMaterialCoords, colorMaterialDataProb,...
        'whichMatch', 'colorMatch', 'whichFit', 'weibull', 'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
    thisFig2 = ColorMaterialModelPlotFit(theSmoothValsReverseModel, theSmoothPredsReverseModel, params.materialMatchColorCoords, 1-colorMaterialDataProb', ...
        'whichMatch', 'materialMatch', 'whichFit', 'weibull', 'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
    if saveFigs
        FigureSave([subjectName, 'WeibullFitColorXAxis'], thisFig1, 'pdf');
        FigureSave([subjectName, 'WeibullFitMaterialXAxis'],thisFig2, 'pdf');
    end
end
%% Plot predictions of the model through the actual data
thisFig3 = ColorMaterialModelPlotFit([], [], params.materialMatchColorCoords, colorMaterialDataProb, ...
    'whichMatch', 'colorMatch', 'whichFit', 'MLDS','returnedWeight', returnedW, ...
    'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth, 'dataOnly', true);
thisFig4 = ColorMaterialModelPlotFit([], [], params.colorMatchMaterialCoords, 1-colorMaterialDataProb', ...
    'whichMatch', 'materialMatch', 'whichFit', 'MLDS','returnedWeight', returnedW, ...
    'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth, 'dataOnly', true);
if saveFigs
    FigureSave([subjectName, 'DataOnlyColorXAxis'], thisFig3, 'pdf');
    FigureSave([subjectName, 'DataOnlyMaterialXAxis'], thisFig4, 'pdf');
end
