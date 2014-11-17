function [priorProb] = BayesMvnNormalPriorProb(x,ux,Kx)
% [priorProb] = BayesMvnNormalPriorProb(x,ux,Kx)
%
% Computes the prior p(x), specified as N(ux,Kx) for the
% MvnNormal model.
%
% Input x may be a matrix of column vectors, on which the prior is
% evaluated.
%
% 10/23/06  dhb  Wrote it.

priorProb = mvnpdf(x',ux',Kx);
