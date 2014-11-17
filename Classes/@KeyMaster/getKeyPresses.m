function [keyPresses, detectionTime] = getKeyPresses
% [keyPresses, detectionTime] = getKeyPresses
%
% Description:
% Gets the latest set of active keys, i.e. all the keys pressed on the
% keyboard at the same time.
%
% Output:
% keyPresses (1xN cell) - The current keys pressed.  Each key is its own
%	element in the cell array.
% detectionTime (double) - The time we detected the keyboard input.  This
%	time comes from the internal hardware clock via mglGetSecs.  [] if no
%	keys were detected.

persistent p_keyMap;

if isempty(p_keyMap)
	p_keyMap = KeyMaster.getKeyMap;
end

keyPresses = [];
detectionTime = [];

k = mglGetKeys;
t = mglGetSecs;

if any(k)
	detectionTime = t;
	keyPresses = p_keyMap(k);
end
