function theAngle = VisualAngle(extent,distance)
% theAngle = VisualAngle(extent,distance)
%
% Computes visual angle for the stimulus given its extent (e.g., height, width,
% diameter) and its distance from the observer.  Obviously, extent and distance
% should be specified in the same units, but it doesn't matter what units.
% 
% Assumes that the observer is viewing the stimulus fronto-parallel from the center
% of the relevant dimension.
%
% Angle is returned in degrees.
% 
% 1/14/10  ar    Wrote it.
% 1/14/10  dhb   Cosmetic.

% Simple one line way
theAngle = 2*atan(extent/(2*distance))*180/pi;