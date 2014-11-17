function atSmallestStep = getAtSmallestStep(obj)
% atSmallestStep = getAtSmallestStep(obj)
%
% Description: Get vector that indicates whether a trial was
%   run at the smallest step size.
%
% Required Input:
%   obj - Staircase object.
%
% Output:
%   atSmallestStep - the indicator vector.
%
% 02/08/11  dhb  Wrote it

switch obj.StaircaseType
	case 'standard'
        atSmallestStep = obj.AtSmallestStep;
	case 'quest'
        atSmallestStep = [];
end

