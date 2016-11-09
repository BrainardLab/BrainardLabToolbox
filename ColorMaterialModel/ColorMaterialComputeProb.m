function p = ColorMaterialComputeProb(targetC,targetM, cy1,cy2,my1, my2, sigma, w)
% function p = ColorMaterialComputeProb(targetC,targetM, cy1,cy2,my1, my2, sigma, w)
%
% Computes the probability of the first competitor being chosen given the  
% inferred position of the target and the two competitors in the pair. 
%
%   Inputs: 
%       x  - inferred target position . 
%       y1 - inferred position of the first element in the pair
%       y2 - inferred position of the second element in the pair
%       sigma - fixed standard deviation of a cummulative normal distribution
%       mapFunction - function that determins the mapping from x to y domain. 
%                     it can be used to model the effect of context. 
%                     we typically use the identity function. 
%   Output: 
%       p - probability of first competitor in the pair being chosen given the
%           inferred target position.  

%% Since we're going to assume that the target is at 0,0, check this
if (targetC ~= 0 | targetM ~= 0)
    error('We baked in that the target is at 0,0, but it is not');
end

%% We assume that sigma is 1, check for this too
if (sigma ~= 1)
    error('Code assumes that sigma is 1');
end

%% We want to know the probability of a 1 response.  
%
% This happens if the first distance is less than the second distance.
%
% The way we find the probability is to take the expected value that the
% first distance is less than the second distance, with the expectation
% taken across values of the first distance.
%
% We can get the probability distribution of the first distance by using
% the pdf of the non-central chi2 distribution.  We count on the fact that
% the target is sitting at (0,0).  We assume that the variability of the
% comparisons has unit variance in both c and m.
%
% Compute delta parameter of non-central chi-squared.  See wikipedia
% article on non-central chi-squared, where delta is called lambda.
% Also take square root to get mean length.
delta1 = cy1^2 + my1^2;
meanLength1 = sqrt(delta1);

% Given the assumption about unit variance, the mean length, almost all the
% probability mass for distance1 is going to be between meanLength +/- n,
% where n is 3 or 4 or something like that (given sigma == 1).
% We use this fact to compute a set of discrete values for the first
% length.
rangeValue = 4;
nSampleValues1 = 100;
minLength1 = max([0 meanLength1-rangeValue]);
lengths1 = linspace(minLength1,meanLength1+rangeValue,nSampleValues1);
deltaValues1 = lengths1(2)-lengths1(1);

% Now get probability for each possible value of the first length
probForEachValueOf1 = ncx2pdf(lengths1,2,delta1)*deltaValues1;

% Now for each value that the first length might take on, compute the
% probability that the second length is longer.  For this we use
% the cdf of the ncx2 distribution.
delta2 = cy2^2 + my2^2;
p1LessThan2ForEachValueOf1 = 1 - ncx2cdf(lengths1,2,delta2);

% Get expected value to get the returned p
p = sum(probForEachValueOf1 .* p1LessThan2ForEachValueOf1);

% Deal with edge cases
if (p == 0)
    p = 0.0001;
elseif (p == 1)
    p = 0.9999;
end
end
