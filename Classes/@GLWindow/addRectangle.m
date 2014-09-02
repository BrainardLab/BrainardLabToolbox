function addRectangle(GLWObj, center, dimensions, rgbColor, varargin)
% addRectangle - Adds a rectangle.
%
% Syntax:
% obj.addRectangle(center, dimensions, rgbColor, [rectOpts])
%
% Input:
% center (1x2|1x3) - Center of the rectangle (x,y) or (x,y,z).
% dimensions (1x2) - Width and Height of the rectangle.
% rgbColor (1x3) - RGB color of the rectangle in the range [0,1].

    if nargin < 4
        error('Usage: addRectangle(center, dimensions, rgbColor, [rectOpts])');
    end

    parser = inputParser;

    parser.addRequired('Center');
    parser.addRequired('Dimensions', @(x)isvector(x) && length(x) == 2);
    parser.addRequired('Color');

    parser.addParamValue('PhaseOffset', 0, @isscalar);
    parser.addParamValue('Rotation', [0 0 0 1]);
    parser.addParamValue('Enabled', true, @islogical);
    parser.addParamValue('Name', 'rectObject', @ischar);
    parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

    % Execute the parser to make sure input is good.
    parser.parse(center, dimensions, rgbColor, varargin{:});
    obj = parser.Results;

    % Assign a numerical object type ID for easy type checking later.
    obj.ObjectType = GLWindow.ObjectTypes.Rect;

    % Validate the passed RGB value(s).
    obj.Color = GLW_ValidateRGBColor(obj.Color, GLWObj.DisplayTypeID);

    % Validate the center param.
    obj.Center = GLW_ValidateCenterParam(obj.Center, GLWObj.DisplayTypeID);

    % Validate the rotation parameter.
    obj.Rotation = GLW_ValidateRotation(obj.Rotation, GLWObj.DisplayTypeID);

    % Modify the auto gamma if it's enabled.  The function does nothing if it's
    % not.
    obj = GLWObj.addAutoGammaColor(obj);

    % TODO - Make sure the render method was legit.

    % Add the object to the render queue.
    GLWObj.addObjectToQueue(obj);

end

