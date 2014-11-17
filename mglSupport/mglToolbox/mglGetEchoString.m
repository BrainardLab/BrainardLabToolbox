function response = mglGetEchoString(GLWObj, promptString, textCenter, textRGB, fontSize)
% response = mglGetEchoString(GLWObj, promptString, [textCenter], [textRGB], [fontSize])
%
% Description:
% Renders a prompt and interactively shows keyboard input.  Hitting enter
%   terminates input and returns the response.
%
% Input:
% GLWObj (GLWindow) - The GLWindow object.
% promptString (string) - The prompt to display on the screen.
%
% Optional Input:
% textCenter (1x2) - (x,y) coordinates of the center of the text on the
%   display.  Default: [0 0]
% textRGB (1x3) - RGB color of the text.  Default: [1 1 1]
% fontSize (scalar) - Size of the font.  Default: 100
%
% Output:
% response (string) - String containing the inputted text.

if nargin < 2 || nargin > 5
	error(help('mglGetEchoString'));
end

% Setup some defaults.
if ~exist('textCenter', 'var') || isempty(textCenter)
	textCenter = [0 0];
end
if ~exist('textRGB', 'var') || isempty(textRGB)
	textRGB = [1 1 1];
end
if ~exist('fontSize', 'var') || isempty(fontSize)
	fontSize = 100;
end

% Flush the mgl keyboard queue.
mglGetKeyEvent;

% We'll create a random name for the text we're going to add to the screen.
% The text object will be deleted at the end of the function.  We choose a
% random name so we don't overwrite anyone's predefined text object that
% might have the same name.
textName = GenerateRandomString(20);

% The response starts of as empty.
response = '';

% Add the text object and show the prompt.
GLWObj.addText(promptString, 'Name', textName, 'Center', textCenter', ...
	'Color', textRGB, 'FontSize', fontSize);
GLWObj.draw;

% Loop until enter is pressed.
while true
	% Get a keypress.
	key = mglGetKeyEvent(Inf);
	
	switch key.keyCode
		% Enter pressed
		case 37
			break;
			
		% Backspace pressed
		case 52
			if ~isempty(response)
				response = response(1:end-1);
			end
			
		% All other keys
		otherwise
			response = [response, key.charCode]; %#ok<AGROW>
	end
	
	GLWObj.setText(textName, [promptString response]);
	GLWObj.draw;
end

% Delete the text object.
GLWObj.deleteObject(textName);
