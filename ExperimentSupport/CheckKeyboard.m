function [gotTR, gotTaskCode, key] = CheckKeyboard(trCode, taskCode)
% [gotTR, gotTaskCode] = CheckKeyboard(trCode, taskCode)
%   Checks to see if we've received a TR or task input. trCode and taskCode
%   are ASCII numerical values.  Sets 'key' to whatever value(s) was
%   received, empty if nothing in the queue.

global g_timeTracker;

% Initialize the return variables.
gotTR = false;
gotTaskCode = false;

% Check to see if any characters are available in the queue.  Record when we
% got the task code or the tr.
[avail, numChars] = CharAvail;
key = [];
if avail
	for i = 1:numChars
		[c, w] = GetChar(1, 1);
		key(end+1) = c; %#ok<AGROW>
		switch c
			case trCode
				gotTR = true;
				g_timeTracker = addTimeStamp(g_timeTracker, 'tr', w.secs);
			case taskCode
				gotTaskCode = true;
				g_timeTracker = addTimeStamp(g_timeTracker, 'task', w.secs);
		end
	end
end
