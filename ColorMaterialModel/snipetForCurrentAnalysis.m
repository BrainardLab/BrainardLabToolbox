
% w = 0.2 for simulation
load('/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/paramsxx1x.mat')
for i = 1:length(rowIndex)
        resizePredictedProbabilitiesBasedOnSolution(rowIndex((i)), columnIndex((i))) = predictedProbabilitiesBasedOnSolution(overallColorMaterialPairIndices(i)); 
        resizeProbabilitiesComputedForSimulatedData(rowIndex((i)), columnIndex((i))) = probabilitiesComputedForSimulatedData(overallColorMaterialPairIndices(i)); 
     
end
weibullplots = 0; 
close all
ColorMaterialModelPlotSolution(resizedDataProb, resizePredictedProbabilitiesBasedOnSolution, ...
    returnedParams, params, params.subjectName, params.conditionCode, figDir, saveFig, weibullplots);

%  'weightVary'
%   recovered Weigth


figure; hold on
plot(theDataProb(:),predictedProbabilitiesBasedOnSolution(:),'ro','MarkerSize',12,'MarkerFaceColor','r');
rmse = computeRealRMSE(theDataProb(:),predictedProbabilitiesBasedOnSolution(:)); 
text(0.07, 0.87, sprintf('RMSE = %.4f', rmse), 'FontSize', 12); 


   plot(theDataProb(:),probabilitiesComputedForSimulatedData(:),'bo','MarkerSize',12,'MarkerFaceColor','b');
 %   legend('Fit Parameters', 'Actual Parameters', 'Location', 'NorthWest')
  legend('Fit Parameters', 'Location', 'NorthWest')
  legend boxoff
