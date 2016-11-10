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

%% Make diagnostic plots?
PLOTS = false;

%% Since we're going to assume that the target is at 0,0, check this
if (targetC ~= 0 | targetM ~= 0)
    error('We baked in that the target is at 0,0, but it is not');
end

%% We assume that sigma is 1, check for this too
if (sigma ~= 1)
    error('Code assumes that sigma is 1');
end

%% Prevent pathological values of w
if (w == 0)
    w = 0.0001;
elseif (w == 1)
    w = 0.9999;
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
rangeValue = 6;
nSampleValues = 1000;
minLength1 = max([0 meanLength1-rangeValue]);
lengthsSquared1 = linspace(minLength1^2,(meanLength1+rangeValue)^2,nSampleValues);
deltaValues1 = lengthsSquared1(2)-lengthsSquared1(1);

% Now get probability for each possible value of the first length
probForEachValueOf1 = ncx2pdf(lengthsSquared1,2,delta1)*deltaValues1;
totalProb1 = sum(probForEachValueOf1);
if (PLOTS)
    plotFigure1 = figure; clf; hold on;
    plot(lengthsSquared1,probForEachValueOf1,'r','LineWidth',2);
    xlabel('Distance1')
    ylabel('Probability');
end
if (abs(totalProb1 - 1) > 1e-2)
    error('Total probability that length1 has a length is not close enough to 1');
end

%% Compute expected value of length1 and adjust w1
expectedLengthsSquared1 = sum(probForEachValueOf1.*lengthsSquared1);
expectedA1Squared = expectedLengthsSquared1 - 1;
expectedAdjustedLengthsSquared1 = w^2*expectedA1Squared + (1-w)^2*1;
adjustedW = sqrt(expectedAdjustedLengthsSquared1 / expectedLengthsSquared1);
fprintf('Adjusted w %0.3f, w %0.3f\n',adjustedW,w);

%% Compute expected value of length2 and adjust w2
delta2 = cy2^2 + my2^2;
meanLength2 = sqrt(delta2);
minLength2 = max([0 meanLength2-rangeValue]);
lengthsSquared2 = linspace(minLength2^2,(meanLength2+rangeValue)^2,nSampleValues);
deltaValues2 = lengthsSquared2(2)-lengthsSquared2(1);
probForEachValueOf2 = ncx2pdf(lengthsSquared2,2,delta2)*deltaValues2;
totalProb2 = sum(probForEachValueOf2);
if (PLOTS)
    plotFigure2 = figure; clf; hold on
    plot(lengthsSquared2,probForEachValueOf2,'r','LineWidth',2);
    xlabel('Distance2')
    ylabel('Probability');  
end
if (abs(totalProb2 - 1) > 1e-2)
    error('Total probability that length2 has a length is not close enough to 1');
end
expectedLengthsSquared2 = sum(probForEachValueOf2.*lengthsSquared2);
expectedA2Squared = expectedLengthsSquared2 - 1;
expectedAdjustedLengthsSquared2 = (1-w)^2*expectedA2Squared + w^2*1;
adjustedOneMinusW = sqrt(expectedAdjustedLengthsSquared2 / expectedLengthsSquared2);
fprintf('Adjusted (1-w) %0.3f, (1-w) %0.3f\n\n',adjustedOneMinusW,1-w);

% Now for each value that the first length might take on, compute the
% probability that the second length is longer.  For this we use
% the cdf of the ncx2 distribution.
p1LessThan2ForEachValueOf1 = 1 - ncx2cdf((adjustedW/adjustedOneMinusW)^2*lengthsSquared1,2,delta2);
if (PLOTS)
    plotFigure3 = figure; clf; hold on
    plot(lengthsSquared1,p1LessThan2ForEachValueOf1,'r','LineWidth',2);
    xlabel('Distance1')
    ylabel('Probability 1 Less Than 2');
end

% Get expected value to get the returned p
p = sum(probForEachValueOf1 .* p1LessThan2ForEachValueOf1);

% Deal with edge cases
if (p == 0)
    p = 0.0001;
elseif (p == 1)
    p = 0.9999;
end
end
