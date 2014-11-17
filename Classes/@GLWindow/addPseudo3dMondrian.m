function addPseudo3dMondrian(GLWObj, numRows, numColumns, dimensions, colors, splitType, varargin)
% glwObj = addMondrian(glwObj, numRows, numColumns, dimensions, colors,[mondrianOpts])
%
% Description:
% Adds a pseudo 3d mondrian of 2 patches to the GLWindow.
%
% Required Inputs:
% numRows (scalar) - Number of rows in the mondrian.
% numColumns (scalar) - Number of columns in the mondrian.
% dimensions (1x2 double) - Width and height of the mondrian in window
%	coordinates.
% colors (numRows x numColumns x 3 double) - The RGB value for each element
%	of the mondrian.  The upper left element is position (1,1) and the
%	lower right element is position (numColumns, numRows).
% splitType - which columns to fold down.  1 = rightmost column, 2 = 2
% rightmost columns, 4 = 4 rightmost columns
%
% Optional Inputs:
% 'Center' (1x2 double) - (x,y) position of the center of the mondrian.
% 'Enabled' (logical) - Enables/Disables the object in the drawing pipeline.
% 'Name' (string) - Name of the object.

if nargin < 5
	error('Usage: addRectangle(glwObj, numRows, numColumns, dimensions, colors, [mondrianOpts])');
end

parser = inputParser;

parser.addRequired('numrows', @(x)isscalar(x) && x >= 1);
parser.addRequired('numcolumns', @(x)isscalar(x) && x >= 1);
parser.addRequired('dimensions', @(x)isvector(x) && length(x) == 2);
parser.addRequired('color', @(x)size(x,1) == numRows && size(x,2) == numColumns && size(x,3) == 3);

parser.addParamValue('rotation', 0, @isscalar);
parser.addParamValue('type', 'normal', @ischar);
parser.addParamValue('center', [0 0], @(x)isvector(x) && length(x) == 2);
parser.addParamValue('enabled', true, @islogical);
parser.addParamValue('name', 'mondrianObject', @ischar);
parser.addParamValue('rendermethod', 'normal', @ischar);
parser.addParamValue('border', 0, @isscalar);

% Execute the parser to make sure input is good.
parser.parse(numRows, numColumns, dimensions, colors, varargin{:});

obj = parser.Results;
obj.ObjectType = GLWindow.ObjectTypes.Mondrian;

% Convert the Mondrian type to a numerical form.
switch lower(obj.Type)
	case 'normal'
		obj.Type = GLWindow.MondrianTypes.Normal;
	case 'horizontaladelson'
		obj.Type = GLWindow.MondrianTypes.HorizontalAdelson;
	case 'verticaladelson'
		obj.Type = GLWindow.MondrianTypes.VerticalAdelson;
	otherwise
		error('Invalid Mondrian type "%s".', obj.Type);
end

% Validate the colors.
obj.Color = GLW_ValidateMondrianColors(obj.Color, GLWObj.DisplayTypeID);

% Validate the center param.
obj.Center = GLW_ValidateCenterParam(obj.Center, GLWObj.DisplayTypeID);

% Create a grid of vertices which we'll use to draw the mondrian.
[x, y] = meshgrid(linspace(0, obj.Dimensions(1), numColumns+1), ...
	linspace(0, obj.Dimensions(2), numRows+1));
obj.Verts = zeros([size(x), 2]);
obj.Verts(:,:,1) = x;
obj.Verts(:,:,2) = flipdim(y, 1);

% Shift vertices for folding
% The vertical shift amount is the width of 1.15 rows.
	shiftAmount = obj.Verts(2,1,2) - obj.Verts(1,1,2);
    shiftAmount = 1.15*shiftAmount;
if splitType == 1
    obj.Verts(:,end,2) = obj.Verts(:,end,2) + shiftAmount;
elseif splitType == 2
    obj.Verts(:,end-1,2) = obj.Verts(:,end-1,2) + shiftAmount;
    obj.Verts(:,end,2) = obj.Verts(:,end-1,2) + shiftAmount;
elseif splitType == 4
    obj.Verts(:,end-3,2) = obj.Verts(:,end-3,2) + shiftAmount;
    obj.Verts(:,end-2,2) = obj.Verts(:,end-3,2) + shiftAmount;
    obj.Verts(:,end-1,2) = obj.Verts(:,end-2,2) + shiftAmount;
    obj.Verts(:,end,2) = obj.Verts(:,end-1,2) + shiftAmount;
end

% Shift some of the vertices around if this is an Adelson Mondrian.
switch obj.Type
	case GLWindow.MondrianTypes.HorizontalAdelson
		% Get a list of all rows that need shifting.
		shiftRows = mod((1:numRows)+1, 2);
		shiftRows(1) = 1;
		shiftRows = ~shiftRows;
		
		% The horizontal shift amount is the width of one column.
		shiftAmount = obj.Verts(1,2,1) - obj.Verts(1,1,1);
		
		offset = 0;
		for i = 1:numRows
			if shiftRows(i)
				shiftAmount = -shiftAmount;
				offset = offset + shiftAmount;
			end
			
			obj.Verts(i,:,1) = obj.Verts(i,:,1) + offset;
		end
		
	case GLWindow.MondrianTypes.VerticalAdelson
		% Get a list of all columns that need shifting.
		shiftColumns = mod((1:numColumns)+1, 2);
		shiftColumns(1) = 1;
		shiftColumns = ~shiftColumns;
		
		% The vertical shift amount is the width of one row.
		shiftAmount = obj.Verts(2,1,2) - obj.Verts(1,1,2);
		
		offset = 0;
		for i = 1:numColumns
			if shiftColumns(i)
				shiftAmount = -shiftAmount;
				offset = offset + shiftAmount;
			end
			
			obj.Verts(:,i,2) = obj.Verts(:,i,2) + offset;
		end
end

% Add the object to the render queue.
GLWObj.addObjectToQueue(obj);
