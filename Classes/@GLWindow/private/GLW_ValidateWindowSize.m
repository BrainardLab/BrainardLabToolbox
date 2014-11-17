function validatedWindowSize = GLW_ValidateWindowSize(desiredWindowSize)
% validatedWindowSize = GLW_ValidateWindowSize(desiredWindowSize)
%
% Description:
% Validates the desired window size for non fullscreen mode windows.  The
% window size applies to all windows attached to the GLWindow instance.
%
% Input:
% desiredWindowSize (1x2 double|[]) - Width and height of the window(s) in
%   pixels.
%
% Output:
% validatedWindowSize (1x2 double) - Validated window size.

if nargin ~= 1
	error('Usage:  validatedWindowSize = GLW_ValidateWindowSize(desiredWindowSize)');
end

% Default.
if isempty(desiredWindowSize)
	desiredWindowSize = [350 350];
end

if ndims(desiredWindowSize) ~= 2 || ~all(size(desiredWindowSize) == [1 2])
	error('"desiredWindowSize" must be a 1x2 vector.');
end

% Make sure the values are > 0.
if any(desiredWindowSize <= 0)
	error('Values must be > 0.');
end

% Round the window size to remove decimals since these values should
% specify pixels, which must be integers.
validatedWindowSize = round(desiredWindowSize);
