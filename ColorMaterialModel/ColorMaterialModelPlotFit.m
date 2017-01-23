function h = ColorMaterialModelPlotFit(theSmoothVals,theSmoothPreds, theDeltaSteps, theData, varargin)
% ColorMaterialModelPlotWeibullFit(theSmoothVals,theSmoothPreds, theDeltaSteps, theData, whichMatch, xMin, xMax)
% 
% Plots the fit of the descriptive Weibull model to the data.
%
% Input: 
%   returnedW - returned weight (value we print on the figure); 
%   theSmoothVals - range of values for the x-axis
%   theSmoothPreds - corresponding range of predictions from the fit (y-axis)
%   theDeltaSteps - number of color/material steps (x-axis) 
%   theData - data points from the experiment (y-axis)
%   whichMatch - string - either 'colorMatch' or 'materialMatch' - defines
%                what choice probabilities we're plotting
%   figDir - whichDirectory to save the figures in
%   saveFig - should we save figures

%   Dec 2016 ar Wrote it

p = inputParser;
p.addParameter('whichMatch','colorMatch', @ischar);
p.addParameter('returnedWeight',0.5, @isnumeric);
p.addParameter('whichFit','MLDS', @ischar);
p.parse(varargin{:});

% Set up some plotting parameters
blue = [28, 134, 238]./255; 
red = [238, 59, 59]./255; 
green = [34, 139, 34]./255.*1.2; 
stepColors = {red, green, blue, 'k', blue, green, red};
xMin = theDeltaSteps(1)-0.5;
xMax =  theDeltaSteps(end)+0.5;
    
% Plot color material trade off fits
h = figure; clf; hold on
for i = 1:size(theData,2)
    if i < 4
        plot(theDeltaSteps,theData(:,i),'o','MarkerEdgeColor',stepColors{i},'MarkerSize',12, 'LineWidth', 2);
        plot(theSmoothVals(:,i),theSmoothPreds(:,i),'--','color', stepColors{i}, 'LineWidth',2);
    else
        plot(theDeltaSteps,theData(:,i),'o','MarkerFaceColor',stepColors{i},'MarkerEdgeColor',stepColors{i},'MarkerSize',12);
        plot(theSmoothVals(:,i),theSmoothPreds(:,i),'color', stepColors{i}, 'LineWidth',2);
    end
end
plot(0, 0.5, 'kx', 'LineWidth',2)
axis([xMin xMax 0 1.05])
set(gca,'FontName','Helvetica','FontSize',14);

% add appropriate text
% switch whichFit
%     case 'MLDS'
%         text(-3, 1.05, sprintf('w = %.2f', returnedW), 'FontSize', 12);
%         switch whichMatch
%             case 'colorMatch'
%                 title(sprintf('MLDS fits for different material steps'),'FontName','Helvetica','FontSize',16);
%                 xlabel('Color Coordinates of the Material Match','FontName','Helvetica','FontSize',18);
%                 ylabel('Fraction color match chosen','FontName','Helvetica','FontSize',18);
%             case 'materialMatch'
%                 title(sprintf('MLDS fits for different color steps'),'FontName','Helvetica','FontSize',16);
%                 xlabel('Material Coordinates of the Color Match','FontName','Helvetica','FontSize',18);
%                 ylabel('Fraction material match chosen','FontName','Helvetica','FontSize',18);
%         end
%     case 'weibull'
%         switch whichMatch
%             case 'colorMatch'
%                 title(sprintf('Weibull fits for different material steps'),'FontName','Helvetica','FontSize',16);
%             case 'materialMatch'
%                 title(sprintf('Weibull fits for different color steps'),'FontName','Helvetica','FontSize',16);
%         end
% end


