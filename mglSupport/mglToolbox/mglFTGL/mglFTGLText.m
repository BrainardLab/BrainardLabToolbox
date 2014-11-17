function mglFTGLText(subCommand, varargin)

if nargin < 1
	error('Usage: mglFTGLText(subCommand, [subCommandArgs])');
end

if ~ischar(subCommand)
	error('"subCommand" must be a string.');
end

switch lower(subCommand)
	case 'rendertext'
		commandCode = 1;
		
		if nargin ~= 2
			error('Usage: mglFTGLText(''RenderText'', textString');
		end
		
		% Get the text string.
		textString = varargin{1};
		if ~ischar(textString)
			error('"textString" must be a string.');
		end
			
		mglPrivateFTGLText(commandCode, textString);
		
	case 'initialize'
		commandCode = 2;
		
		mglPrivateFTGLText(commandCode);
		
	case 'setfontsize'
		commandCode = 3;
		
		if nargin ~= 2
			error('Usage: mglFTGLText(''SetFontSize'', fontSize)');
		end
		
		% Get the font size and validate it.
		fontSize = varargin{1};
		if ~isscalar(fontSize)
			error('"fontSize" must be a scalar value');
		elseif fontSize < 1
			error('"fontSize" must be greater than or equal to 1.');
		end
		
		% Force font size to be an integer.
		fontSize = round(fontSize);
		
		mglPrivateFTGLText(commandCode, fontSize);
		
	otherwise
		error('Unknown command "%s"', subCommand);
end
