function [x] = BayesMvnPoissPriorDraw(nDraws,ux,Kx)
% [x] = BayesMvnNormalPriorDraw(nDraws,ux,Kx)
%
% Draw from prior.
%
% 10/28/06  dhb  Wrote it.

x = BayesMvnNormalPriorDraw(nDraws,ux,Kx);

