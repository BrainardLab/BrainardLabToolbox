function deriv = DerivativeNakaRushton(params,contrast)
% [response] =  DerivativeNakaRushton(params,contrast)
%
% Compute the derivatimve of the Naka-Rushton function on passed vector of contrasts.
% Several different forms may be computed depending on length of
% passed params vector.  See ComputeNakaRushton.
%
% In the general form, where the response is given by:
%   response = Rmax*[contrast^n]/[contrast^m + sigma^m]
% the derivative is given by (http://www.derivative-calculator.net):
%   Rmax*n*x^(n-1)/(x^m + s^n) - Rmax*m*x^(n+m-1)/(x^m+x^n)^2
%
% This routine is not heavily tested.
% 
% 9/21/13  dhb  Wrote it.

% Extract parameter vector into meaningful variables
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
elseif (length(params) == 4)
    A = params(1);
    sigma = params(2);
    exponent = params(3);
    exponent1 = params(4);
else
    error('Inproper format for passed parameter vector');
end

% Check for bad contrast input
if (any(contrast < 0))
    error('Cannot deal with negative contrast');
end

% Handle really weird parameter values
if (sigma < 0 || exponent < 0 || exponent1 < 0)
    error('Cannot handle passed parameter values');
else
    deriv1 = (A*exponent*contrast.^(exponent-1))./(contrast.^exponent1 + sigma.^exponent);
    deriv2 = (A*exponent1*contrast.^(exponent + exponent1 - 1))./((contrast.^exponent1 + sigma.^exponent).^2);
    deriv = deriv1 - deriv2;
end

end