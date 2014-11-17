function mglBitsBlankScreen(screenNumber)
% mglBitsBlankScreen([screenNumber])
%
% Description:
% Turns the specified screen to black via Bits++.
%
% Optional Input:
% screenNumber (integer) - Id of the screen to be blanked.  Screen numbers
%	start from 1.  Defaults to -1, which means the last screen attached to
%	the computer is selected.

dInfo = mglDescribeDisplays;

if ~exist('screenNumber', 'var') || isempty(screenNumber)
	screenNumber = length(dInfo);
end

mglSwitchDisplay(screenNumber);
mglOpen(screenNumber);
identityGamma = mglGetIdentityGamma;
mglSetGammaTable(identityGamma');
mglWaitSecs(0.2);
mglClearScreen(0);
mglScreenCoordinates;
mglBitsPlusSetClut(zeros(256, 3));
WaitSecs(0.2);
mglClose;
