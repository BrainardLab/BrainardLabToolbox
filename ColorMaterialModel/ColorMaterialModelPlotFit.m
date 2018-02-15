%function [h, currentAxis] = ColorMaterialModelPlotFit(theSmoothVals,theSmoothPreds, differenceSteps, theData, varargin)
function [h, currentAxis] = ColorMaterialModelPlotFit(theSmoothVals,theSmoothPreds, differenceSteps, theData, varargin)
%
% Plots the model fit to the data - either our color-material MLDS model or the descriptive Weibull model to the data.
% The plots include only the color-material tradeoff. 
%
% Input: 
%   theSmoothVals - range of values for the x-axis
%   theSmoothPreds - corresponding range of predictions from the fit (y-axis)
%   differenceSteps - number of color/material steps (x-axis) 
%   theData - experimental data: if colorMatch the row x column format of
%             the data is rows: color-varies columns: material-varies but
%             if materialMatch: rows: material vary, columns: color-vary. 
%   whichMatch - string - either 'colorMatch' or 'materialMatch' - defines
%                what choice probabilities (i.e. matrix orientation) we're plotting
%  returnedWeight - current returned weight (so we can plot it)
%  whichFit - our (MLDS) model or Weibull
%  fontSize - font size on the plots 
%  lineWidth - line width on the plots
%  markerSize - marker size on the plots
%  dataOnly - do not plot the model
%
% Output: 
%   h - figure handle
%   currentAxis - axes properties of the current figure. 
%
%   12/xx/2016 ar Wrote it
%   06/21/2017 ar Checked, added comments. 
%   02/15/2017 ar Added plot data only option. 

p = inputParser;
p.addParameter('whichMatch','colorMatch', @ischar);
p.addParameter('returnedWeight',0.5, @isnumeric);
p.addParameter('whichFit','MLDS', @ischar);
p.addParameter('fontSize', 12, @isnumeric); 
p.addParameter('lineWidth', 12, @isnumeric); 
p.addParameter('markerSize', 12, @isnumeric); 
p.addParameter('dataOnly', false, @islogical); 
p.parse(varargin{:});

thisMarkerSize = p.Results.markerSize-2; 
thisLineWidth = p.Results.lineWidth; 
thisFontSize = p.Results.fontSize; 

% Set up additional plotting parameters
blue = [28, 134, 238]./255; 
red = [238, 59, 59]./255; 
green = [34, 139, 34]./255.*1.2; 
stepColors = {red, green, blue, 'k', blue, green, red};
xMin = differenceSteps(1)-0.5;
xMax =  differenceSteps(end)+0.5;
    
% Plot color-material trade off fits
h = figure; clf; hold on
for i = 1:size(theData,2)
    if i < 4
        plot(differenceSteps,theData(:,i),'o','MarkerEdgeColor',stepColors{i},'MarkerSize',thisMarkerSize, 'LineWidth', thisLineWidth);
        if (p.Results.dataOnly == 0) && strcmp(p.Results.whichFit, 'MLDS')
            plot(theSmoothVals(:,i),theSmoothPreds(:,i),'--','color', stepColors{i}, 'LineWidth',thisLineWidth);
        end
    else
        plot(differenceSteps,theData(:,i),'o','MarkerFaceColor',stepColors{i},'MarkerEdgeColor',stepColors{i},'MarkerSize',thisMarkerSize);
        if (p.Results.dataOnly == 0) && strcmp(p.Results.whichFit, 'MLDS')
            plot(theSmoothVals(:,i),theSmoothPreds(:,i),'color', stepColors{i}, 'LineWidth',thisLineWidth);
        end
    end
end

switch p.Results.whichFit
    case 'MLDS'
       % text(-3, 1.05, sprintf('w = %.2f', p.Results.returnedWeight), 'FontSize', thisFontSize);
        switch  p.Results.whichMatch
            case 'colorMatch'
                %      title(sprintf('MLDS fits for different material steps'),'FontName','Helvetica','FontSize',thisFontSize);
                xlabel('Material Match Color Difference (\Delta C)','FontName','Helvetica','FontSize',thisFontSize);
                ylabel('p Color Match chosen','FontName','Helvetica','FontSize',thisFontSize);
            case 'materialMatch'
                %        title(sprintf('MLDS fits for different color steps'),'FontName','Helvetica','FontSize',thisFontSize);
                xlabel('Color Match Material Difference (\Delta M)','FontName','Helvetica','FontSize',thisFontSize);
                ylabel('p Material Match chosen','FontName','Helvetica','FontSize',thisFontSize);
        end
    case 'weibull'
        switch p.Results.whichMatch
            case 'colorMatch'
                % title(sprintf('Weibull fits for different material steps'),'FontName','Helvetica','FontSize',thisFontSize);
                xlabel('Material Match Color Difference (\Delta C)','FontName','Helvetica','FontSize',thisFontSize);
                ylabel('p Color Match chosen','FontName','Helvetica','FontSize',thisFontSize);
                
            case 'materialMatch'
                % title(sprintf('Weibull fits for different color steps'),'FontName','Helvetica','FontSize',thisFontSize);
                xlabel('Color Match Material Difference (\delta M)','FontName','Helvetica','FontSize',thisFontSize);
                ylabel('p Material Match chosen','FontName','Helvetica','FontSize',thisFontSize);
        end
end

%plot(0, 0.5, 'kx', 'LineWidth',2)
axis([xMin xMax 0 1.05])
set(gca,'FontName','Helvetica','FontSize',20,'FontSize', 20);
set(gca, 'YTick', [0.0:0.25:1]);
set(gca, 'XTick', [-3:1:3]);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f'))

if strcmp(p.Results.whichFit, 'MLDS')
    set(gca, 'XTickLabel', {'-3', '-2', '-1', '0', '+1', '+2', '+3'});
end
currentAxis = gca; 