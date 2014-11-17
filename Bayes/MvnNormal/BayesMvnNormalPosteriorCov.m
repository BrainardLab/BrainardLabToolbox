function [posteriorK] = BayesMvnNormalPosteriorCov(T,ux,Kx,un,Kn)
% [posteriorK] = BayesMvnNormalPosteriorCov(T,ux,Kx,un,Kn) 
%
% Computes the posterior covariance for the MvnNormal model.  This is analytic.
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

posteriorK = inv((inv(Kx)+T'*inv(Kn)*T));

