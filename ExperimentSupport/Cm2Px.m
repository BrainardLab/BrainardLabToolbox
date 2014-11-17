function screenPosPx = Cm2Px(screenDimsCm, screenDimsPx, screenPosCm)
% screenPosPx = Cm2Px(screenDimsCm, screenDimsPx, screenPosCm)
%
% Description:
% Transforms coordinates specifed in centimeters to coordinates in pixels.
% Note that (0, 0) translates to the upper left corner in screen
% coordinates, so a positive y value moves down on the screen.
%
% Inputs:
% screenDimsCm - The dimensions of the screen in centimeters.
% screenDimsPx - The dimensions of the screen in pixels.
% screenPosCm - The position (x,y) you want to convert.  This can by an Mx2
%	matrix consisting of many points to convert.
%
% Output:
% screenPosPx - Mx2 matrix of converted (x,y) points in pixels.

screenPosCm(2) = -screenPosCm(2);

% Find the midpoint of the screen in centimeters.
midCm = screenDimsCm ./ 2;

screenPosPx = zeros(size(screenPosCm));

for i = 1:size(screenPosCm)
	shiftedPosCm = screenPosCm + midCm;
	screenPosPx(i, :) = round(shiftedPosCm .* screenDimsPx ./ screenDimsCm);
end
