function WaitForTR(params, emulateTR)
% WaitForTR(params, emulateTR)
% Waits for a TR in an endless loop.  If emulateTR is set to true, then the
% loop ends after TRduration + TRslop.
%
% params is a struct that must contain the following fields:
% TRduration        -- Length of a single TR.
% TRslop            -- Time slop for a given TR.
% trCode            -- Numerical code value for a TR.

baseTime = GetSecs;
keepLooping = true;

while keepLooping
    % Check to see if we've gotten the TR.  Otherwise, show the fixation
    % point.
    if CheckForTR(params.trCode)
        break;
    end
    
    if emulateTR
        keepLooping = (GetSecs - baseTime) < (params.TRduration + params.TRslop);
    end
end