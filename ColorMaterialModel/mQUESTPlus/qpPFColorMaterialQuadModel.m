function predictedProportions = qpPFColorMaterialQuadModel(stimParams,psiParams,F)
% Psychometric function for the color material model, for use with mQUESTPlus
%
% Usage:
%     predictedProportions = qpPFColorMaterialModel(stimParams,psiParams)
%
% Description:
%     Compute the proportions of each outcome for the color material model psychometric
%     function, using the quadratic relation between nominal and perceptual stimulus positions.
%
% Input:
%     stimParams     Matrix, with each row being a vector of stimulus parameters.
%                    The vector contains in order:
%                       colorMatchColorCoord - inferred position on the color dimension for the first competitor in the pair
%                       materialMatchColorCoord - inferred position on the material dimension for the first competitor in the pair
%                       colorMatchMaterialCoord - inferred position on the color dimension for the second competitor in the pair
%                       materialMatchMaterialCoord - inferred position on the material dimension for the second competitor in the pair
%
%     psiParams      Row vector of parameters. This contains in order
%                      colorCoordinateSlope - linear parameter of curve relating color coordinate positions to perceptual positions
%                      colorCoordinateQuad - quadratic parameter of curve relating color coordinate positions to perceptual positions
%                      materialCoordinateSlope - linear parameter of curve  relating material coordinate positions to perceptual positions
%                      materialCoordinateQuad - quadratic parameter of curve relating material coordinate positions to perceptual positions
%                      weight - Color material weight
%
%     F              The precomputed lookup table
%
% Output:
%     predictedProportions  Matrix, where each row is a vector of predicted proportions
%                           for each outcome.
%                             First entry of each row is for color match response (outcome == 1)
%                             Second entry of each row is for material match response (outcome == 2)
%
% Optional key/value pairs
%     None

% 07/08/17  dhb  Started on this.

%% Extract model parameter
colorCoordinateSlope = psiParams(1);
colorCoordinateQuad = psiParams(2);
materialCoordinateSlope = psiParams(3);
materialCoordinateQuad = psiParams(4);
weight = psiParams(3);

%% Extract and map stim parameters
colorMatchColorCoords = colorCoordinateSlope*stimParams(:,1)+colorCoordinateQuad*(stimParams(:,1).^2);
materialMatchColorCoords = colorCoordinateSlope*stimParams(:,2)+colorCoordinateQuad*(stimParams(:,2).^2);
colorMatchMaterialCoords = materialCoordinateSlope*stimParams(:,3)+materialCoordinateQuad*(stimParams(:,3).^2);
materialMatchMaterialCoords = materialCoordinateSlope*stimParams(:,4)+materialCoordinateQuad*(stimParams(:,4).^2);
nStim = length(colorMatchColorCoords);

%% Look up probability of each response for each stimulus
predictedProportions = zeros(nStim,2);
for ii = 1:nStim
    p1 = ColorMaterialModelGetProbabilityFromLookupTable(F,colorMatchColorCoords(ii),materialMatchColorCoords(ii), ...
        colorMatchMaterialCoords(ii),materialMatchMaterialCoords(ii), weight);
    predictedProportions(ii,:) = [p1 1-p1];
end

