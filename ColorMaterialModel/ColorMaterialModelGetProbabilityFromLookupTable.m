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
%     Because a cubic lookup table can ring, we allow for possibility that
%     returned probability from the lookup table might be a little less
%     than 0 or a little greater than one.  Currently the tolerance is 2%.
%     In these cases, the routine returns 0 or 1 as appropriately.  A
%     bigger deviation from the expected bounds on probability throws an
%     error.
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

% 02/2/17 ar        Wrote it. 
% 02/16/18 dhb, ar  Add check for returned value and implement tolerance.
% 04/10/18 dhb, ar  Also, truncate to a value (e.g. 0.0001-0.9999) that
%                   accounts for lapses.

probability = F(colorMatchColorCoordGrid,materialMatchColorCoordGrid,colorMatchMaterialCoordGrid,materialMatchMaterialCoordsGrid, weightGrid);
tolerance = 0.1;

% Check on bounds and handle possibilityt that subject might lapse.
minProbability = 1e-4;
if (probability < minProbability)
    if (probability > -tolerance)
        probability = minProbability;
    else
         probability
        error('Table returns probability too much less than 0');
    end
elseif (probability > 1-minProbability)
    if (probability < 1 + tolerance)
        probability = 1-minProbability;
    else
        probability
       error('Table returns probability greater than 1');
    end
end


end