function addText(GLWObj, textToDisplay, varargin)
% addText - Adds text to the GLWindow object.
%
% Syntax:
% obj.addText(textToDisplay)
% obj.addText(textToDisplay, textOpts)
%
% Input:
% textToDisplay (string) - Text to display in the GLWindow.
% textOpts (key/value list) - Variable list of key/value pairs.  The
%     following options are supported:
%     Center (1x2) - The (x,y) location of the center of the text.
%     Color (1x3) - The RGB color of the text.
%     FontSize (scalar) - Font size.
%     Name (string) - Object identifier name.
%     Enabled (logical) - Enables/disables the text object.
%
% Example:
% win = GLWindow;
% win.addText('Hello World', 'Color', [1 0 0], 'Name', 'myText');
% win.open;
% win.draw;

error(nargchk(2, 12, nargin));

if nargin < 2
	error('Usage: addText(textToDisplay, [textOpts])');
end

parser = inputParser;
parser.addRequired('Text', @(x)ischar(x) || uint16(x));
parser.addParamValue('Center', [0 0], @(x)isvector(x) && length(x) == 2);
parser.addParamValue('CharactersPerLine', 40, @(x)isscalar(x) && x > 0);
parser.addParamValue('Color', [1 1 1], @(x)isvector(x) && length(x) == 3);
parser.addParamValue('Enabled', true, @islogical);
parser.addParamValue('Name', 'textObject', @ischar);
parser.addParamValue('FontSize', 100, @isscalar);
parser.addParamValue('FontName','Helvetica',@isstr);

% Execute the parser to make sure input is good.
parser.parse(textToDisplay, varargin{:});

obj = parser.Results;
obj.ObjectType = GLWindow.ObjectTypes.Text;
obj.RenderMethod = GLWindow.RenderMethods.Texture;

% Make is so that letters are wide enough such that obj.charactersperline
% characters can fit in the width of the scene.
obj.LetterWidth = GLWObj.SceneDimensions(1) / obj.CharactersPerLine;

% Make sure the Color property is in the right format given the display
% type.
switch GLWObj.DisplayTypeID
	case {GLWindow.DisplayTypes.Stereo, GLWindow.DisplayTypes.StereoBitsPP, GLWindow.DisplayTypes.HDR}
		obj.Color = [obj.Color ; obj.Color];
end

GLWObj.addObjectToQueue(obj);
