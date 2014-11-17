function [x] = BayesMvnNormalPriorDraw(nDraws,ux,Kx)
% [x] = BayesMvnNormalPriorDraw(nDraws,ux,Kx)
%
% Draw from prior.
%
% 10/23/06  dhb  Wrote it.

x = mvnrnd(ux,Kx,nDraws)';
