function addOval(GLWObj, center, dimensions, rgbColor, varargin)
% addOval - Adds an oval to the GLWindow.
%
% Syntax:
% addOval(center, dimensions, rgbColor, [ovalOpts])
% 
% Description:
% Adds an oval to the GLWindow.
%
% Required Inputs:
% center (1x2 double) - Center of the oval (x, y).
% dimensions (1x2 double) - Width and Height of the oval.
% rgbColor (1x3 double) - RGB color of the oval in the range [0,1].

if nargin < 4
	error('Usage: addRectangle(center, dimensions, rgbColor, [ovalOpts])');
end

parser = inputParser;

parser.addRequired('Center', @isvector);
parser.addRequired('Dimensions', @isvector);
parser.addRequired('Color');
parser.addParamValue('Rotation', 0, @isscalar);
parser.addParamValue('Enabled', true, @islogical);
parser.addParamValue('Name', 'ovalObject', @ischar);
parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

% Execute the parser to make sure input is good.
parser.parse(center, dimensions, rgbColor, varargin{:});

obj = parser.Results;

% Assign a numerical object type ID for easy type checking later.
obj.ObjectType = GLWindow.ObjectTypes.Oval;

% Validate the passed RGB value(s).
obj.Color = GLW_ValidateRGBColor(obj.Color, GLWObj.DisplayTypeID);

% Validate the center param.
obj.Center = GLW_ValidateCenterParam(obj.Center, GLWObj.DisplayTypeID);

% Modify the auto gamma if it's enabled.  The function does nothing if it's
% not.
obj = GLWObj.addAutoGammaColor(obj);

% TODO - Make sure the render method was legit.

% Add the object to the render queue.
GLWObj.addObjectToQueue(obj);
