function [u_x,K_x,var_x] = mvlognmeanvcovtonorm(u_y,K_y)
% [u_x,K_x,var_x] = mvlognmeanvcovtonorm(u_y,K_y)
%
% Compute the mean and covariance matrix of the
% underlying normal distribution (x) from actual mean
% and variance of a multivariate log normal distribution (y) from .
%
% Formula extracted from R code by Peter Reichert, that we
% found on the web.
%
% See also mvlognmeancovfromnorm, mvlogntest
%
% 12/23/07  dhb       Pulled out from other places.

% Mean of normal from mean and varaiance of lognormal.
u_x = 2*log(u_y) - 0.5*log(diag(K_y)' + u_y.^2);

% Variance of normal from mean and varaiance of lognormal
var_x = -2*log(u_y) + log(diag(K_y)' + u_y.^2);

% Get correlation matrix from covariance and then use this
% to produce the desired covariance for the normal.  This
% follows the R code we found.  We haven't sat down and
% figured out why this works, but it does generate the
% right answer for the variances, and it does invert 
% properly.  See mvnlogntest.
for i = 1:length(u_y)
    for j = 1:length(u_y)
        corr(i,j) = K_y(i,j)/sqrt((K_y(i,i)*K_y(j,j)));
    end
end
sdlog = log(1 + diag(K_y)' ./ (u_y.^2) );
K_x = log(1 + diag(sqrt(exp(sdlog)-1))*corr*diag(sqrt(exp(sdlog)-1)));

% Check that direct computation of variance matches the weird 
% computation above.
if any(abs(diag(K_x)'-var_x) > 1e-7)
    error('Mismatch between two ways of computing variances');
end

return