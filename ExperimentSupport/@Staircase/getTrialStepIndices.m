function trialStepIndices = getTrialStepIndices(obj)
% trialStepIndices = getTrialStepIndices(obj)
%
% Description: Returns the step size indices for
%   trials run so far.
%
% This will only work for data collected after the tracking of information
% was added to the staircase class, Feb 08, 2011.
%
% Required Input:
%   obj - Staircase object.
%
% Output:
%   trialStepIndices - The stepindex vector
%
% 02/08/11  dhb  Wrote it

error('This function does not work with the old version of the staircase class');
switch obj.StaircaseType
	case 'standard'
        trialStepIndices = obj.TrialStepIndices;
	case 'quest'
        trialStepIndices = [];
end

