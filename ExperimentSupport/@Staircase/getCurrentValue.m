function value = getCurrentValue(obj)
% value = getCurrentValue(obj)
%
% Description: Returns the current recommended staircase value.
%
% Required Input:
%   obj - Staircase object from which to calculate 'value'.
%
% Output:
%   value - The recommended value for the next trial.
%
% Note that the calling program can override the recommendation and run something else.
% This is handled because the update routine takes the actually used value.
%
% 10/19/09  dhb  Work in linear coords for the outside world, covert to log here.
%           dhb  MaxValue and MinValue enforced.
% 10/21/09  dhb  Add staircase code.

switch obj.StaircaseType
	case 'standard'
        value = obj.NextValue;
        
	case 'quest'
		value = 10.^QuestQuantile(obj.QuestObj);
end

% Enforce MaxValue, MinValue
if (value > obj.MaxValue)
    value = obj.MaxValue;
end
if (value < obj.MinValue)
    value = obj.MinValue;
end
