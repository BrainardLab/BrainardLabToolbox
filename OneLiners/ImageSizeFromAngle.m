function TheExtent = ImageSizeFromAngle(angle,distance)
% function TheExtent = ImageSizeFromAngle(angle,distance)
%
% Computes the size (e.g., height, width, diameter) of the object viewed given
% the visual angle and its distance from the observer.  The extent retured will be in the same units 
% as the units as the provided distance but it doesn't matter what units.
% 
% Assumes that the observer is viewing the stimulus fronto-parallel from the center
% of the relevant dimension.
%
% 
% 05/01/13  ar    Wrote it, from the VisualAngleFormula. 

% Simple one line way
 TheExtent = tan(deg2rad(angle/2))*(2*distance); 