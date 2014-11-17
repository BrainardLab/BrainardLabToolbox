function mvy = mvgammaln(x,p)
% mvy = mvgammaln(x,p)
%
% Return the log of the multivariate gamma function with deg. of freedom p.
%
% Formula source, Wikipedia entry on the Multivariate gamma function
%
% 9/15/10  dhb, jrm  Wrote it on the way to a working Wishart pdf.
% 5/19/11  dhb, jrm  Added some sanity checks

if (p < 1)
    error('Very bad things happen if you call this function with p < 1');
end
if (round(p) ~= p)
    error('Very bad things happen if you call this function with non-integer p');
end

% Use the recursive formula provided on wikipedia
if (p == 1)
    mvy = gammaln(x);
else
    mvy = ((p-1)/2)*log(pi) + gammaln(x) + mvgammaln(x-0.5,p-1);
end

end

