function [keyPressed, detectionTime] = waitForKeyPress(waitDuration)
% keyPressed = waitForKeyPress([waitDuration])
%
% Description:
% Waits for a keypress and returns when one is detected.
%
% Optional Input:
% waitDuration (double) - Time to wait for a key press.  If not specified,
%	the function will wait forever.
%
% Ouput:
% keyPressed (char) - The key pressed.  [] if no key was pressed.
% detectionTime (double) - The time we detected the keyboard input.  This
%	time comes from the internal hardware clock via mglGetSecs.  [] if no
%	keys were detected.

persistent p_keyMap;

if isempty(p_keyMap)
	p_keyMap = KeyMaster.getKeyMap;
end

if nargin > 1
	error('Usage: keyPressed = waitForKeyPress([waitDuration])');
end

if nargin == 0
	waitDuration = Inf;
end

t0 = tic;
keyPressed = [];
detectionTime = [];
while toc(t0) < waitDuration
	k = mglGetKeys;
	if any(k)
		detectionTime = mglGetSecs;
		k = p_keyMap(k);
		
		% Just record the 1st key we see.
		keyPressed = k{1};
		break;
	end
end
