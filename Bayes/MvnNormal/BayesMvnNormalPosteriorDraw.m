function [xDraw] = BayesMvnNormalPosteriorDraw(nDraws,y,T,ux,Kx,un,Kn)
% [xDraw] = BayesMvnNormalPosteriorDraw(nDraws,y,T,ux,Kx,un,Kn)
%
% Computes the posterior probability p(x|y) for the MvnNormal model.  This is analytic.
% Then returns draws from the posterior.
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
% 12/18/08  dhb  Wrote it.

Kx_post = BayesMvnNormalPosteriorCov(T,ux,Kx,un,Kn);
ux_post = BayesMvnNormalPosteriorMean(y,T,ux,Kx,un,Kn,Kx_post);
xDraw = mvnrnd(ux_post,Kx_post,nDraws)';

