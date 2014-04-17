function [a,b] = betaparamsfrommeanvar(u,s2)
% [a,b] = betaparamsfrommeanvar(u,s2)
%
% Compute the parameters [a,b] of the beta distribution
% that correspond to the passed mean (u) and variance (s2).
%
% The formula came from:
%   http://linkage.rockefeller.edu/pawe3d/help/Beta-distribution.html.
% That page in turn references:
%   Evans, M., Hastings, N. and Peacock, B. (2000)
%   Statistical Distributions. 3rd ed. J. Wiley and Sons, Inc.,
%   New York.
% 
% The computed result is checked by using Matlab's betastat to make
% sure the computed a and b produce the desired answer.  If that
% routine returns NaNs, then a and b are set to NaN on return.  [I think
% this corresponds to either a or b being less than zero.]  This case
% indicates that the needed parameters do not produce a valid beta
% distribution, and that the desired u and s2 are not attainable for
% a beta.
%
% 7/25/09  dhb  Wrote it.

% Basic calculation
u2 = u.^2; u3 = u.^3;
a = (u2 - u3 - u*s2)/s2;
b = (u - 2*u2 + u3 - s2 + u*s2)/s2;

% Check against Matlab's inverse calculation
[ucheck,s2check] = betastat(a,b);
if (isnan(ucheck) | isnan(s2check))
    a = NaN;
    b = NaN;
end
if (abs(ucheck-u) > 1e-7)
    fprintf('Failure for u %0.2g, ucheck = %0.2g\n',u,ucheck);
end
if (abs(s2check-s2) > 1e-7)
    fprintf('Failure for s2 %0.2g, s2check = %0.2g\n',s2,s2check);
end