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
        materialCoordSpacing = x(1);
        colorCoordSpacing = x(2);
        
        % We're too lazy to rewrite the code below so we just set the bits
        % to what they are supposed to be.
        numberOfCompetitorsPositive = params.numberOfCompetitorsPositive;
        numberOfCompetitorsNegative = params.numberOfCompetitorsNegative;
        competitorsRangePositive = params.competitorsRangePositive;
        competitorsRangeNegative = params.competitorsRangeNegative;
        targetPosition = 0;
        
        % Derive positions from spacing.
        colorMatchMaterialCoords= [materialCoordSpacing*linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,materialCoordSpacing*linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
        materialMatchColorCoords = [colorCoordSpacing*linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,colorCoordSpacing*linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
        
    otherwise
        colorMatchMaterialCoords = x((1+params.numberOfColorCompetitors):(params.numberOfColorCompetitors+params.numberOfMaterialCompetitors));
        materialMatchColorCoords = x(1:params.numberOfColorCompetitors);
end

w = x(end-1);
sigma = x(end); 

end

