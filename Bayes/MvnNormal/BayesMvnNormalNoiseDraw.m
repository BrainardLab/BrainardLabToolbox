function [n] = BayesMvnNormalNoiseDraw(nDraws,un,Kn)
% [n] = BayesMvnNormalNoiseDraw(nDraws,un,Kn)
%
% Draw from noise.
%
% 10/23/06  dhb  Wrote it.

n = mvnrnd(un,Kn,nDraws)';
