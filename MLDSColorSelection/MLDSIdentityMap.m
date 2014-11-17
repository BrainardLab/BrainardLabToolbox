function yOfX = MLDSIdentityMap(x)
% function yOfX = MLDSIdentityMap(x)
%
% Identity mapping from one context to another. 
% Assumes no context effect on x when it is presented in one conext vs another.
% This is mainly for development/debugging using simulated data.  Real data determine their own
% actual mapping.
%
%   Input:     x - value of x in context 1
%   Output: yOfx - value of x in context 2
% 
% 5/03/12  dhb  Capture predicted probabilities and pass them along.
% 6/13/13  ar   Added comments. 

yOfX = x;
    
end