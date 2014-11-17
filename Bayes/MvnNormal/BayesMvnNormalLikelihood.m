function [likelihood] = BayesMvnNormalLikelihood(y,x,T,un,Kn)
% [likelihood] = BayesMvnNormalLikelihood(y,x,T,un,Kn)
%
% Computes the likelihood p(y|x) for the model where
% the mean datum given x is y_mean = T*x and the noise
% is Normal ~ N(un,Kn).
%
% Input x may be a matrix of column vectors, on which the likelihood is
% evaluated.
%
% 10/23/06  dhb  Wrote it.

uy = T*x;
n = size(x,2);
likelihood = mvnpdf((y(:,ones(1,n))-uy)',un',Kn);
