function [likelihood] = BayesMvnPoissLikelihood(y,x,T,d)
% [likelihood] = BayesMvnPoissLikelihood(y,x,T,un,Kn)
%
% Computes the likelihood p(y|x) for the model where
% the mean datum given x is y_mean = T*x and the noise
% is independent Poisson for each y, with parameter T*x+d. 
%
% Input x may be a matrix of column vectors, on which the
% likelihood is evaluated.
%
% d should be a column vector of the same dimension as y, and
% should contain the "dark" noise corresponding to each y.
%
% 10/23/06  dhb  Wrote it.

uy = T*x;
n = size(x,2);
likelihood = poisspdf(y(:,ones(1,n),T*x+d(:,ones(1,n));
