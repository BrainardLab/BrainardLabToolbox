function gammaTable = getGammaTable(glwObj)
% glwObj = getGammaTable(glwObj)
%
% Description:
% Returns the internal gamma table.
%
% Input:
% glwObj (GLWindow) - GLWindow object.
%
% Output:
% gammaTable (256x3 | cell array) - Internally stored gamma table.

if nargin ~= 1
	error('Usage: glwObj = getGammaTable(glwObj)');
end

gammaTable = glwObj.gamma;
