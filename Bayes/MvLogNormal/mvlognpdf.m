function pdf = mvlognpdf(x,u_x,K_x)
% pdf = mvlognpdf(x,u_x,K_x)

% Calculate log normal multivariate pdf.  This expects
% its parameters in terms of the underlying normal
% distribution, which makes it very simple.  This
% matches Matlab's convention for the univariate
% log normal.
%
% The calling convention matches that of Matlab's mvnpdf,
% with the exception that we have not implemented the
% possibility of a different mean vector or covariance
% matrix for each row of passed vector x.
%
% See mvlognmeancovtonorm to convert from parameters
% in the log normal representation to the form this
% routine requires.
%
% The formula was taken from notes by Ghasem Tarmast, which
% we found on the web and also matches our reading of the R
% implementation by Peter Reichert.

% 12/12/07  lyj  Created it.
% 12/23/07  dhb  Changed usuage, simplify by moving the work into mvlognmeancovtonorm.

% Calculate the probability density.
n = size(x,2);
pdf = zeros(size(x,1),1);
for i = 1:size(x,1)
    if min(x(i,:)) <= 0
        pdf(i) = 0;
    else
        pdf(i) = (2*pi)^(-n/2)*((det(K_x))^(-.5))*(prod(x(i,:))^(-1))*exp(-0.5*(log(x(i,:))-u_x)*inv(K_x)*(log(x(i,:))-u_x)');
    end
end
