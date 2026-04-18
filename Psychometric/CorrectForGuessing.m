function [pCorrected] = CorrectForGuessing(pHit,pFA,pLapse)
% Correct for guessing and lapses
%
% Synopsis:
%   [pCorrected] = CorrectForGuessing(pHit,pFA,[pLapse])
%
% Description:
%    Apply standard high-threshold correction for guessing formula.
%
%    False alarm rate is corrected to 0, and anything less
%    than that also is forced to 0, since negative doesn't
%    make sense.
%
% Inputs:
%    pHit -         Vector of hit rates.
%    pFA -          False alarm rate to use in the correction
%    pLapse -       Lapse rate (optional, default 0)
%
% Outputs:
%   pCorrected -    Vector. pHit corrected for guessing & lapses.]

%{
% Examples:
    % Correcting 1-lapse should yield 1.
    pCorrected = CorrectForGuessing(0.9,0,0.1)
    pCorrected = CorrectForGuessing(0.9,0.2,0.1)

    % Correcting guess should yield 0
    pCorrected = CorrectForGuessing(0.1,0.1)
    pCorrected = CorrectForGuessing(0.1,0.1,0.2)

%}

% History:
%   12/23/21 dhb    Pulled out into its very own function. 
%                   Added avoidance of negative return values.
%   04/18/26 dhb    Add lapse rate option

if (nargin < 3 | isempty(pLapse))
    pLapse = 0;
end

% Avoid the weird world of negative proportion correct.
pHit(pHit < pFA) = pFA;

% Standard correct for guessing formula.
pCorrected = (pHit-pFA)/(1-pFA-pLapse);

% Make sure pCorrected is in bounds
pCorrected(pCorrected <= 0) = 0;
pCorrected(pCorrected >= 1) = 1;

% See if we can invert properly
pCorrected = CorrectForGuessing(0.72,0.05,0.01);
pHit = UncorrectForGuessing(pCorrected,0.05,0.01)

end