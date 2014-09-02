function winInfo = GLW_CreateWindowInfoStruct(numWindows)
% GLW_CreateWindowInfoStruct - Creates the empty WindowInfo property data.
%
% Syntax:
% winInfo = GLW_CreateWindowInfoStruct(numWindows)
%
% Description:
% Creates a generic window info struct array.  The default values are
% meaningless and will be set later or via property set methods or private
% initialization methods.
%
% Input:
% numWindows (integer) - The number of windows to track.
%
% Output:
% winInfo (1xN struct) - This array will be 1xnumWindows and will contain
%   all the fields necessary for each window attached to the GLWindow
%   object.

for i = 1:numWindows
	winInfo(i) = struct('BackgroundColor', [0 0 0 0], ...
		'BitsPP', false, ...
		'FBObject', -1, ...
		'WarpScale', [-1 -1], ...
		'WarpTranslation', [-1 -1], ...
		'WarpList', -1, ...
		'Gamma', zeros(256,3), ...
		'WindowID', -500, ...
		'WarpFile', 'dummy', ...
		'Warp', false); %#ok<AGROW>
end
