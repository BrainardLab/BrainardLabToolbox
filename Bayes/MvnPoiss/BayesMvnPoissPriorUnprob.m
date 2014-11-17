function [unnormalizedPriorProb] = BayesMvnPoissPriorUnprob(x,ux,Kx)
% [unnormalizedPriorProb] = BayesMvnPoissPriorUnprob(x,ux,Kx)
%
% Computes the unnormalize prior p(x), specified as a truncated
% N(ux,Kx) for the MvnPoiss model.  The truncation is for x < 0.
%
% Input x may be a matrix of column vectors, on which the prior is
% evaluated.
%
% 10/28/06  dhb  Wrote it.

unnormalizedPriorProb = BayesMvnNormalPriorProb(x,ux,Kx);
index = any(find(x < 0),1);
if (~isempty(index))
    unnormalizedPriorProb(index) = 0;
end


