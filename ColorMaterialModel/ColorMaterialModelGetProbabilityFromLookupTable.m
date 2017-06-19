% function probability = ColorMaterialModelGetProbabilityFromLookupTable(F,colorMatchColorCoordGrid,materialMatchColorCoordGrid,...
%     colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid)
function probability = ColorMaterialModelGetProbabilityFromLookupTable(F,colorMatchColorCoordGrid,materialMatchColorCoordGrid,...
    colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid)

% Read probabilities from the lookup table. 
% Input: 
%   F - gridded interpolation function based on a look up table. 
% 	colorMatchColorCoordGrid - current position of color match on color dimension
%   materialMatchColorCoordGrid - current position of material match on color dimension
%   colorMatchMaterialCoordGrid - current position of color match on material dimension
%   materialMatchMaterialCoordsGrid - current position of the material match on material dimension
%   weightGrid - current weight
% Output: 
%   probability - for passed paramters, based on the interpolated lookup table.   

% 2/2/17 ar Wrote it. 

probability = F(colorMatchColorCoordGrid,materialMatchColorCoordGrid,colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid);


end