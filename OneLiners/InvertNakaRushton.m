function x = InvertNakaRushton(params,y)
% x = InvertNakaRushton(params,y)
%
% Invert the Naka-Rushton function.  The forward function is as in ComputeNakaRushton.
% This routine does not invert the most general case implemented in the forward routine.
%
% Currently only the two/three parameter versions are implemented.  The
% forward function is:
%
% length(params) == 2
%   sigma = params(1)
%   n = params(2)
%   y = [x^n]/[x^n + sigma^n]
%
% length(params) == 3
%   Rmax = params(1)
%   sigma = params(2)
%   n = params(3)
%   y = Rmax*[x^n]/[x^n + sigma^n]
%
% This leads to the inverse:
%  (y/Rmax)*[x^n + sigma^n] = x^n
%  (1-(y/Rmax))*x^n = (y/Rmax)*sigma^n
%  x = [(y/Rmax)*sigma^n/(1-(y/Rmax))]^(1/n)
%
% 12/4/10  dhb  Wrote it.
% 1/25/11  dhb  Improve error message for out of range y.  Bound in general is Rmax.


if (length(params) == 2)
    A = 1;
    sigma = params(1);
    exponent = params(2);
    exponent1 = params(2);  
elseif (length(params) == 3)
    A = params(1);
    sigma = params(2);
    exponent = params(3);
    exponent1 = params(3);
else
    error('Inproper format for passed parameter vector');
end

if (any(y < 0) || any(y > A))
    error('Input y must be in range [0-Rmax]');
end

if (sigma < 0 || exponent <= 0 || exponent1 <= 0)
    error('Bad parameter value passed');
end

x = ((y/A).*(sigma^exponent)./(1-(y/A))).^(1/exponent);