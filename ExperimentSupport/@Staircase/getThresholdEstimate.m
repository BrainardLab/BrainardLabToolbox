function value = getThresholdEstimate(obj)
% value = getThresholdEstimate(obj)
%
% Description: Returns the current threshold estimate.
%
% Required Input:
%   obj - Staircase object from which to calculate 'value'.
%
% Output:
%   value - The current threshold estimate.
%
% 10/19/09  dhb  Return value in linear rather than log terms
% 10/21/09  dhb  Standard staircase code.

switch obj.StaircaseType
	case 'standard'
        % This is pretty quick and dirty.  But we should never use this estimate
        % for real.  We should always post fit the entire set of measurements.
		reversals = find(obj.AtSmallestStep == 1 & obj.Reversals == 1);
        value = mean(obj.Values(reversals));
        if (isnan(value))
            reversals = find(obj.Reversals == 1);
            value = mean(reversals);
            value = mean(obj.Values(reversals));
        end
        if (isnan(value))
            value = mean(obj.Values);
        end
	case 'quest'
        % Quest's estimate.  Again, this should not be used but rather
        % the entire staircase should be post fit.
		value = 10.^QuestMean(obj.QuestObj);
end
