function radSize = FindOuterRadiusSize(screenHeight, viewingDistance)
% Usage:
%	radSize = FindOuterRadiusSize(screenHeight, viewingDistance)
%
% Description:
%	Convenience function to calculate the outer ring size used for certain
%	FRMI scripts.
%
% Inputs:
%	'screenHeight' is the height of the screen in centimeters.
%	'viewDistance' is the distance from the observer to the screen in
%		centimeters.
%
% Output:
%	'radSize' is the size of the outer radius in degrees.

if nargin ~= 2
	error('Usage: FindOuterRadiusSize(screenHeight, viewingDistance)');
end

radSize = atan(screenHeight/2/viewingDistance)/pi*180;
