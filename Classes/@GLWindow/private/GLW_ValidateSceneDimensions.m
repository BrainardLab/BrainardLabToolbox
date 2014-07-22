function validatedSceneDimensions = GLW_ValidateSceneDimensions(desiredSceneDimensions)
% validatedSceneDimensions = GLW_ValidateSceneDimensions(desiredSceneDimensions)
%
% Description:
% Validates the OpenGL scene dimensions.
%
% Input:
% desiredSceneDimensions (1x2|1x3|[]) - The width and height of the scene in
%   the plane of the monitor.  This willy typically be the size of the screen(s)
%   in centimeters.  If a 3rd value is passed, this will be interpreted as
%   the distance from the observer (camera) to the display.  Defaults to [40 30].
%
% Output:
% validatedSceneDimensions (1x2|1x3) - The validated scene dimensions.

if nargin ~= 1
	error('Usage: validatedSceneDimensions = GLW_ValidateSceneDimensions(desiredSceneDimensions)');
end

% Default
if isempty(desiredSceneDimensions)
	desiredSceneDimensions = [40 30];
end

% Verify size of the input.
if ~(isequal(size(desiredSceneDimensions), [1 2]) || isequal(size(desiredSceneDimensions), [1 3]))
	error('Scene dimensions must be a 1x2 or 1x3 array.');
end

if any(desiredSceneDimensions <= 0)
	error('Scene dimensions must consist of values greather than 0.');
end

validatedSceneDimensions = desiredSceneDimensions;
