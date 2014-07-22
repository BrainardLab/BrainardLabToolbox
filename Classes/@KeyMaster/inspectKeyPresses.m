function keysFound = inspectKeyPresses(keysOfInterest, keysPressed)
% keysFound = inspectKeyPresses(keysOfInterest, keysPressed)
%
% Description:
% Can be used to see if any of the "keysOfInterest" were found in the
% results of KeyMaster.getKeyPresses.
%
% Input:
% keysOfInterest (char | 1xN cell) - A single character or a cell array of
%	characters that are to be looked for.
% keysPressed (1xN cell) - Cell array of single characters, such as the
%	return value from KeyMaster.getKeyPresses.
%
% Output:
% keysFound (logical) - True if any of the keys were found, false
%	otherwise.

if nargin ~= 2
	error('Usage: keysFound = inspectKeyPresses(keysOfInterest, keysPressed)');
end

% If just a single character was passed as a key of interest, convert it
% into a cell array prior to sending it off to the analysis loop.
if ischar(keysOfInterest)
	keysOfInterest = {keysOfInterest};
end

keysFound = false;

for i = 1:length(keysOfInterest)
	if any(strcmp(keysOfInterest{i}, keysPressed))
		keysFound = true;
		break;
	end
end
