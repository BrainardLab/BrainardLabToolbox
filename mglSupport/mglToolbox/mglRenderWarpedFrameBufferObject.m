function mglRenderWarpedFrameBufferObject(FBOTexture, warpList, sceneDimensions)

if nargin ~= 3
	error('Usage: mglRenderWarpedFrameBufferObject(FBOTexture, warpList, sceneDimensions)');
end

if ~isscalar(FBOTexture)
	error('"FBOTexture" must be a scalar value.');
end

if ~isscalar(warpList)
	error('"warpList" must be a scalar value.');
end

if ndims(sceneDimensions) ~= 2 || ~all(size(sceneDimensions) == [1 2])
	error('"sceneDimensions" must be a 1x2 array.');
end

% mglClearScreen(0);

private_mglRenderWarpedFrameBufferObject(FBOTexture, warpList, sceneDimensions);
