function [unnormalizePosteriorProb] = BayesMvnNormalPoissPosteriorUnprob(x,y,T,ux,Kx,d)
% [unnormalizePosteriorProb] = BayesMvnPoissPosteriorUnprob(x,y,T,ux,Kx,d)
%
% Computes the posterior probability p(x|y) for the MvnPoiss model.
%
% 10/23/06  dhb  Wrote it.

prior = BayesMvnPoissPriorProb(T,ux,Kx);
likelihood = BayesMvnPoissLikelihood(y,x,T,d);
unnormalizePosteriorProb = likelihood .* prior;