function addMonocularCursor(GLWObj, diameter,  lineThickness, rgbColor, varargin)
% addMonocularCursor - Adds a monocular cursor.
%
% Syntax:
% obj.addMonocularCursor(diameter,  lineThickness, rgbColor, [rectOpts])
%
% Input:
% diameter (1x1)    - diameter of the cursor.
% lineThickness (1x1)   - line thickness of the cursor.
% rgbColor (1x3)    - RGB color of the cursor in the range [0,1].
%
% 3/21/2013  npc Wrote it.
%
    if nargin < 4
        error('Usage: addMonocularCursor(diameter,  lineWidth, rgbColor, [cursorOpts])');
    end

    parser = inputParser;
    parser.addRequired('Diameter', @(x)isscalar(x) && x > 0);
    parser.addRequired('LineThickness', @(x)isscalar(x) && x > 0);
    parser.addRequired('Color');
    parser.addParamValue('Enabled', true, @islogical);
    parser.addParamValue('Name', 'cursor3DObject', @ischar);
    parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

    % Execute the parser to make sure input is good.
    parser.parse(diameter, lineThickness, rgbColor, varargin{:});

    obj = parser.Results;

    % Assign a numerical object type ID for easy type checking later.
    obj.ObjectType = GLWindow.ObjectTypes.MonocularCursor2D;

    % Validate the passed RGB value(s).
    obj.Color = GLW_ValidateRGBColor(obj.Color, GLWObj.DisplayTypeID);

    % Modify the auto gamma if it's enabled.  The function does nothing if it's not.
    obj = GLWObj.addAutoGammaColor(obj);

    % Add the object to the render queue.
    GLWObj.addObjectToQueue(obj);
end
