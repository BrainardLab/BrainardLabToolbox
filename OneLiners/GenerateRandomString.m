function randString = GenerateRandomString(stringLength)
% randString = GenerateRandomString(stringLength)
%
% Description:
% Creates a random alpha string of abritrary length.
%
% Input:
% stringLength (integer) - Length of the random string.  Must be > 0.
%
% Output:
% randString (string) - The randomly generated string.

if nargin ~= 1
	error(help('GenerateRandomString'));
end

if stringLength <= 0
	error('stringLength must be > 0');
end

ClockRandSeed;

% Numerical codes for letters a-z and A-Z.
alphaSet = ['a':'z', 'A':'Z'];
alphaSetSize = length(alphaSet);

randString = alphaSet(randi(alphaSetSize, [1 stringLength]));
