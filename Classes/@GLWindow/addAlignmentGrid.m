function addAlignmentGrid(GLWObj, nodePositions, rgbColor, varargin)
% addAlignmentGrid - Adds an alignment grid. 
% Used to verify alignment of left and right screens in the stereo display.
%
% Syntax:
% obj.addAlignmentGrid(nodePositions, rgbColor, [rectOpts])
%
% Input:
% nodePositions (MxNx2) - Matrix of (x,y) centers of nodes of a grid with M rows and N cols.
% rgbColor (1x3)        - RGB color of the cursor in the range [0,1].
%
% 3/27/2013  npc Wrote it.
%
    if nargin < 2
        error('Usage: addAlignmentGrid(nodePositions, rgbColor, [gridOpts])');
    end

    parser = inputParser;
    parser.addRequired('NodePositions');
    parser.addRequired('Color');
    parser.addParamValue('LineWidth', 2, @isscalar);
    parser.addParamValue('Enabled', true, @islogical);
    parser.addParamValue('Name', 'alignmentGridObject', @ischar);
    parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

    % Execute the parser to make sure input is good.
    parser.parse(nodePositions, rgbColor, varargin{:});
    obj = parser.Results;

    % Assign a numerical object type ID for easy type checking later.
    obj.ObjectType = GLWindow.ObjectTypes.AlignmentGrid;

    % Validate the passed RGB value(s).
    obj.Color = GLW_ValidateRGBColor(obj.Color, GLWObj.DisplayTypeID);

    % Modify the auto gamma if it's enabled.  The function does nothing if it's not.
    obj = GLWObj.addAutoGammaColor(obj);

    % Add the object to the render queue.
    GLWObj.addObjectToQueue(obj);
end



