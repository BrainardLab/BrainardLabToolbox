function [values,responses] = getTrials(obj)
% [values,responses] = getTrials(obj)
%
% Description: Returns the values and responses for
%   trials run so far.
%
% Required Input:
%   obj - Staircase object.
%
% Output:
%   values - Vector of values
%   responses - Vector of responses
%
% 10/19/09  dhb  Wrote it.

switch obj.StaircaseType
	case 'standard'
        
	case 'quest'
end

if (obj.NextTrial == 1)
    values = [];
    responses = [];
else
    values = obj.Values(1:obj.NextTrial-1);
    responses = obj.Responses(1:obj.NextTrial-1);
end
