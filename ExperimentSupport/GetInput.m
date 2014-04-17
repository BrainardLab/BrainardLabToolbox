function data = GetInput(inputString, inputType, inputDims)
% data = GetInput(inputString, [inputType], [inputDims])
% 
% Description:
% Gets user input from the command line.
%
% Required Input:
% inputString (string) - The query that will be shown to the users.
%	Example: 'Enter your selection'.
% 
% Optional Inputs:
% inputType (string) - Can be either 'number' or 'string'.  Defaults to
%	'number'.
% inputDims (integer vector) - For an inputType of 'string', this represents the
%	limits on the size of the input string.  Defaults to [1,256].  For
%	'number', this represents the number of elements in the inputted vector.
%	Defaults to 1.  This value can also be -1, which implies that any input
%	is accepted.
%
% Output:
% data (string|vector) - The inputted string or vector.
%
% Example:
% data = GetInput('Please Insert a Number', 'number', 2);
% Please Insert a Number: <user input goes here>

if nargin < 1 || nargin > 3
    error('Usage: data = GetInput(inputString, inputType, inputDims)');
end

% Setup some defaults.
if nargin == 1
    inputType = 'number';
    inputDims = 1;
end

% Make sure inputType is valid.
if ~any(strcmp(inputType, {'number', 'string'}))
    error('*** Invalid inputType, must choose ''number'' or ''string''');
end

% Make sure the input dimensions are valid
switch inputType
    case 'number'
		if ~exist('inputDims', 'var')
			inputDims = 1;
		end
		
        % Make sure inputDims is a single scalar.
        if ~isscalar(inputDims)
            error('*** Invalid inputDims, must be a single scalar for type ''number''');
        end
        
    case 'string'
        % Setup the default string length if it wasn't specified.
        if nargin < 3
            inputDims = [1, 256];
        else
            % Make sure inputDims is a 1x2 matrix.
            if ~all(size(inputDims) == 1:2)
                error('*** Invalid inputDims, must be of form [x,y] for type ''string''');
            end
        end
end

% Grab the data from the user.  Loop until the data is valid.
inputString = [inputString, ': '];
keepLooping = true;
while keepLooping
    if strcmp(inputType, 'number')
        data = str2num(input(inputString, 's')); %#ok<ST2NM>
		
		% inputDims of -1 implies we'll take anyingthing as input.
		if inputDims == -1
			keepLooping = false;
		else
			if numel(data) == inputDims
				keepLooping = false;
			else
				beep;
				fprintf('*** Invalid entry, must be a vector of length %d.\n', inputDims);
			end
		end
    else
        data = input(inputString, 's');
        
        lenData = length(data);
        if lenData >= inputDims(1) && lenData <= inputDims(2)
            keepLooping = false;
        else
            beep;
            fprintf('*** Invalid entry, must be a string >= %d and <= %d in length\n', inputDims(1), inputDims(2));
        end
    end
end


