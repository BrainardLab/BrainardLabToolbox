
clear; close all; 
%% Get some values we need to index into the parameters vector in ways we
% will need.
params.targetPosition = 0;
params.targetIndex = 4; % this is going to be target index in the competitor space.
params.targetIndexColor = 11; % in the vector of parameters, this is the position for target on color dimension.
params.targetIndexMaterial = 4; % in the vector of parameters, this is the positino for target on material dimension.
params.competitorsRangePositive = [1 3];
params.competitorsRangeNegative = [-3 -1];
params.numberOfCompetitorsPositive = 3;
params.numberOfCompetitorsNegative = 3;
params.sigma = 1; 0
params.sigmaFactor = 4; 
params.numberOfColorCompetitors = 7; 
params.numberOfMaterialCompetitors = 7; 

save('ExampleStructure', 'params') 

