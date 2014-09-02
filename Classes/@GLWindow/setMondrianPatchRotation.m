function setMondrianPatchRotation(GLWObj, mondrianName, rowIndex, colIndex, patchRotation)
% setMondrianPatchDepth(mondrianName, rowIndex, colIndex, patchDepth)
%
% Description:
% Sets the rotation of a particular patch in a Mondrian object.
%
% Input:
% GLWObj (GLWindow) - GLWindow object.
% mondrianName (string) - The name of the Mondrian object in the GLWindow.
% rowIndex (integer) - The row number of the patch to be modified.
% colIndex (integer) - The column number of the patch to be modified.
% patchRotation (1x4) - Rotation in degrees plus the (x,y,z) rotation vector.

if nargin ~= 5
	error('Usage: setMondrianPatchDepth(mondrianName, rowIndex, colIndex, patchRotation)');
end

% Validate the patch depth.
if ~isequal(size(patchRotation), [1 4])
	error('"patchRotation" must be a 1x4 vector.');
end

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
	GLWObj.Objects{queueIndex}.PatchRotations(rowIndex, colIndex, :) = patchRotation;
end
