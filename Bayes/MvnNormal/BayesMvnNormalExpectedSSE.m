function [expectedSSE] = BayesMvnNormalExpectedSSE(T,ux,Kx,un,Kn,M,Kx_post)
% [expectedSSE] = BayesMvnNormalExpectedSSE(T,ux,Kx,un,Kn,[M],[Kx_post])
%
% Computes the expected SSE from estimating as the posterior mean for
% the MvnNormal model.  This is analytic.
%
% Formulae from the appendix of:
%
%   Brainard, D. H. (1995), An ideal observer for appearance:
%   reconstruction from samples", UCSB Vision Labs Report 95-1, available at
%   http://color.psych.upenn.edu/brainard/papers/bayessampling.pdf.
%
% Almost surely these formulae are available somewhere in the statistics
% literature as well.
%
% If M is passed, expected error is computed for a linear transformation of
% the the x space, M*x.
%
% It is allowable to pass Kx_post, which saves time if it was already
% computed elsewhere.
%
% 10/23/06  dhb  Wrote it.
% 10/28/06  dhb  Optional passing of M, Kx_post.

if (nargin < 7 | isempty(Kx_post))
    Kx_post = BayesMvnNormalPosteriorCov(T,ux,Kx,un,Kn);
end

if (nargin < 6 | isempty(M))
    expectedSSE = trace(Kx_post);
else
    expectedSSE = trace(M*Kx_post*M');
end
