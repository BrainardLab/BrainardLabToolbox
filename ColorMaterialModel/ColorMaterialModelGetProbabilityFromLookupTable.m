% function probability = ColorMaterialModelGetProbabilityFromLookupTable(colorMatchColorCoordGrid,materialMatchColorCoordGrid,...
%     colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid)
function probability = ColorMaterialModelGetProbabilityFromLookupTable(colorMatchColorCoordGrid,materialMatchColorCoordGrid,...
    colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid)

% Read probabilities from the lookup table
% Input: 
% 	colorMatchColorCoordGrid - current position of color match on color dimension
%   materialMatchColorCoordGrid - current position of material match on color dimension
%   colorMatchMaterialCoordGrid - current position of color match on material dimension
%   materialMatchMaterialCoordsGrid - current position of the material match on material dimension
%   weightGrid - current weight
% Output: 
%   probability - 

% 2/2/17 ar Wrote it. 

% Load lookup table
load('test');

probability = F(colorMatchColorCoordGrid,materialMatchColorCoordGrid,colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid);


end