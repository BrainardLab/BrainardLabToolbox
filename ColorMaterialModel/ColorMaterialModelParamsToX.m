function [x] = ColorMaterialModelParamsToX(colorMatchMaterialCoords,materialMatchColorCoords,w,sigma)
% [x] = ColorMaterialModelParamsToX(colorMatchMaterialCoords,materialMatchColorCoords,w,sigma)
%
% Packk the parameter vector for ColorMaterialModel
%
% Input: 
%   colorPositions - inferred positions on color dimensions for a material match
%   materialPositions - inferred positions on material dimensions for a color match
%   w - weighting of color, relative to material. 
%   sigma - noise, fixed to 1.
%
% Output: 
%   x - parameters vector
%
%   Note, target falls at some place on color and material position and
%   that position is at 0, by definition (i.e. this is an assumption
%   inhereent in our model). 

% 12/2/2016 ar, dhb Wrote it

x = [colorMatchMaterialCoords materialMatchColorCoords w sigma]';

end



