function trExists = CheckForTR(trCode)
% CheckForTR(trCode)
%   Checks to see if a TR has occurred.  trCode is the ASCII code of the
%   character to look for.

trExists = false;

t0 = GetSecs;

% Check to see if a character is available in the queue.
if CharAvail
    [c, w] = GetChar(0, 1);
    if c == trCode
        trExists = true;
    end
end
