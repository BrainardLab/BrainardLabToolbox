function predictedProportions = qpPFColorMaterialCubicModel(stimParams,psiParams,F)
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
%                       materialMatchColorCoord - inferred position on the color dimension for the second competitor in the pair
%                       colorMatchMaterialCoord - inferred position on the material dimension for the first competitor in the pair
%                       materialMatchMaterialCoord - inferred position on the material dimension for the second competitor in the pair
%
%     psiParams      Row vector of parameters. This contains in order
%                      colorCoordinateSlope - linear parameter of curve relating color coordinate positions to perceptual positions
%                      colorCoordinateQuad - quadratic parameter of curve relating color coordinate positions to perceptual positions
%                      colorCoordinateCubic - cubic parameter of curve relating color coordinate positions to perceptual positions
%                      materialCoordinateSlope - linear parameter of curve  relating material coordinate positions to perceptual positions
%                      materialCoordinateQuad - quadratic parameter of curve relating material coordinate positions to perceptual positions
%                      materialCoordinateCubic - cubic parameter of curve relating material coordinate positions to perceptual positions
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
% 01/05/18  dhb  Add check for return value out of range [0,1], throw error.
% 01/24/18  dhb  Cubic version.

%% Extract model parameter
colorCoordinateSlope = psiParams(1);
colorCoordinateQuad = psiParams(2);
colorCoordinateCubic = psiParams(3);
materialCoordinateSlope = psiParams(4);
materialCoordinateQuad = psiParams(5);
materialCoordinateCubic = psiParams(6);
weight = psiParams(7);

%% Extract and map stim parameters
colorMatchColorCoords = colorCoordinateSlope*stimParams(:,1)+colorCoordinateQuad*(stimParams(:,1).^2)+colorCoordinateCubic*(stimParams(:,1).^3);
materialMatchColorCoords = colorCoordinateSlope*stimParams(:,2)+colorCoordinateQuad*(stimParams(:,2).^2)+colorCoordinateCubic*(stimParams(:,2).^3);
colorMatchMaterialCoords = materialCoordinateSlope*stimParams(:,3)+materialCoordinateQuad*(stimParams(:,3).^2)+materialCoordinateCurbic*(stimParams(:,3).^3);
materialMatchMaterialCoords = materialCoordinateSlope*stimParams(:,4)+materialCoordinateQuad*(stimParams(:,4).^2)+materialCoordinateCubic*(stimParams(:,4).^3);
nStim = length(colorMatchColorCoords);

%% Look up probability of each response for each stimulus
predictedProportions = zeros(nStim,2);
for ii = 1:nStim
    % Look up probability
    p1 = ColorMaterialModelGetProbabilityFromLookupTable(F,colorMatchColorCoords(ii),materialMatchColorCoords(ii), ...
        colorMatchMaterialCoords(ii),materialMatchMaterialCoords(ii), weight);
    
    % Check on bounds
    if (p1 < 0)
        error('Table returns probability less than 0');
    elseif (p1 > 1)
        error('Table returns probability greater than 1');
    end
    
    % Return in desired format
    predictedProportions(ii,:) = [p1 1-p1];
end

