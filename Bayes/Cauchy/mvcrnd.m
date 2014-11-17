function r = mvcrnd(mu,K,N,method)
% r = mvcrnd(mu,K,N,method)
% 
% Generate N draws from the specified multivariate Cauchy distribution.
% Each draw ends up as one row of r.
%
% mu should be passed as a row vector.
%
% Based on fact that the Cauchy is just
% the t distribution with 1 df.
%
% 8/11/11  dhb, gt  Wrote it.

if (nargin < 4 || isempty(method))
    method = 'normandchi2';
end

switch (method)
    case 'mvt'
        
        scaleMat = diag(1./sqrt(diag(K)));
        unscaleMat = diag(sqrt(diag(K)));
        C = scaleMat*K*scaleMat';
        r = mvtrnd(C,1,N);
        r = (unscaleMat*r')' + repmat(mu,N,1);
    case 'normandchi2'
        chi = chi2rnd(1,N,1);
        for i = 1:N
            r(i,:) = mvnrnd(mu,K/chi(i));
        end
        
    otherwise
        error('Unknown method specified');
end

