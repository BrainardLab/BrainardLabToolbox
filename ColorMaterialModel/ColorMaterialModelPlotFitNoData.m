%function [h, currentAxis] = ColorMaterialModelPlotFitNoData(theSmoothVals,theSmoothPreds, differenceSteps, varargin)
function [h, currentAxis] = ColorMaterialModelPlotFitNoData(theSmoothVals,theSmoothPreds, differenceSteps, varargin)
%
% Plots the color-material MLDS model fit without the data. 
% Can be used for color-only, material-only or color-material tradeoff. 
%
% Input: 
%   theSmoothVals - range of values for the x-axis
%   theSmoothPreds - corresponding range of predictions from the fit (y-axis)
%   differenceSteps - number of color/material steps (x-axis) 
%   whichMatch - string - either 'colorMatch' or 'materialMatch' - defines
%                what choice probabilities (i.e. matrix orientation) we're plotting
%  returnedWeight - current returned weight (so we can plot it)
%  whichFit - our (MLDS) model or Weibull 
%  fontSize - font size on the plots 
%  lineWidth - line width on the plots
%
% Output: 
%   h - figure handle
%   currentAxis - axes properties of the current figure. 
%
%   06/xx/2018 ar Adapted it from ColorMaterialModelPlot 
%   07/11/2018 ar Clean up

p = inputParser;
p.addParameter('whichMatch','colorMatch', @ischar);
p.addParameter('returnedWeight',0.5, @isnumeric);
p.addParameter('whichFit','MLDS', @ischar);
p.addParameter('fontSize', 12, @isnumeric); 
p.addParameter('lineWidth', 12, @isnumeric); 
p.parse(varargin{:});

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
for i = 1:length(differenceSteps)
    if i < 4
        plot(theSmoothVals(:,i),theSmoothPreds(:,i),'--','color', stepColors{i}, 'LineWidth',thisLineWidth);
    else
        plot(theSmoothVals(:,i),theSmoothPreds(:,i),'color', stepColors{i}, 'LineWidth',thisLineWidth);
    end
end

switch  p.Results.whichMatch
    case 'colorMatch'
        %title(sprintf('MLDS fits for different material steps'),'FontName','Helvetica','FontSize',thisFontSize);
        xlabel({'Material Match';'Color Difference (\Delta C)'},'FontName','Helvetica','FontSize',thisFontSize);
        %xlabel('Material Match Color Difference','FontName','Helvetica','FontSize',thisFontSize);
        ylabel('p Color Match chosen','FontName','Helvetica','FontSize',thisFontSize);
    
    case 'colorVariationOnly'
        xlabel({'Second competitor';'Color Difference (\Delta C)'},'FontName','Helvetica','FontSize',thisFontSize);
        ylabel('p First competitor chosen','FontName','Helvetica','FontSize',thisFontSize);
    
    case 'materialVariationOnly'
        xlabel({'Second competitor';'Material Difference (\Delta M)'},'FontName','Helvetica','FontSize',thisFontSize);
        ylabel('p First competitor chosen','FontName','Helvetica','FontSize',thisFontSize);
    
    case 'materialMatch'
        %        title(sprintf('MLDS fits for different color steps'),'FontName','Helvetica','FontSize',thisFontSize);
        xlabel('Color Match Material Difference (\Delta M)','FontName','Helvetica','FontSize',thisFontSize);
        ylabel('p Material Match chosen','FontName','Helvetica','FontSize',thisFontSize);
end


%plot(0, 0.5, 'kx', 'LineWidth',2)
axis([xMin xMax 0 1.05])
set(gca,'FontName','Helvetica','FontSize',20,'FontSize', 20);
set(gca, 'YTick', [0.0:0.25:1]);
set(gca, 'XTick', [-3:1:3]);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f'))

if strcmp(p.Results.whichFit, 'MLDS')
 %  set(gca, 'XTickLabel', {'C-3', 'C-2', 'C-1', 'C0', 'C+1', 'C+2', 'C+3'});
    set(gca, 'XTickLabel', {'-3', '-2', '-1', '0', '1', '2', '3'});
end
currentAxis = gca; 