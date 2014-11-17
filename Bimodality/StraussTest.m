% BIMODAL: Calculates a coefficient of bimodality (original here, not in
%          lnBootature to my knowledge), based on an inverse kurtosis, by column.
%          The index is centered on zero, the asymptotic value for a uniform
%          distribution (no modes).  Positive values are increasingly bimodal;
%          negative values are increasingly unimodal.  Index ranges from
%          negative to positive infinity.
%
%     Syntax: [coeff,pr,ci,power] = bimodal(X,nBoot,alpha)
%
%          X =     [n x p] data matrix.
%          nBoot =  number of nBootations for significance and confidence levels.
%          alpha = expected probability of Type I error.
%          --------------------------------------------------------------------
%          coeff = [1 x p] vector of bimodality coefficients.
%          pr =    [1 x p] vector of randomized significance levels, based on a
%                    null uniform distribution.
%          ci =    [2 x p] matrix of randomized confidence intervals:
%                    row 1 - lower critical values
%                        2 - upper critical values
%          power = [1 x p] vector of power levels.
%

% RE Strauss, 10/21/97

function [coeff,pr] = StraussTest(X,nBoot,alpha)
if (nargin < 2) nBoot = []; end;
if (nargin < 3) alpha = []; end;

if (isempty(nBoot))
    nBoot = 0;
end;
if (isempty(alpha))
    alpha = 0.05;
end;

coeff = bimodalf(X);

if (nBoot > 0)
    if (nargout < 4)
        bootCoeff = bootstrp(nBoot,@bimodalf,sort(unifrnd(0,1,1,length(X))));
    else
        bootCoeff = bootstrp(nBoot,@bimodalf,sort(unifrnd(0,1,1,length(X))));
    end;
end;

pr = sum(coeff < bootCoeff)/nBoot;

% BIMODALF: Objective function for BIMODAL.  Coefficient is centered on zero,
%           the value for a uniform distribution.  Positive values are
%           increasingly bimodal, negative values are increasingly unimodal.
%

% RE Strauss, 10/21/97
function b = bimodalf(X,grps,initsoln,nulldist,nullflag)
[n,p] = size(X);

if (nargin < 4)
    nulldist = 0;
end;

if (nulldist)                     % Random-uniform sample
    X = rand(n,1)*ones(1,p);          % Identical sample for all variables
end;

kurt = kurtosis(X);               % Kurtosis, by column
b = log(1.8./kurt);               % Bimodality coeff, by column
%  bias = 0.0294-(0.4051./sqrt(n));  % Bias correction
%  b = b - bias;

return;


