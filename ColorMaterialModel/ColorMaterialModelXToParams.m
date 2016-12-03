function [colorMatchMaterialCoords,materialMatchColorCoords,w,sigma] = ColorMaterialModelXToParams(x,params)
% [colorMatchMaterialCoords,materialMatchColorCoords,w,sigma] = ColorMaterialModelXToParams(x,params)
%
% Unpack the parameter vector for ColorMaterialModel
%
% Input: 
%   x - parameters vector
%   params - structure giving experiment design parameters
%
% Output: 
%   colorPositions - inferred positions on color dimensions for a material match
%   materialPositions - inferred positions on material dimensions for a color match
%   w - weighting of color, relative to material. 
%   sigma - noise, fixed to 1. 
%
%   Note, target falls at some place on color and material position and
%   that position is at 0, by definition (i.e. this is an assumption
%   inhereent in our model). 

% 11/20/2016 ar Wrote it

switch (params.whichVersion)
    case 'equalSpacing'
        materialCoordSpacing = x(1:params.smoothOrder);
        colorCoordSpacing = x(params.smoothOrder+1:params.smoothOrder+params.smoothOrder);
        
        % We're too lazy to rewrite the code below so we just set the bits
        % to what they are supposed to be.
        numberOfCompetitorsPositive = params.numberOfCompetitorsPositive;
        numberOfCompetitorsNegative = params.numberOfCompetitorsNegative;
        competitorsRangePositive = params.competitorsRangePositive;
        competitorsRangeNegative = params.competitorsRangeNegative;
        targetPosition = 0;
        
        % Derive positions from spacing.  We compute a poloynomial of
        % order equal to the length of the provided coordinates.
        baseColorMatchMaterialCoords = [linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
        colorMatchMaterialCoords = zeros(size(baseColorMatchMaterialCoords));
        for ii = 1:length(materialCoordSpacing)
            colorMatchMaterialCoords = colorMatchMaterialCoords + (baseColorMatchMaterialCoords.^ii)*materialCoordSpacing(ii);
        end
        
        baseMaterialMatchColorCoords = [linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
        materialMatchColorCoords = zeros(size(baseMaterialMatchColorCoords));
        for ii = 1:length(colorCoordSpacing)
            materialMatchColorCoords = materialMatchColorCoords + (baseMaterialMatchColorCoords.^ii)*colorCoordSpacing(ii);
        end
    otherwise
        colorMatchMaterialCoords = x(1:params.numberOfColorCompetitors);
        materialMatchColorCoords = x((1+params.numberOfColorCompetitors):(params.numberOfColorCompetitors+params.numberOfMaterialCompetitors));
end

w = x(end-1);
sigma = x(end); 

end

