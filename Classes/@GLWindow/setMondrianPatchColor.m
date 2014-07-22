function setMondrianPatchColor(GLWObj, mondrianName, rowIndex, colIndex, patchColor)
% setMondrianPatchColor(mondrianName, rowIndex, colIndex, patchColor)
%
% Description:
% Sets the color of a particular patch in a Mondrian object.
%
% Input:
% GLWObj (GLWindow) - GLWindow object.
% mondrianName (string) - The name of the Mondrian object in the GLWindow.
% rowIndex (integer) - The row number of the patch to be modified.
% colIndex (integer) - The column number of the patch to be modified.
% patchColor (1x3 double) - (r,g,b) value of the new patch color.  Values
%	must be in the range [0,1].

if nargin ~= 5
	error('Usage: setMondrianPatchColor(mondrianName, rowIndex, colIndex, patchColor)');
end

% Validate the patch color.
patchColor = GLW_ValidateRGBColor(patchColor, GLWObj.DisplayTypeID);

% Get the queue index of the objects of interest.
queueIndex = GLWObj.findObjectIndex(mondrianName);

% Verify if the object was found.
if queueIndex == -1
	error('Mondrian with name "%s" not found.', mondrianName);
end

% Make sure that the object found is of type 'mondrian'.
if GLWObj.Objects{queueIndex}.ObjectType ~= GLWindow.ObjectTypes.Mondrian
	error('"%s" not a Mondrian object.', mondrianName);
end

% Make sure that the row and column indices are within the mondrian limits.
if rowIndex < 1 || rowIndex > GLWObj.Objects{queueIndex}.NumRows
	error('%d is not a valid row index.', rowIndex);
end
if colIndex < 1 || colIndex > GLWObj.Objects{queueIndex}.NumColumns
	error('%d is not a valid column index.', colIndex);
end

% Set the color if not in Bits++ mode.  The color values never change
% for the object in Bits++ mode, only the values in the gamma.
if any(GLWObj.DisplayTypeID == [GLWindow.DisplayTypes.BitsPP GLWindow.DisplayTypes.StereoBitsPP])
	error('Not implemented');
% 	g = GLWObj.Gamma;
% 	for ii = 1:GLWObj.NumWindows
% 		g{ii}(GLWObj.Objects{queueIndex}.BitsPPIndex,:) = objectColor(ii,:);
% 	end
% 	GLWObj.Gamma = g;
else
	for ii = 1:GLWObj.NumWindows
		GLWObj.Objects{queueIndex}.Color{ii}(rowIndex, colIndex,:) = patchColor(ii,:);
	end
end
