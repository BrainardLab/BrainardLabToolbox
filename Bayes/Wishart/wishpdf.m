function p = wishpdf(W,V,n)
% p = wishpdf(W,V,n) 
%
% Wishart pdf.  Evaluates probability of W given Wishart parameters V and n.
%
% Formulae from Wikipedia entry for Wishart distribution.  Actual computation
% is done in the log domain, here we just exponentiate.
%
% A small check.  The Wishart reduces to the chi2 if you pass scalars for
% x and set V = 1.  We tried one case and matched what Matlab's chi2pdf returns:
%   >> chi2pdf(1.7,6)
%   ans =
%       7.7202e-02
%   >> wishpdf(1.7,1,6)
%   ans =
%       7.7202e-02
%
% The Wishart is also a generalization of the gamma distribution (not the gamma function),
% and if we could figure out exactly what the relation between the parameters is, we
% could test that too.
%
% 9/15/10  dhb, jrm   Wrote it.

p = exp(wishpdfln(W,V,n));
