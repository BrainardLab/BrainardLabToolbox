function ColorMaterialModelPlotFits(theSmoothVals,theSmoothPreds, theDeltaCs, theData, xMin, xMax)
%function ColorMaterialModelPlotFits(theSmoothVals,theSmoothPreds, theDeltaCs, theData, xMin, xMax)
% 
% Plots the fits to the data given the following input 
% Input: 
%   theSmoothVals
%   theSmoothPreds
%   theDeltaCs
%   theData



% Set up some plotting parameters
blue = [28, 134, 238]./255; 
red = [238, 59, 59]./255; 
green = [34, 139, 34]./255.*1.2; 
stepColors = {red, green, blue, 'k', blue, green, red};

% Set ends of the xAxis if we didn't pass them. 
if (nargin < 5)
    xMin = theDeltaCs(1)-0.5;
    xMax =  theDeltaCs(end)+0.5; 
end


% Plot color material trade off fits
figure; clf; hold on
for i = 1:size(theData,2)
    if i < 4
        plot(theDeltaCs,theData(:,i),'o','MarkerEdgeColor',stepColors{i},'MarkerSize',12, 'LineWidth', 2);
        plot(theSmoothVals(:,i),theSmoothPreds(:,i),'--','color', stepColors{i}, 'LineWidth',2);
    else
        plot(theDeltaCs,theData(:,i),'o','MarkerFaceColor',stepColors{i},'MarkerEdgeColor',stepColors{i},'MarkerSize',12);
        plot(theSmoothVals(:,i),theSmoothPreds(:,i),'color', stepColors{i}, 'LineWidth',2);
    end
end
plot(0, 0.5, 'kx', 'LineWidth',2)

xlabel('Color Coordinates of the Material Match','FontName','Helvetica','FontSize',18);
ylabel('Fraction color match chosen','FontName','Helvetica','FontSize',18);
axis([xMin xMax 0 1])
set(gca,'FontName','Helvetica','FontSize',14);

title(sprintf('Different material steps'),'FontName','Helvetica','FontSize',20);

%cd(figureDir)
%FigureSave(sprintf('%s_DeltaM_%s',subjectData.Name, conditionCode),gcf,'pdf');

