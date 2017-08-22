function newRGB = Recontrast(rgbValue, contrast)
% Recontrast - Changes an RGB value(s) to a specific contrast level.
%
% Syntax:
% newRGB = Recontrast(rgbValue, contrast)
%
% Description:
% Recalculates an RGB value to a particular contrast level about gray (0.5 
% in the [0 1] world).
%
% Input:
% rgbValue (Mx3) - Input RGB value(s) in the [0,1] range.
% contrast (scalar) - Contrast of the transformed RGB value in the range [0,1].
%
% Output:
% newRGB (Mx3) - Transformed RGB value(s).

% Make sure we have the right number of input arguments.
narginchk(2, 2);

% Figure out what the minimum value is when we set the contrast the
% desired level.  This will be essentially be half our actual range (0.5)
% minus half the desired contrast.
rgbMin = 0.5 - contrast / 2;

% Normalize the RGB value(s) to the desired contrast range, then shift it
% to start at our calculated RGB minimum.
newRGB = rgbValue .* contrast + rgbMin;
