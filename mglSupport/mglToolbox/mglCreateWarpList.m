function warpListID = mglCreateWarpList(warpGrid, textureDims)

if nargin < 1 || nargin > 2
	error('Usage: warpListID = mglCreateWarpList(warpGrid, [textureDims])');
end

if nargout ~= 1
	error('Function output must be assigned.');
end

if nargin == 1
	textureDims = [1 1];
end

% Validate the warp grid dimensions.
if ndims(warpGrid) ~= 3 || size(warpGrid, 3) ~= 2
	error('"warpGrid" must be a MxNx2 matrix.');
end

% Validate the texture dimensions.
if ndims(textureDims) ~= 2 || ~all(size(textureDims) == [1 2])
	error('"textureDims" must be a 1x2 array.');
end

warpListID = private_mglCreateWarpList(warpGrid, textureDims);
