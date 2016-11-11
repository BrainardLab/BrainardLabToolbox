function p = ColorMaterialModelComputeProb(targetC,targetM, cy1,cy2,my1, my2, sigma, w)
% function p = ColorMaterialModelComputeProb(targetC,targetM, cy1,cy2,my1, my2, sigma, w)
%
% This function is part of our modeling effort for our initial
% color-material tradeoff experiments.  On each trial of these experiments,
% there is a single target stimulus and two competitors (y1 and y2).  The
% first competitor differs from the target in color while the second
% differs in terms of material.  The subject indicates which competitor is
% closer to the target.
%
% Our model assumes that there is a two-dimensional representational space,
% with color on one axis and material on the other.  We make this
% assumption because our stimulus manipulations of color and material lie
% along a single line in the higher-dimensional color and material
% perceptual spaces.  We assume that there is trial-by-trial noise in the
% position of both competitors in the space.  For simplicity, we assume
% that the target position is fixed at the origin. (We think this is
% without loss of generality, although we should probably check it more
% closely.)  We then assume that the subject picks y1 if on that trial the
% distance between y1 and the target is less than the distance between y2
% and the target.
%
% The job of this function is to compute the probility that the subject
% picks y1, that is, the probability that y1 is closer to the target when
% we aggregate over trials with the same stimulus triad.  The routine takes
% the positions of the target, y1, and y2 in the perceptual space, as well
% as the noise standard deviation for each dimension and a weight value w
% that determines how distances are scaled along the color and material
% axes of the perceptual space.
%
% Despite the fact that it takes a number of variables, the routine is
% based on some assumptions and approximations.  These could be relaxed if
% we computed the probability through forward simulation, but our goal here
% is to provide a reasonable analytic approximation that applies to our
% current experiments.
%  1) Target position is always 0,0.
%  2) The mean of the y1 representaitonal distribution lies on the color axis
%     and the mean of the y2 representaitonal distribution lies on the material axis.
%  3) The value of sigma is the same for both axes and is 1.
%  4) 0 < w < 1
%
% Assumptions 1, 3, and 4 are, we think, without loss of generality.  The
% size of sigma scales each axis and this scale needs to be locked somehow
% because the data don't really change under an affine scaling of either
% axis.  Similarly with locking the origin using the target.
%
% We can't quite get an analytic solution for exactly what we want, but
% this routine comes reasonably close.  The problem is that we rely on the
% non-central chi-squared distribution to determine the relevant
% probabilities, and this forces us to have w act on distances rather than
% on the underlying dimensions.  With the fact that y1 and y2 each lie
% close to the axis on each trial, perturbed away from it only by the
% noise, this isn't a bad assumption and we can do a first order correction
% for the expected deviation of the representation from each axis.
%
% Note that 'analytic' here does involve some numerical intergration. But
% it does not involve forward simulation and the answer we return is
% deterministic.  A deterministic value is important for numerical search,
% which will call this routine as part of its objective function.
%
%   Inputs: 
%       targetC  - target position on color dimension (fixed to 0).
%       targetM  - target position on material dimension (fixed to 0). 
%      
%       cy1 - inferred position on the color dimension for the first competitor in the pair
%       my1 - inferred position on the material dimension for the first competitor in the pair
%       cy2 - inferred position on the color dimension for the second competitor in the pair
%       my2 - inferred position on the material dimension for the second competitor in the pair
%       sigma - noise around the target position (we assume it is equal to 1 and the same
%               for both color and material dimenesions).  
%       w - weight for color dimension.   
%          
%   Output: 
%       p - probability of first competitor in the pair being chosen given the
%           target position and inferred position of the second competitor.  

%% Make diagnostic plots?
%
% Make this true to get some plots that might be useful for debugging (and
% that were in fact useful when we first wrote this routine.)
PLOTS = false;

%% Check that passed args meet assumptions
%
% We pass them all because some day we might generalize, but here we 
% check that they're good.

% We assume that the target is at 0,0, check
if (targetC ~= 0 || targetM ~= 0)
    error('We baked in that the target is at 0,0, but it is not');
end

% We assume that sigma is 1, check
if (sigma ~= 1)
    error('Code assumes that sigma is 1');
end

% We assume that my1 is 0 and cy2 is 0, check
if (my1 ~= 0 | cy2 ~= 0)
    error('Assumption that competitors lie on the axes is violated.');
end

% Check w and also avoid numerical problems for very small w or (1-w)
if (w < 0 | w > 1)
    error('w must be between 0 and 1 inclusive');
end
if (w == 0)
    w = 0.0001;
elseif (w == 1)
    w = 0.9999;
end

%% Compute distribution of lengths (over trials) of competitor y1 
%
% We can get the probability distribution of the first distance by using
% the pdf of the non-central chi2 distribution.  We count on the fact that
% the target is sitting at (0,0).  We assume that the variability of the
% comparisons has unit variance in both c and m.
%
% Step 1: Compute delta parameter of non-central chi-squared.  See wikipedia
% article on non-central chi-squared, where delta is called lambda.  This
% parameter is needed so that the non-central chi-squared returns the
% appropriate values for (cy1,my1).
% Also take square root to get mean length.
delta1 = cy1^2 + my1^2;

% We'll also need the length of the mean of the distribution of y1 in the
% perceptual space.
meanLength1 = sqrt(delta1);

% Step 2: We want the probability distribution for the length of noisy draws
% of y1 in the stimulus space. Given the assumption we make that sigma is 1 for both axes,
% and the fact my1 = 0, the distribution of lengths of y1 is going to bet
% between meanLength +/- n, where n is 3 or 4 or something like that
% (because sigma == 1) and not too much gets perturbed because the noise
% along the material direction isn't going to screw things up too much.
% We use this fact to compute a set of discrete values for the length of y1 that covers
% the range of values that will occur.

% Turns out empirically that 6 is a good range, and we'll compute the pdf
% over nSamplesValues within that range, to get a good approximation.
% Lengths cannot be negative.  It is convenient to work in length^2,
% because that's what the non-central chi-squared describes the probability
% of.
%
% Note that the length of y1 is the same as the distance between y1
% and the target, because we force the target to be at the origin.  Its
% possible that the code would be clearer if we had called everything
% distance, rather than length.
rangeValue = 6;
nSampleValues = 1000;
minLength1 = max([0 meanLength1-rangeValue]);
lengthsSquared1 = linspace(minLength1^2,(meanLength1+rangeValue)^2,nSampleValues);
deltaValues1 = lengthsSquared1(2)-lengthsSquared1(1);

% Now get probability for each interval over the sampled lengths for y1,
% using the non-central chi-squared.  Make sure the probability sums to 1.
probForEachValueOf1 = ncx2pdf(lengthsSquared1,2,delta1)*deltaValues1;
totalProb1 = sum(probForEachValueOf1);
if (PLOTS)
    % Show sampled PDF, optionally.
    plotFigure1 = figure; clf; hold on;
    plot(lengthsSquared1,probForEachValueOf1,'r','LineWidth',2);
    xlabel('Length of y1')
    ylabel('Probability');
end
if (abs(totalProb1 - 1) > 1e-2)
    error('Total probability that length1 has a length is not close enough to 1');
end

%% Compute expected value of length1 and adjust w
%
% We want to compare the distance to y1 and y2 in a weighted fashion.
% Ideally, we would compute each distance by weighting the color axis by w
% and the material axis by (1-w).  But we can't calculate that, because the
% non-central chi-squared requires that we take the compute the sum of
% squares of independent normal random variables each with sigma = 1.
%
% So, we do a trick.  First note that in the limit that sigma -> 0, the
% length of y1 depends only on the color axis position and the length of y2
% only on the material axis position.  In this case, we could weight the
% length of y1 by w and the length of y2 by (1-w) and compare those
% lengths.  Doing that in fact (we checked) gives an excellend contribution
% for cases where cy1 >> 1 and my2 >> 1.  But when cy1 gets smaller (say, <
% 20 or so based on some simulations we did) or my2 gets similarly small,
% the trial by trial variation that takes the perceptual representations
% off the axes intrudes on the approxmation more than we would like.
%
% So, here's what we do.  First, we find the expected length of y1.  Then,
% we note that the expected value of the length of the material component
% of y1 is 1 and thus its expected squared length is also 1.  (This is a
% property of the univariate normal distribution with 0 mean, because the
% variance is in fact the expected squared value when the mean is 0.  These
% facts allow us to draw a right triangle with hypotonuese corresponding to
% the expected length and rise corresponding to 1.  Then we can compute the
% squared value of the run using Pythagoreus.  
%
% Then, we shrink the run by w and the rise by (1-w) and compute the length
% of the hypotenuse after the shrinking.  Taking the ratio of this length
% with the original expected length gives us an approximation to the amount
% we need to shrink distance to approximate what we'd get, on average, if
% we did the underlying dimensional shrinkage.  We have no theorems about
% this, it is based on intuition and in comparison with simulations
% improves the approximation compared to not doing it.
%
% Note that this adjustment only applies to the factor we apply to the
% length of y1 -- it is not the right adjustment for the length of y2.  We
% compute that length below.
expectedLengthsSquared1 = sum(probForEachValueOf1.*lengthsSquared1);
expectedRise1Squared = 1;
expectedRun1Squared = expectedLengthsSquared1 - expectedRise1Squared ;
expectedAdjustedLengthsSquared1 = w^2*expectedRun1Squared + (1-w)^2*1;
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


% This happens if the first distance is less than the second distance.
%
% The way we find the probability is to take the expected value that the
% first distance is less than the second distance, with the expectation
% taken across values of the first distance.

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