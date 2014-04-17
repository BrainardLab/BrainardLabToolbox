function [posteriorProb] = BayesMvnNormalPosteriorProb(x,y,T,ux,Kx,un,Kn)
% [posteriorProb] = BayesMvnNormalPosteriorPorb(x,y,T,ux,Kx,un,Kn)
%
% Computes the posterior probability p(x|y) for the MvnNormal model.  This is analytic.
% Input x can be a matrix of column vectors, each of which repesents a
% point on which the posterior is evaluated.
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
% 10/23/06  dhb  Wrote it.

Kx_post = BayesMvnNormalPosteriorCov(T,ux,Kx,un,Kn);
ux_post = BayesMvnNormalPosteriorMean(y,T,ux,Kx,un,Kn,Kx_post);
posteriorProb = mvnpdf(x',ux_post',Kx_post);

