function addPolygonSet(GLWObj, vertexList, rgbColor, varargin)
% addPolygonSet - Adds a set of polygons.
%
% Syntax:
% addPolygonSet(vertexList, rgbColor, [polygonSetOpts])
%
% Input:
% vertexList (1xN cell) - Cell array where each element is the set of
%   vertices for a single polygon.
% rgbColor (Nx3|struct|cell array) - RGB values for each polygon.

if nargin < 3
	error('Usage: addPolygonSet(vertexList, rgbColor, [polygonSetOpts])');
end

parser = inputParser;

parser.addRequired('VertexList');
parser.addRequired('Color');

parser.addParamValue('Rotation', [0 0 0 1]);
parser.addParamValue('Enabled', true, @islogical);
parser.addParamValue('Name', 'polygonSetObject', @ischar);
parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

% Execute the parser to make sure input is good.
parser.parse(vertexList, rgbColor, varargin{:});

obj = parser.Results;

% Assign a numerical object type ID for easy type checking later.
obj.ObjectType = GLWindow.ObjectTypes.PolygonSet;

% Validate the passed RGB value(s).
obj.Color = GLW_ValidatePolygonSetColors(obj.Color, GLWObj.DisplayTypeID);

% Validate the rotation parameter.
obj.Rotation = GLW_ValidateRotation(obj.Rotation, GLWObj.DisplayTypeID);

% Make sure there is a color defined for every single polygon.
if length(vertexList) ~= size(obj.Color{1}, 1)
	error('Number of polygons must match the number of defined colors.');
end

% % Modify the auto gamma if it's enabled.  The function does nothing if it's
% % not.
% obj = GLWObj.addAutoGammaColor(obj);

% TODO - Make sure the render method was legit.

% Add the object to the render queue.
GLWObj.addObjectToQueue(obj);
