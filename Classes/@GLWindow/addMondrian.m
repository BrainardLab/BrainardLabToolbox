function addMondrian(GLWObj, numRows, numColumns, dimensions, colors, varargin)
% addMondrian(numRows, numColumns, dimensions, colors, [mondrianOpts])
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
%	lower right element is position (numRows, numColumns).
%
% Optional Inputs:
% 'Center' (1x2|1x3) - (x,y) or (x,y,z) position of the center of the mondrian.
% 'Enabled' (logical) - Enables/Disables the object in the drawing pipeline.
% 'Name' (string) - Name of the object.

if nargin < 5
	error('Usage: addRectangle(numRows, numColumns, dimensions, colors, [mondrianOpts])');
end

parser = inputParser;

parser.addRequired('NumRows', @(x)isscalar(x) && x >= 1);
parser.addRequired('NumColumns', @(x)isscalar(x) && x >= 1);
parser.addRequired('Dimensions', @(x)isvector(x) && length(x) == 2);
parser.addRequired('Color');

parser.addParamValue('Rotation', [0 0 0 1]);
parser.addParamValue('Type', 'Normal', @ischar);
parser.addParamValue('Center', [0 0 0]);
parser.addParamValue('Enabled', true, @islogical);
parser.addParamValue('Name', 'mondrianObject', @ischar);
parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);
parser.addParamValue('Border', 0, @isscalar);
parser.addParamValue('ShiftAmount', NaN);

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
	case 'smoothwall'
		obj.Type = GLWindow.MondrianTypes.SmoothWall;
	case 'jaggedwall'
		obj.Type = GLWindow.MondrianTypes.JaggedWall;
	otherwise
		error('Invalid Mondrian type "%s".', obj.Type);
end

% Validate the colors.
obj.Color = GLW_ValidateMondrianColors(obj.Color, GLWObj.DisplayTypeID);

% Validate the center param.
obj.Center = GLW_ValidateCenterParam(obj.Center, GLWObj.DisplayTypeID);

% Validate the rotation parameter.
obj.Rotation = GLW_ValidateRotation(obj.Rotation, GLWObj.DisplayTypeID);

% Make sure that the number of colors matches the number of rows and
% columns.
for i = 1:length(obj.Color)
	colorDims = size(obj.Color{i});
	
	if ~isequal(colorDims(1:2), [numRows numColumns])
		error('Number of colors doesn''t match with the number of rows and columns of the Mondrian.');
	end
end

% Create a grid of vertices which we'll use to draw the mondrian.
[x, y] = meshgrid(linspace(0, obj.Dimensions(1), numColumns+1), ...
	linspace(0, obj.Dimensions(2), numRows+1));
obj.Verts = zeros([size(x), 2]);
obj.Verts(:,:,1) = x;
obj.Verts(:,:,2) = flipdim(y, 1);

% Set the matrix containing all the patch depths to zero.  Note that center
% param is additive with this value.
obj.PatchDepths = zeros(numRows, numColumns);

% Set the matrix containing individual path rotations to zero.
obj.PatchRotations = zeros(numRows, numColumns, 4);

% Shift some of the vertices around if this is an Adelson Mondrian.
switch obj.Type
	case GLWindow.MondrianTypes.HorizontalAdelson
		% Get a list of all rows that need shifting.
		shiftRows = mod((1:numRows)+1, 2);
		shiftRows(1) = 1;
		shiftRows = ~shiftRows;
		
		if isnan(obj.ShiftAmount)
			% The horizontal shift amount is the width of one column.
			shiftAmount = obj.Verts(1,2,1) - obj.Verts(1,1,1);
		else
			shiftAmount = obj.ShiftAmount;
		end
		
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
		
		if isnan(obj.ShiftAmount)
			% The vertical shift amount is the width of one row.
			shiftAmount = obj.Verts(2,1,2) - obj.Verts(1,1,2);
		else
			shiftAmount = obj.ShiftAmount;
		end
		
		offset = 0;
		for i = 1:numColumns
			if shiftColumns(i)
				shiftAmount = -shiftAmount;
				offset = offset + shiftAmount;
			end
			
			obj.Verts(:,i,2) = obj.Verts(:,i,2) + offset;
		end
		
	case {GLWindow.MondrianTypes.SmoothWall, GLWindow.MondrianTypes.JaggedWall}
		% The pinch distance is half the height of a single row.  I define
		% pinch as the amount needed to make 2 corners of the same patch
		% touch each other, i.e. become the same vertex.
		pinchSize = dimensions(2) / numRows / 2;
		
		if obj.Type == GLWindow.MondrianTypes.JaggedWall
			expansionSize = 0;
		else
			% The expansion distance is used to make the non pinched edges of a
			% patch slightly bigger.  We do it so the illusion looks nicer.
			expansionSize = pinchSize / 2;
		end
		
		% Get a list of rows where the right side of the first column is
		% pinched in.
		p2Rows = 2:6:numRows;
		
		% Loop all columns in each row and apply the pinch.  
		for row = p2Rows
			for col = 1:numColumns+1
				if mod(col, 2)
					obj.Verts(row,col,2) = obj.Verts(row,col,2) + expansionSize;
					obj.Verts(row+1,col,2) = obj.Verts(row+1,col,2) - expansionSize;
				else
					obj.Verts(row,col,2) = obj.Verts(row,col,2) - pinchSize;
					obj.Verts(row+1,col,2) = obj.Verts(row+1,col,2) + pinchSize;
				end
			end
		end
		
		% Get a list of the rows that have a pinched in left side for the
		% first column.
		p1Rows = 5:6:numRows;
		
		% Loop and apply the pinch.
		for row = p1Rows
			for col = 1:numColumns+1
				if mod(col, 2)
					obj.Verts(row,col,2) = obj.Verts(row,col,2) - pinchSize;
					obj.Verts(row+1,col,2) = obj.Verts(row+1,col,2) + pinchSize;
				else
					obj.Verts(row,col,2) = obj.Verts(row,col,2) + expansionSize;
					obj.Verts(row+1,col,2) = obj.Verts(row+1,col,2) - expansionSize;
				end
			end
		end
		
		% For Mondrians of the jagged wall type, we need to adjust a few
		% more rows and columns.
		if obj.Type == GLWindow.MondrianTypes.JaggedWall			
			% Find rows that need to be pinched down.
			pdRows = 1:6:numRows;
			
			% Pinch every other column down for those rows.
			for row = pdRows
				for col = 1:numColumns
					if mod(col, 2)
						obj.Verts(row,col+1,2) = obj.Verts(row,col+1,2) - pinchSize;
					end
				end
			end
			
			% Find rows that need to be pinched up.
			pdRows = 3:6:numRows;
			
			% Pinch every other column down for those rows.
			for row = pdRows
				for col = 1:numColumns
					if mod(col, 2)
						obj.Verts(row+1,col+1,2) = obj.Verts(row+1,col,2) + pinchSize;
					end
				end
			end
			
			% Some of the rows will now look too tall, so we need to adjust
			% for that.
			shrinkSize =  .5 * dimensions(2) / numRows;
			sRows = [4:6:numRows, 6:6:numRows];
			for row = sRows
				obj.Verts(row+1:end,:,2) = obj.Verts(row+1:end,:,2) + shrinkSize;
			end
			
			% The overall height of the Mondrian won't match the requested
			% height.  The Mondrian will have essentially been shortened
			% from the bottom, so now we need to add in an offset to all
			% rows to stretch it back out.
			newHeight = obj.Verts(1,1,2) - obj.Verts(end,1,2);
			scaleFactor = obj.Dimensions(2) / newHeight;
			obj.Verts(:,:,2) = (obj.Verts(:,:,2) - obj.Verts(end,1,2)) * scaleFactor;
		end
end

% Add the object to the render queue.
GLWObj.addObjectToQueue(obj);
