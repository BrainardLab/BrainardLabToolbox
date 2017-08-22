function addWedge(GLWObj, center, innerRadius, outerRadius, startAngle, sweep, rgbColor, varargin)
% addWedge - Adds a wedge to the GLWindow.
%
% Syntax:
% obj.addWedge(center, innerRadius, outerRadius, startAngle, sweet, rgbColor);
% obj.addWedge(center, innerRadius, outerRadius, startAngle, sweet, rgbColor, wedgeOptions);
%
% Description:
% Adds a wedge to the GLWindow.  The wedge spans from the inner radius to
% the outer radius and from the start angle to the extent of its sweep.
%
% Input:
% center (1x2) - (x,y) position of the wedge center. A wedge's center is
%     defined as the theoretical center of a the circle upon which the
%     wedge exists.
% innerRadius (scalar) - The radius from the center to the inner part of the
%     wedge.
% outerRadius (scalar) - The radius from the center to the outer part of
%     the wedge.
% startAngle (scalar) - The angle in degrees from where the wedge begins.
% sweep (scalar) - The span of the wedge in degrees from the start angle.
% rgbColor (1x3|cell array|struct) - RGB color of the wedge.
% wedgeOptions (key/value) - Set of key/value pairs defining optional
%     information about the wedge.

narginchk(7, Inf);

parser = inputParser;

parser.addRequired('Center', @isvector);
parser.addRequired('InnerRadius', @isscalar);
parser.addRequired('OuterRadius', @isscalar);
parser.addRequired('StartAngle', @isscalar);
parser.addRequired('Sweep', @isscalar);
parser.addRequired('Color', @(x)isvector(x) && length(x) == 3);

parser.addParamValue('NumSlices', 8, @isscalar);
parser.addParamValue('NumLoops', 1, @isscalar);
parser.addParamValue('Enabled', true, @islogical);
parser.addParamValue('Name', 'wedgeObject', @ischar);
parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

% Execute the parser to make sure input is good.
parser.parse(center, innerRadius, outerRadius, startAngle, sweep, rgbColor, varargin{:});

obj = parser.Results;

% Assign a numerical object type ID for easy type checking later.
obj.ObjectType = GLWindow.ObjectTypes.Wedge;

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
