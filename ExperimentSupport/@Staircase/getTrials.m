function [values,responses] = getTrials(obj,nTrialsDiscard)
% [values,responses] = getTrials(obj,[nTrialsDiscard])
%
% Description: Returns the values and responses for
%   trials run so far.
%
% Required Input:
%   obj - Staircase object.
%   nTrialsDiscard (default 0)
%
% If nTrialsDiscard is set to an integer, the first nTrialsDiscard of the
% staircase are not returned.
%
% Output:
%   values - Vector of values
%   responses - Vector of responses
%
% Empty matrices are returned if there were not enough trials.
%
% 10/19/09  dhb  Wrote it.
% 09/1916   dhb  Add nTrialsDiscard argument.

if (nargin < 2 | isempty(nTrialsDiscard))
    nTrialsDiscard = 0;
end

switch obj.StaircaseType
	case 'standard'
        
	case 'quest'
end

if (obj.NextTrial-1 <= nTrialsDiscard)
    values = [];
    responses = [];
else
    values = obj.Values((nTrialsDiscard+1):obj.NextTrial-1);
    responses = obj.Responses((nTrialsDiscard+1):obj.NextTrial-1);
end
