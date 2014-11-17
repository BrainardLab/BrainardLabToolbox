function lp = wishpdfln(W,V,n)
% lp = wishpdfln(W,V,n) 
%
% ln of Wishart pdf.  Evaluates ln probability of W given Wishart parameters V and n.
%
% Formulae from Wikipedia entry for Wishart distribution.
%
% 9/15/10  dhb, jrm   Wrote it.
% 5/19/11  dhb, jrm   Checks on mvgammaln return val.

% Check on conditions
p = size(V,1);
if (n <= p-1)
    fprintf('Degrees of freedom %d too small for dimension of passed matrix %d\n',n,p);
    error;
end

% Get some quantities we'll need
detW = det(W);
if (detW < 0)
    error('Passed matrix W is not positive semidefinite');
end
detV = det(V);
if (detV < 0)
    error('Passed Wishart parameter V is not positive semidefinite');
end
if (detW == 0 || detV == 0)
    lp = -1000;
    return;
end

invV = inv(V);
np_1_over2 = (n-p-1)/2;
np_over2 = n*p/2;
n_over2 = n/2;

% Evaluate multivariate gamma function
lnmvgamma = mvgammaln(n_over2,p);
if (lnmvgamma == Inf)
    lnmvgamma = 1000;
elseif (lnmvgamma == -Inf)
    lnmvgamma = -1000;
elseif (isnan(lnmvgamma))
    lnmvgamma = 1000;
end
    

% Compute log of exponential term
lnExpTerm = -0.5*trace(invV*W);

% Get logs of the various other constatns
a = np_1_over2*log(detW);
b = np_over2*log(2);
c = n_over2*log(detV);

% Sum up for the answer
lp = a - b - c - lnmvgamma + lnExpTerm;