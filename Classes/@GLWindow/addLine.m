function addLine(GLWObj, startPoint, endPoint, thickNess, rgbColor, varargin)
% addLine(startPoint, endPoint, thickNess, rgbColor, [lineOpts])
%
% Description:
% Adds a line to the GLWindow.
%
% Required Input:
% startPoint (1x2) - (x,y) coordinates of the line start point.
% endPoint (1x2) - (x,y) coordinates of the line end point.
% thickNess (scalar) - Thickness of the line in pixels.  Must be a value
%   greater than 0.
% rgbColor (1x3) - RGB color of the line in the range [0,1].

if nargin < 4
	error('Usage: addLine(startPoint, endPoint, thickNess, rgbColor, [lineOpts])');
end

parser = inputParser;

parser.addRequired('StartPoint');
parser.addRequired('EndPoint');
parser.addRequired('Thickness', @(x)isscalar(x) && x > 0);
parser.addRequired('Color');

parser.addParamValue('Rotation', [0 0 0 1]);
parser.addParamValue('Enabled', true, @islogical);
parser.addParamValue('Name', 'lineObject', @ischar);
parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

% Execute the parser to make sure input is good.
parser.parse(startPoint, endPoint, thickNess, rgbColor, varargin{:});

obj = parser.Results;

% Assign a numerical object type ID for easy type checking later.
obj.ObjectType = GLWindow.ObjectTypes.Line;

% Validate the passed RGB value(s).
obj.Color = GLW_ValidateRGBColor(obj.Color, GLWObj.DisplayTypeID);

% Validate the 2 end points.  We can use the CenterParam validator since we
% just want to make sure they are 1x2 values.
obj.StartPoint = GLW_ValidateCenterParam(obj.StartPoint, GLWObj.DisplayTypeID);
obj.EndPoint = GLW_ValidateCenterParam(obj.EndPoint, GLWObj.DisplayTypeID);

% Validate the rotation parameter.
obj.Rotation = GLW_ValidateRotation(obj.Rotation, GLWObj.DisplayTypeID);

% Modify the auto gamma if it's enabled.  The function does nothing if it's
% not.
obj = GLWObj.addAutoGammaColor(obj);

% TODO - Make sure the render method was legit.

% Add the object to the render queue.
GLWObj.addObjectToQueue(obj);
