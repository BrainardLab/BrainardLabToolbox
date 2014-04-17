function response = Prompt(question, defaultValue, requireAnswer)
% Prompt(question, defaultValue, requireAnswer)
%	Prompts the user for input.
%
%	'question' is a string containing the message you want to prompt the
%	user with.
%
%	'defaultValue' is a default value that will be returned should the user
%	just hit enter.  If this is empty, no default value will be available.
%
%	'requireAnswer' if set to true will force the user to input something
%	at the prompt.  If 'defaultValue' is set, this argument does nothing.
%	By default, 'requireAnswer' is false.

if nargin < 1 || nargin > 3
	error('Usage: response = Prompt(question, [defaultValue], [requireAnswer])');
end

switch nargin
	case 1
		defaultValue = [];
		requireAnswer = true;
	case 2
		if isempty(defaultValue)
			defaultValue = [];
		end
		requireAnswer = false;
	case 3
		if isempty(defaultValue)
			defaultValue = [];
		end
end

% Setup the query string.
if isempty(defaultValue)
	query = sprintf('%s: ', question);
else
	query = sprintf('%s: [%s] ', question, defaultValue);
end

keepAsking = true;
while keepAsking
	% Get the user input.
	response = input(query, 's');

	% If we require an answer, no default value was specified, and no user
	% input, then request input again.
	if requireAnswer && isempty(defaultValue) && isempty(response)
		disp('*** Input required');
	else
		% If nothing was inputted, use the default value.
		if isempty(response)
			response = defaultValue;
		end
		
		% Break out the loop.
		keepAsking = false;
	end
end
