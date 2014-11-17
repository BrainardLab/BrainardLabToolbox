function [posteriorMean,I,i0] = BayesMvnNormalPosteriorMean(y,T,ux,Kx,un,Kn,Kx_post)
% [posteriorMean,I,i0]] = BayesMvnNormalPosteriorMean(y,T,ux,Kx,un,Kn,[Kx_post]) 
%
% Computes the posterior mean for the MvnNormal model.  This is analytic.
% Formulae from the appendix of:
%
%   Brainard, D. H. (1995), An ideal observer for appearance:
%   reconstruction from samples", UCSB Vision Labs Report 95-1, available at
%   http://color.psych.upenn.edu/brainard/papers/bayessampling.pdf.
%
% Almost surely these formulae are available somewhere in the statistics
% literature as well.
%
% Input y may be a matrix with data in each column.
%
% For this model, it turns out that posteriorMean = I*y+i0, and this
% routine also returns I and i0.
%
% If Kx_post has already been computed, it may be passed to save time.
%
% 10/23/06  dhb  Wrote it.
% 10/28/06  dhb  Express as I*y+i0, return I and i0 too.
% 12/30/06  dhb  Allow passing of y = [], in which case posteriorMean is returned as [].

% If posterior covariance is passed, don't need to computer it again.
if (nargin < 7 | isempty(Kx_post))
    Kx_post = BayesMvnNormalPosteriorCov(T,ux,Kx,un,Kn);
end 
n = size(y,2);
I = Kx_post*T'*inv(Kn);
i0 = Kx_post*inv(Kx)*ux - I*un;
if (~isempty(y))
    posteriorMean = I*y + i0(:,ones(1,n));
else
    posteriorMean = [];
end
