function glwObj = addTriangle(glwObj, center, dimensions, rgbColor, varargin)
% addTriangle(glwObj, center, dimensions, rgbColor, [triangleOpts])
% 
% Description:
% Adds a triangle to the GLWindow.
%
% Required Input:
% glwObj (GLWindow) - The GLWindow into which we are drawing.
% center (1x2 double) - Center of the triangle (x, y).
% dimensions (1x2 double) - Width and height of the triangle.
% rgbColor (1x3 double) - RGB color of the triangle in the range [0,1].

if nargin < 4
	error('Usage: addTriangle(glwObj, center, dimensions, rgbColor, [rectOpts])');
end

parser = inputParser;

parser.addRequired('center', @(x)isvector(x) && length(x) == 2);
parser.addRequired('dimensions', @(x)isvector(x) && length(x) == 2);
parser.addRequired('color', @(x)isvector(x) && length(x) == 3);

parser.addParamValue('phaseoffset', 0, @isscalar);
parser.addParamValue('rotation', 0, @isscalar);
parser.addParamValue('enabled', true, @islogical);
parser.addParamValue('name', 'rectObject', @ischar);
parser.addParamValue('rendermethod', 'normal', @ischar);

% Execute the parser to make sure input is good.
parser.parse(center, dimensions, rgbColor, varargin{:});

obj = parser.Results;
obj.objecttype = glwObj.private.consts.objectTypes.triangle;

% Convert the colors depending on the display type.
switch glwObj.displaytype
	case glwObj.private.consts.displayTypes.bitspp
		% The object keeps track of its Bits++ index for later use.
		obj.bitsppIndex = glwObj.private.bitsppIndex;
		
		% Add the calibrated object color to the gamma table, get the new
		% object color based on the Bits++ gamma index, and return the
		% incremented Bits++ index.
		[glwObj.gamma(obj.bitsppIndex, :), obj.color, glwObj.private.bitsppIndex] = ...
			processBitsPPColor(glwObj.private.cal, obj.color, glwObj.private.bitsppIndex);
		
		% Set the rest of the gamma to be the identity.  This is useful for
		% showing text without having screwed up shading colors.
		glwObj.gamma(glwObj.private.bitsppIndex:256, :) = ...
			linspace(0, 1, 256-glwObj.private.bitsppIndex+1)' * [1 1 1];
		
	case glwObj.private.consts.displayTypes.hdr
		obj.color = processHDRColor(obj.color, glwObj.hdrpreprocessinghook, ...
			glwObj.hdrgammacorrectionmode);
		
	case {glwObj.private.consts.displayTypes.stereo, glwObj.private.consts.displayTypes.stereobitspp}
		obj.color(2,:) = obj.color(1,:);
end

% Convert the specified string form of the render method into an
% internalized numerical form.
switch lower(obj.rendermethod)
	case 'normal'
		obj.rendermethod = glwObj.private.consts.renderMethods.normal;
	otherwise
		error('Invalid render method "%s".', obj.rendermethod);
end

% Look to see if this object already exists in the object queue.  If so,
% we'll replace the old object.  If not, we add the new one to the end of the queue.
queueIndex = GLW_FindObjectIndex(glwObj.private.objects, obj.name);

% queueIndex == -1 if not the object was not found in the queue.
if queueIndex == -1
	queueIndex = length(glwObj.private.objects) + 1;
	
	%fprintf('* New object %s in slot %d\n', obj.name, queueIndex);
else
	%fprintf('* Replacing object %s in slot %d\n', obj.name, queueIndex);
end

% Add the rect to drawing queue.
glwObj.private.objects{queueIndex} = obj;
