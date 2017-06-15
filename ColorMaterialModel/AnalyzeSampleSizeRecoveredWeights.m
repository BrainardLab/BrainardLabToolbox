%% Initialize and set directories and some plotting params.
clear; close all;
currentDir = pwd;
dataDir = ['/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData'];


nBlocks1 = 56; 
nBlocks2 = 24; 
w = [0.25, 0.5, 0.75]; 
nSets = 10; 
cd([currentDir '/'])
for whichWeight = 1:length(w)
    for whichSet = 1:nSets
        clear a b
        a = load(['DemoData' num2str(w(whichWeight)) 'W' num2str(nBlocks1) 'Blocks10SetsFitVary.mat']);
        b = load(['DemoData' num2str(w(whichWeight)) 'W' num2str(nBlocks2) 'Blocks10SetsFitVary.mat']);
        
        getWeight1(whichSet, whichWeight) = a.dataSet{whichSet}.returnedParams(end-1);
        getWeight2(whichSet, whichWeight) = b.dataSet{whichSet}.returnedParams(end-1);
        
    end
end
xMin = -20;
yMin = xMin;
xMax = 20;
yMax = xMax;
thisMarkerSize = 10;
thisFontSize = 10; thisLineWidth = 1;
figure; clf; hold on; 
for whichSet = 1:10
    subplot(1,2,1); hold on % plot of material positions
    plot([-3:3], a.dataSet{whichSet}.returnedParams(8:14),'ro-', 'MarkerSize', thisMarkerSize);
    %plot([-3:3], b.dataSet{whichSet}.returnedParams(8:14),'bo-', 'MarkerSize', thisMarkerSize);
    pause
    plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
    axis([xMin, xMax,yMin, yMax])
    axis('square')
    xlabel('"True" position');
    ylabel('Inferred position');
    set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
    set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
    
    subplot(1,2,2); hold on % plot of material positions
    plot([-3:3], a.dataSet{whichSet}.returnedParams(1:7),'ro-', 'MarkerSize', thisMarkerSize);
    %plot([-3:3], b.dataSet{whichSet}.returnedParams(1:7),'bo-', 'MarkerSize', thisMarkerSize);
    
    plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
    axis([xMin, xMax,yMin, yMax])
    axis('square')
    xlabel('"True" position');
    ylabel('Inferred position');
    set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
    set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
end

