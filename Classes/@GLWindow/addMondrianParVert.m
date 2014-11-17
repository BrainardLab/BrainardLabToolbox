function addMondrianParVert(GLWObj, numRows, numColumns, dimensions, colors, varargin)
% glwObj = addMondrian(glwObj, numRows, numColumns, dimensions, colors, varargin)
%
% Description:
% Adds a mondrian to the GLWindow.
%
% Required Inputs:
% numRows (scalar) - Number of rows in the mondrian.
% numColumns (scalar) - Number of columns in the mondrian.
% dimensions (1x2 double) - Width and height of the mondrian in window
%	coordinates.
% colors (numRows x numColumns x 3 double) - The RGB value for each element
%	of the mondrian.  The upper left element is position (1,1) and the
%	lower right element is position (numColumns, numRows).
%
% Optional Inputs:
% 'Center' (1x2 double) - (x,y) position of the center of the mondrian.
% 'Enabled' (logical) - Enables/Disables the object in the drawing pipeline.
% 'Name' (string) - Name of the object.


% 1/14/10 TYL re-wrote this, by changing some code in Horizontal Adelson
% verticies shifting portion
% 1/18/10 TYL changed Vertical Adelson vertices shifting code
% 10/29/10 TYL updated to new GLWindow syntax
% 11/7/10 TYL added new case

if nargin < 5
	error('Usage: addRectangle(numRows, numColumns, dimensions, colors, [mondrianOpts])');
end

parser = inputParser;

parser.addRequired('NumRows', @(x)isscalar(x) && x >= 1);
parser.addRequired('NumColumns', @(x)isscalar(x) && x >= 1);
parser.addRequired('Dimensions', @(x)isvector(x) && length(x) == 2);
parser.addRequired('Color');

parser.addParamValue('Rotation', 0, @isscalar);
parser.addParamValue('Type', 'Normal', @ischar);
parser.addParamValue('Center', [0 0], @(x)isvector(x) && length(x) == 2);
parser.addParamValue('Enabled', true, @islogical);
parser.addParamValue('Name', 'mondrianObject', @ischar);
parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);
parser.addParamValue('Border', 0, @isscalar);

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

% Shift some of the vertices around if this is an Adelson Mondrian.
switch obj.Type
	case GLWindow.MondrianTypes.HorizontalAdelson
	% The horizontal shift amount is the width of .75 column.
	shiftAmount = obj.Verts(1,2,1) - obj.Verts(1,1,1);
	
	offset = 0;
			offset = offset + .75*shiftAmount;

		
		obj.Verts(:,1,2) = obj.Verts(:,1,2) + 3*offset;
		obj.Verts(:,2,2) = obj.Verts(:,2,2) + 2*offset;
		obj.Verts(:,3,2) = obj.Verts(:,3,2) + offset;
		obj.Verts(:,5,2) = obj.Verts(:,5,2) - offset;
		obj.Verts(:,6,2) = obj.Verts(:,6,2) - 2*offset;
		
	case GLWindow.MondrianTypes.VerticalAdelson
		% The horizontal shift amount is the width of .75 column.
	shiftAmount = obj.Verts(1,2,1) - obj.Verts(1,1,1);
	
	offset = 0;
			offset = offset + .75*shiftAmount;

		obj.Verts(:,6,2) = obj.Verts(:,6,2) + 3*offset;
		obj.Verts(:,5,2) = obj.Verts(:,5,2) + 2*offset;
		obj.Verts(:,4,2) = obj.Verts(:,4,2) + offset;
		obj.Verts(:,2,2) = obj.Verts(:,2,2) - offset;
		obj.Verts(:,1,2) = obj.Verts(:,1,2) - 2*offset;

end

% Add the object to the render queue.
GLWObj.addObjectToQueue(obj);
