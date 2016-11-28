function ColorMaterialModelPlotFits(theSmoothVals,theSmoothPreds, theDeltaCs, theData)
%function ColorMaterialModelPlotFits(theSmoothVals,theSmoothPreds, theDeltaCs, theData)

% plotting parameters
blue = [28, 134, 238]./255; 
red = [238, 59, 59]./255; 
green = [34, 139, 34]./255.*1.2; 
stepColors = {red, green, blue, 'k', blue, green, red};

figure; clf; hold on
% Plot color material trade off fits
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

xlabel('Delta color (nominal)','FontName','Helvetica','FontSize',18);
ylabel('Fraction color match chosen','FontName','Helvetica','FontSize',18);
axis([-3 3 0 1])
set(gca,'FontName','Helvetica','FontSize',14);

%title(sprintf('Delta material = %d',theDeltaMs(i)),'FontName','Helvetica','FontSize',20);
title(sprintf('Different material steps'),'FontName','Helvetica','FontSize',20);

%cd(figureDir)
%FigureSave(sprintf('%s_DeltaM_%s',subjectData.Name, conditionCode),gcf,'pdf');

