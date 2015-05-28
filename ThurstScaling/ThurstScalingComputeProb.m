function p = ThurstScalingComputeProb(y1,y2,sigma)
% function p = ThurstScalingComputeProb(y1,y2,sigma)
%
% Computes the probability of the first stimulus being chosen to have
% "more X" where X is whatever is being scaled.
%
%   Inputs: 
%       y1 - inferred position of the first element in the pair
%       y2 - inferred position of the second element in the pair
%       sigma - fixed standard deviation of a stimulus normal distributions
%   Output: 
%       p - probability of first competitor in the pair being chosen given the
%           inferred positions. 
% 
% 4/28/15  dhb  Wrote it from MLDS version.

% Compute stimulus difference
diff = y1-y2;

% Response is 1 if diff is positive.  This is 1-normcdf of
% -diff, with sigma multipled by sqrt(2) to take into account 
% of the fact that we are looking at the distribution of the
% differences.
p = 1-normcdf(0,diff,sqrt(2)*sigma);
if (p == 0)
    p = 0.0001;
elseif (p == 1)
    p = 0.9999;
end

end
