function addHollowRectangle(GLWObj, center, width, height, lineThickness, rgbColor, varargin)
% addCursor3D - Adds a hollow rectangle.
%
% Syntax:
% obj.addHollowRectangle(center, width, height, lineThickness, rgbColor, [rectOpts])
%
%
% 4/22/2013  npc Wrote it.
%
    if nargin < 6
        error('Usage: addHollowRectangle(center, width, height, lineThickness, rgbColor, [cursorOpts])');
    end

    parser = inputParser;
    parser.addRequired('Center');
    parser.addRequired('Width', @(x)isscalar(x) && x > 0);
    parser.addRequired('Height', @(x)isscalar(x) && x > 0);
    parser.addRequired('LineThickness', @(x)isscalar(x) && x > 0);
    parser.addRequired('Color');
    parser.addParamValue('Enabled', true, @islogical);
    parser.addParamValue('Name', 'hollowRectangle', @ischar);
    parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

    % Execute the parser to make sure input is good.
    parser.parse(center, width, height, lineThickness, rgbColor, varargin{:});

    obj = parser.Results;

    % Assign a numerical object type ID for easy type checking later.
    obj.ObjectType = GLWindow.ObjectTypes.HollowRectangle;

    % Validate the passed RGB value(s).
    obj.Color = GLW_ValidateRGBColor(obj.Color, GLWObj.DisplayTypeID);

    % Modify the auto gamma if it's enabled.  The function does nothing if it's not.
    obj = GLWObj.addAutoGammaColor(obj);

    % Add the object to the render queue.
    GLWObj.addObjectToQueue(obj);
end
