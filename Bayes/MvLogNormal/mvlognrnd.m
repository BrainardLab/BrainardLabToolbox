function y = mvlognrnd( u_x , K_x , ndraws )
% y = mvlognrnd( u_x , K_x , ndraws )
%
% u_x: The mean of the underlying normal distribution (column vector)
% K_x: The covariance matrix of the underlying normal distribution
% ndraws:  The number of draws to generate.
%
% Requires the statistics toolbox.
%
% Original author: Stephen Lienhard
% 
% 12/23/07  dhb  Got this off the web and changed many things about it.

% Error checking
if nargin < 2
    error('Must have at least 2 input arguments')
end
if (nargin < 3 | isempty(ndraws))
    ndraws = 1;
end

if numel(ndraws) ~= 1 || ndraws < 0
    error('The number of draws to generate must be greater then zero and a scalar')
end

if (numel(u_x) ~= size(K_x,1) | length(u_x) ~= size(K_x,2))
    error('Dimensions of u_x and K_x must be consistent')
end

% Get the draws
y = exp( mvnrnd( u_x , K_x , ndraws ));