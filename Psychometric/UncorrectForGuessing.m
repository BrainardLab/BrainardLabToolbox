function [pHit] = UncorrectForGuessing(pCorrected,pFA,pLapse)
% Invert correct for guessing and lapses
%
% Synopsis:
%   [pHit] = CorrectForGuessing(pCorrected,pFA,[pLapse])
%
% Description:
%    Invert standard high-threshold correction for guessing formula.
%
%    False alarm rate is corrected to 0, and anything less
%    than that also is forced to 0, since negative doesn't
%    make sense.
%
% Inputs:
%    pCorrected -   Vector of hit rates corrected for guessing.
%    pFA -          False alarm rate to use in the correction
%    pLapse -       Lapse rate (optional, default 0)
%
% Outputs:
%   pHit -          Vector. The corresponding uncorrected pHit

% History:
%   12/23/21 dhb    Pulled out into its very own function. 
%                   Added avoidance of negative return values.
%   04/18/26 dhb    Add lapse rate option

if (nargin < 3 | isempty(pLapse))
    pLapse = 0;
end

% Standard correct for guessing formula.
pHit = pCorrected*(1-pFA-pLapse) + pFA;

% Make sure pCorrected is in bounds
pHit(pHit <= 0) = 0;
pHit(pHit >= 1) = 1;

end