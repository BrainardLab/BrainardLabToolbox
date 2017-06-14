

clear all; 
space = [1 1.5 2 2.5 3];
figure; clf; hold on;
colors = {'r', 'g', 'b', 'm', 'k'};
model = 2; 

for i = 1:length(space)
    if model == 1
        k{i} = load(['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots/untitled folder/DemoData0.2W24Blocks15Spacing' ...
            num2str(space(i)) 'LinFitVary.mat']);
    elseif model == 2
        k{i} = load(['/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel/DemoData/DemoData0.2W24Blocks15Spacing' ...
            num2str(space(i)) 'LinFitVary.mat']);
    end
    subplot(1,2,1); hold on;
    title('COLOR')
    for j = 1:length(k{i}.dataSet)
        whichWeigth(i,j) = k{i}.dataSet{j}.returnedParams(end-1);
    end
    for j = 1:length(k{i}.dataSet)
        [~,materialMatchColorCoords,~,~] = ColorMaterialModelXToParams(k{i}.dataSet{j}.returnedParams,k{i}.params); 
        plot(k{i}.params.materialMatchColorCoords, materialMatchColorCoords, 'o', 'MarkerFaceColor', colors{i}, 'MarkerEdgeColor', colors{i});
    end
  subplot(1,2,2); hold on;
  title('MATERIAL')
%  make a plot where 
    for j = 1:length(k{i}.dataSet)
        [colorMatchMaterialCoords,~,~,~] = ColorMaterialModelXToParams(k{i}.dataSet{j}.returnedParams,k{i}.params); 
        plot(k{i}.params.colorMatchMaterialCoords, colorMatchMaterialCoords, 'o', 'MarkerFaceColor', colors{i}, 'MarkerEdgeColor', colors{i});
    end
end



