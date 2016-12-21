function [colorMatchMaterialCoords,materialMatchColorCoords,w,sigma] = ColorMaterialModelXToParams(x,params)
% [colorMatchMaterialCoords,materialMatchColorCoords,w,sigma] = ColorMaterialModelXToParams(x,params)
%
% Unpack the parameter vector for ColorMaterialModel
%
% Input: 
%   x - parameters vector
%   params - structure giving experiment design parameters
% Output: 
%   colorPositions - inferred positions on color dimensions for a material match
%   materialPositions - inferred positions on material dimensions for a color match
%   w - weighting of color, relative to material. 
%   sigma - noise, fixed to 1. 
%
% Note, target falls at some place on color and material position and
% that position is at 0, by definition (i.e. this is an assumption
% inhereent in our model). None the less, we return the target position
% explicitly in each of the returned coords vectors.

% 11/20/2016 ar Wrote it
% 12/3/2016  dhb, ar Clean up smoothSpacing option.

switch (params.whichPositions)
    case 'smoothSpacing'
        % In the smooth spacing condition, the initial parameters in x are
        % the coefficients on polynomials of order params.smoothOrder for
        % both the color match material coordinates and the material match
        % color coordinates.  Extract these.
        materialCoordSpacing = x(1:params.smoothOrder);
        colorCoordSpacing = x(params.smoothOrder+1:params.smoothOrder+params.smoothOrder);
        
        % We need to apply the polynomial so that what we return from this routine is the 
        % actual positions.  To do this, we get the nominal stimulus positions and then
        % apply the polynomial to them.  To get the nominal stimulus position, we rely
        % on information in the params structure, plus the fact that the target position is
        % 0 for both dimensions.  This gets us to the nominal positions.
        numberOfCompetitorsPositive = params.numberOfCompetitorsPositive;
        numberOfCompetitorsNegative = params.numberOfCompetitorsNegative;
        competitorsRangePositive = params.competitorsRangePositive;
        competitorsRangeNegative = params.competitorsRangeNegative;
        targetPosition = 0;
        nominalColorMatchMaterialCoords = [linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];
        nominalMaterialMatchColorCoords = [linspace(competitorsRangeNegative(1),competitorsRangeNegative(2), numberOfCompetitorsNegative),targetPosition,linspace(competitorsRangePositive(1),competitorsRangePositive(2), numberOfCompetitorsPositive)];

        % Derive positions from spacing.  We compute a poloynomial of
        % order equal to the length of the provided coordinates.
        %
        % This loop handles the color matches
        colorMatchMaterialCoords = zeros(size(nominalColorMatchMaterialCoords));
        for ii = 1:length(materialCoordSpacing)
            colorMatchMaterialCoords = colorMatchMaterialCoords + (nominalColorMatchMaterialCoords.^ii)*materialCoordSpacing(ii);
        end
        
        % This loop handles the material matches
        materialMatchColorCoords = zeros(size(nominalMaterialMatchColorCoords));
        for ii = 1:length(colorCoordSpacing)
            materialMatchColorCoords = materialMatchColorCoords + (nominalMaterialMatchColorCoords.^ii)*colorCoordSpacing(ii);
        end
    case 'full'
        % Here we just search on all the positions, so we just need to suck
        % them out of the parameters vector.
        colorMatchMaterialCoords = x(1:params.numberOfColorCompetitors);
        materialMatchColorCoords = x((1+params.numberOfColorCompetitors):(params.numberOfColorCompetitors+params.numberOfMaterialCompetitors));
    otherwise
        error('Unknown whichPositions method specified.')
end

% Grab w and sigma from the parameters vector.  They are always the last
% two entries.
w = x(end-1);
sigma = x(end); 

end

