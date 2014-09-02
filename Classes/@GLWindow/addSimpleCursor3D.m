function addSimpleCursor3D(GLWObj, diameter, lineThickness, rgbColor, varargin)
% addCursor3D - Adds a 3D cursor.
%
% Syntax:
% obj.addCursor3D(diameter, diskDiameter, lineWidth, rgbColor, [rectOpts])
%
% Input:
% diameter (1x1)    - length of the cross-hairs.
% diskDiameter (1x1)- disk diameter 
% lineWidth (1x1)   - line width of the cursor.
% rgbColor (1x3)    - RGB color of the cursor in the range [0,1].
%
% 3/21/2013  npc Wrote it.
%
    if nargin < 3
        error('Usage: addCursor3D(diameter, lineThickness, rgbColor, [cursorOpts])');
    end

    parser = inputParser;
    parser.addRequired('Diameter', @(x)isscalar(x) && x > 0);
    parser.addRequired('LineThickness', @(x)isscalar(x) && x > 0);
    parser.addRequired('Color');
    parser.addParamValue('Enabled', true, @islogical);
    parser.addParamValue('Name', 'cursor3DObject', @ischar);
    parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

    % Execute the parser to make sure input is good.
    parser.parse(diameter,lineThickness, rgbColor, varargin{:});

    obj = parser.Results;

    % Assign a numerical object type ID for easy type checking later.
    obj.ObjectType = GLWindow.ObjectTypes.SimpleCursor3D;

    % Validate the passed RGB value(s).
    obj.Color = GLW_ValidateRGBColor(obj.Color, GLWObj.DisplayTypeID);

    % Modify the auto gamma if it's enabled.  The function does nothing if it's not.
    obj = GLWObj.addAutoGammaColor(obj);

    % Add the object to the render queue.
    GLWObj.addObjectToQueue(obj);
end
