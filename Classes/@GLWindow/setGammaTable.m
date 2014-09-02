function glwObj = setGammaTable(glwObj, gammaTable)
% glwObj = setGammaTable(glwObj, gammaTable)
% 
% Description:
% Sets the gamma of the GLWindow.  This function is powerful in that it
% assumes you know what you're doing by overriding the internally
% controlled gamma.  Useful if you need to temporarily change the gamma.
%
% Inputs:
% glwObj (GLWindow) - GLWindow object.
% gammaTable (256x3 matrix | cell array) - Gamma table in the range [0,1].
%
% Output:
% glwObj (GLWindow) - Updated GLWindow object.

if nargin ~= 2
	error('Usage: glwObj = setGammaTable(glwObj, gammaTable)');
end

% Verify the input.
switch glwObj.displaytype
	case {glwObj.private.consts.displayTypes.bitspp, ...
		  glwObj.private.consts.displayTypes.normal}
	  if ~isnumeric(gammaTable) || ~all(size(gammaTable) == [256 3])
		  error('gammaTable must be a 256x3 matrix.');
	  end

	  glwObj.gamma = gammaTable;
		
	case {glwObj.private.consts.displayTypes.stereo, ...
		  glwObj.private.consts.displayTypes.stereobitspp, ...
		  glwObj.private.consts.displayTypes.hdr}
	  
	  if ~iscell(gammaTable) || ~all(size(gammaTable) == [1 2])
		  error('gammaTable must be a 1x2 cell array.');
	  end
	  
	  for i = 1:2
		  if ~isnumeric(gammaTable{i}) || ~all(size(gammaTable{i}) == [256 3])
			  error('Each gammaTable entry must be a 256x3 matrix.');
		  end
	  end

	  glwObj.gamma = gammaTable;
		
	otherwise
		error('Invalid display type "%s" specified.', glwObj.displaytype);
end

% Set the video card gamma immediately if the window is open and
% we're not in any sort of Bits++ mode.  In Bits++ modes, the gamma is set
% when GLWindow/draw is called.
excludedDisplayTypes = [glwObj.private.consts.displayTypes.bitspp, ...
						glwObj.private.consts.displayTypes.stereobitspp];
if glwObj.private.isOpen && ~any(glwObj.displaytype == excludedDisplayTypes)
	for i = 1:length(glwObj.windowid)
		mglSwitchDisplay(glwObj.windowid(i));
		mglSetGammaTable(glwObj.gamma');
	end
end
