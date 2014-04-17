function p = cauchycdf(x,mu,sigma)
% p = cauchycdf(x,mu,sigma)
%
% Compute the univariate Cauchy cdf
%
% Based on fact that the Cauchy is just
% the t distribution with 1 df.
%
% 8/11/11  dhb, gt  Wrote it.  

p = tcdf((x-mu)/sigma,1);
