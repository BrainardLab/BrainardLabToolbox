function [colorPositions,  materialPositions, w, sigma] = ColorMaterialModelXToParams(x, params)
%function [colorPositions,  materialPositions, w, sigma] = ColorMaterialModelXToParams(x, params)
% Unpack the parameter vector for ColorMaterialModel
% Input: 
%   x - parameters vector
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

colorPositions = x(1:params.numberOfColorCompetitors);
materialPositions = x((1+params.numberOfColorCompetitors):(params.numberOfColorCompetitors+params.numberOfMaterialCompetitors));
w = x(end-1);
sigma = x(end); 

end

