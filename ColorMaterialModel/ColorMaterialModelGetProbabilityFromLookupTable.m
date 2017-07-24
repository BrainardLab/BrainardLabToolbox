function probability = ColorMaterialModelGetProbabilityFromLookupTable(F,colorMatchColorCoordGrid,materialMatchColorCoordGrid,...
    colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid)
%ColorMaterialModelGetProbabilityFromLookupTable  Get response probability from precomputed lookup table.
%
% Usage:
%     probability = ColorMaterialModelGetProbabilityFromLookupTable(F,colorMatchColorCoordGrid,materialMatchColorCoordGrid,...
%       colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid)
%
% Description:
%     Use precomputed lookup table (produced by ColorMaterialModelBuildLookupTable) to obtain the probability of [WHICH]
%     response in the color material paradigm.
%
%     The target is assumed to live at nominal coordinates 0,0, a fact that is baked into the lookup table.
%
% Input: 
%     F - gridded interpolation function based on a look up table. 
% 	  colorMatchColorCoordGrid - current position of color match on color dimension
%     materialMatchColorCoordGrid - current position of material match on color dimension
%     colorMatchMaterialCoordGrid - current position of color match on material dimension
%     materialMatchMaterialCoordsGrid - current position of the material match on material dimension
%     weightGrid - current weight
%
% Output: 
%     probability - for passed paramters, probability of color match response, based on the lookup table. 
%
% Optional key/value pairs
%    None.
%
% See also:
%    ColorMaterialModelBuildLookupTable.

% 2/2/17 ar Wrote it. 

probability = F(colorMatchColorCoordGrid,materialMatchColorCoordGrid,colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid);


end