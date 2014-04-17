function y = cauchypdf(x,mu,sigma)
% y = cauchypdf(x,mu,sigma)
% 
% Compute the univariate Cauchy pdf
%
% Based on fact that the Cauchy is just
% the t distribution with 1 df.
%
% 8/11/11  dhb, gt  Wrote it.

y = (1/sigma)*tpdf((x-mu)/sigma,1);
if (y <= 0)
    mu
    sigma
end


