function mglBitsResetScreen(whichScreen)

dInfo = mglDescribeDisplays;

if ~exist('whichScreen', 'var') || isempty(whichScreen)
	whichScreen = length(dInfo);
end

mglSwitchDisplay(whichScreen);
mglOpen(whichScreen);
mglDisplayCursor;
identityGamma = mglGetIdentityGamma;
mglSetGammaTable(identityGamma');
mglClearScreen(0);
mglScreenCoordinates;
mglBitsPlusSetClut(linspace(0,1,256)' * [1 1 1]);
mglWaitSecs(0.2);
mglClose;
