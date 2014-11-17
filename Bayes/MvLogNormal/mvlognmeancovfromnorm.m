function [u_y,K_y,corr_y,corr_x] = mvlognmeanvcovfromnorm(u_x,K_x)
% [u_y,K_y,corr_y] = mvlognmeanvarfromnorm(u_x,K_x)
%
% Compute actual mean and variance of a multivariate log normal
% distribution (y) from the mean and covariance matrix of the
% underlying normal distribution (x).
%
% Formula from notes by Ghassem Tarmast that we found on the
% web.  Might be clever to find an archival source for these.
% Same formulae are in a separate set of notes, and it looks
% like a book by Johnson and Kotz would have these written 
% down in a form that could be referenced.
%
% 12/19/07  dhb, lyj  Wrote it.
% 12/23/07  dhb       Changed variable names.
%           dhb       Return input and output correlation matrices

% Translate mean
u_y = exp(u_x+0.5*diag(K_x)');

% Translate covariance matrix
for i = 1:length(u_x)
    for j = 1:length(u_x)
        K_y(i,j) = exp( (u_x(i)+u_x(j)) + (K_x(i,i) + K_x(j,j))/2) .* (exp(K_x(i,j))-1);
    end
end

% Return correlation matrices if asked for.
if (nargout > 2)
    for i = 1:length(u_x)
        for j = 1:length(u_y)
            corr_x(i,j) = K_x(i,j)/sqrt(K_x(i,i)*K_x(j,j));
            corr_y(i,j) = K_y(i,j)/sqrt(K_y(i,i)*K_y(j,j));
        end
    end
end