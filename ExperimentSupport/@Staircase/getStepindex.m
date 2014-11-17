function stepindex = getStepindex(obj)
% stepindex = getStepindex(obj)
%
% Description: Returns the current step index.  If
%   on a finished staircase, returns the step index for
%   the last trial.
%
% You probably do not want to call this routine.  Brendan
% thought it did something else when he wrote it.  See
% getTrialStepIndices.
%
% I put in an error trap to make sure that code that uses this
% routine gets looked at.
%
% Required Input:
%   obj - Staircase object.
%
% Output:
%   stepindex - The stepindex
%
% 10/29/09  bjh  Wrote it.
% 02/08/11  dhb  Fixed commend so that it describes what is actually done.
%           dhb  Only works for staircase type.

error('I don''t think you ever want to call this.');
switch obj.StaircaseType
	case 'standard'
        stepindex = obj.Stepindex;
	case 'quest'
        stepindex = [];
end


