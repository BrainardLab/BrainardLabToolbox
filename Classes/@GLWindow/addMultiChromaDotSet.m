function addMultiChromaDotSet(GLWObj, dotPositions, rgbColor, dotSize, varargin)
% addMultiChromaDotSet - Adds a set of dots, each with its own color, to the GLWindow.
%
% Syntax:
% obj.addDotSet(dotPositions, rgbColor, dotSize, [dotSetOpts])
%
% Input:
% dotPositions (Mx2|Mx3)            - List of the (x,y) or (x,y,z) centers of each dot.Each row of the matrix is an individual dot's position.
% rgbColor (1x3|struct|cell array)  - RGB color for each dot within the set.
% dotSize (scalar)                  - Size of each dot in pixels.  All dots will be the same size.
%
% 12/16/2012  npc  Wrote it.
%
    if nargin < 4
        error('Usage: addDotSet(center, rgbColor, dotSize, [dotSetOpts])');
    end

    parser = inputParser;
    parser.addRequired('DotPositions');
    parser.addRequired('Color');
    parser.addRequired('DotSize', @isscalar);

    parser.addParamValue('Rotation', [0 0 0 1]);
    parser.addParamValue('Enabled', true, @islogical);
    parser.addParamValue('Name', 'dotSetObject', @ischar);
    parser.addParamValue('RenderMethod', GLWindow.RenderMethods.Normal, @isscalar);

    % Execute the parser to make sure input is good.
    parser.parse(dotPositions, rgbColor, dotSize, varargin{:});
    obj = parser.Results;

    % Assign a numerical object type ID for easy type checking later.
    obj.ObjectType = GLWindow.ObjectTypes.MultiChromaDotSet;

    % Validate the dot positions parameter.
    if ndims(dotPositions) ~= 2 || ~any(size(dotPositions, 2) == [2 3])
        error('"dotPositions" must be a Mx2 or Mx3 matrix.');
    end

    disp('In addMultiChromaDotSet we need to call GLW_ValidateRGBColor for all colors. Also check cases for different display types');
    % Validate the colors parameter.
    %obj.Color = GLW_ValidateRGBColor(obj.Color, GLWObj.DisplayTypeID);

    % % Expand single color specifications to the number of dots.
    % for i = 1:length(obj.Color)
    % 	if size(obj.Color{i}, 1) == 1
    % 		obj.Color{i} = repmat(obj.Color{i}, size(dotPositions, 1), 1);
    % 	end
    % end
    % 
    % % Make sure we have the same number of colors as dots.  If only one color
    % % is specified for all the dots that's OK, too.
    % for i = 1:length(obj.Color)
    % 	if size(dotPositions, 1) ~= size(obj.Color{i}, 1)
    % 		error('"rgbColor" must have the same number of rows as "dotPositions" or be a 1x3.');
    % 	end
    % end

    % Validate the rotation parameter.
    obj.Rotation = GLW_ValidateRotation(obj.Rotation, GLWObj.DisplayTypeID);

    % Validate the dot size parameter.
    if ~isscalar(obj.DotSize) || obj.DotSize <= 0
        error('"dotSize" must be a scalar >= 1.');
    end

    % Modify the auto gamma if it's enabled.  The function does nothing if it's
    % not.
    obj = GLWObj.addAutoGammaColor(obj);

    % TODO - Make sure the render method was legit.

    % Add the object to the render queue.
    GLWObj.addObjectToQueue(obj);

end

