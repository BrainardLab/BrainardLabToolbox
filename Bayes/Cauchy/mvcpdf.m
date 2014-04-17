function y = mvcpdf(x,mu,K)
% y = mvcpdf(x,mu,K)
% 
% Compute the multivariate Cauchy pdf
%
% Based on fact that the Cauchy is just
% the t distribution with 1 df.
%
% 8/11/11  dhb, gt  Wrote it.
% 8/18/11  dhb, gt  Fixed scaling.

%y = (1/sigma)*tpdf((x-mu)/sigma,1);

scaleMat = diag(1./sqrt(diag(K)));
xTrans = (x - mu)*scaleMat;
C = scaleMat'*K*scaleMat;
y = det(scaleMat)*mvtpdf(xTrans,C,1);