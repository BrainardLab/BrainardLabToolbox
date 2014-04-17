function reversals = getReversals(obj)
% reversals = getReversals(obj)
%
% Description: Returns the reversals for
%   trials run so far.
%
% Required Input:
%   obj - Staircase object.
%
% Output:
%   reversals - Vector of reversals
%
% 10/29/09  bjh  Wrote it.

switch obj.StaircaseType
	case 'standard'
        
	case 'quest'
end

if (obj.NextTrial == 1)
    reversals = [];
else
    reversals = obj.Reversals(1:obj.NextTrial-1);
end
