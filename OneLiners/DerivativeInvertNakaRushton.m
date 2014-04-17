function deriv = DerivativeInvertNakaRushton(params,response)
% [deriv] =  DerivativeInvertNakaRushton(params,response)
%
% Compute the derivatimve of the inverse Naka-Rushton function on passed vector of contrasts.
% Several different forms may be computed depending on length of
% passed params vector.  See ComputeNakaRushton.
%
% In the case where the response is given by:
%   contrast = [(response/Rmax)*sigma^n/(1-(response/Rmax))]^(1/n)
% the derivative may be obtained at (http://www.derivative-calculator.net
% and is messy enough that I'm not writing it out here.
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

% Check for bad response input
if (any(response < 0))
    error('Cannot deal with negative response');
end

% Handle really weird parameter values
if (sigma < 0 || exponent < 0 || exponent1 < 0)
    error('Cannot handle passed parameter values');
else
    factor1 = A*(1-response./A);
    factor2 = (((sigma^exponent).*response)./factor1).^(1/exponent);
    factor3 = (sigma^exponent)./factor1 + ((sigma^exponent).*response)./((A^2)*((1-response./A).^2));
    denom = exponent*(sigma^exponent)*response;
    
    deriv = factor1.*factor2.*factor3./denom;
end

end