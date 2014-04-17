function stepSizes = getStepSizes(obj)
% stepSizes = getStepSizes(obj)
%
% Description: Get the vector of step sizes used in a staircase.
%
% Required Input:
%   obj - Staircase object.
%
% Output:
%   stepSizes - Vector of step sizes.
%
% 02/08/11  dhb  Wrote it

switch obj.StaircaseType
	case 'standard'
        stepSizes = obj.StepSizes;
	case 'quest'
        stepSizes = [];
end


