function p = ColorMaterialModelComputeProb(targetColorCoord,targetMaterialCoord, colorMatchColorCoord,materialMatchColorCoord,colorMatchMatrialCoord, materialMatchMaterialCoord, w, sigma)
% function p = ColorMaterialModelComputeProb(targetColorCoord,targetMaterialCoord, colorMatchColorCoord,materialMatchColorCoord,colorMatchMatrialCoord, materialMatchMaterialCoord, w, sigma)
%
% This function is part of our modeling effort for our initial
% color-material tradeoff experiments.  On each trial of these experiments,
% there is a single target stimulus and two competitors (colorMatch and
% materialMatch).  The first competitor differs from the target in color
% while the second differs in terms of material.  The subject indicates
% which competitor is closer to the target.
%
% Our model assumes that there is a two-dimensional representational space,
% with color on one axis and material on the other.  We make this
% assumption because our stimulus manipulations of color and material lie
% along a single line in the higher-dimensional color and material
% perceptual spaces.  We assume that there is trial-by-trial noise in the
% position of both competitors in the space.  For simplicity, we assume
% that the target position is fixed at the origin. (We think this is
% without loss of generality, although we should probably check it more
% closely.)  We then assume that the subject picks the colorMatch if on
% that trial the distance between the colorMatch and the target is less
% than the distance between the materialMatch and the target.
%
% The job of this function is to compute the probility that the subject
% picks the colorMatch, that is, the probability that the colorMatch is
% closer to the target when we aggregate over trials with the same stimulus
% triad.  The routine takes the positions of the target, the colorMatch,
% and the materialMatch in the perceptual space, as well as the noise
% standard deviation for each dimension and a weight value w that
% determines how distances are scaled along the color and material axes of
% the perceptual space.
%
% Despite the fact that it takes a number of variables, the routine is
% based on some assumptions and approximations.  These could be relaxed if
% we computed the probability through forward simulation, but our goal here
% is to provide a reasonable analytic approximation that applies to our
% current experiments.
%  1) Target position is always 0,0.
%  2) The mean of the the colorMatch representational distribution lies on the material axis
%     and the mean of the the materialMatch representational distribution lies on the color axis.
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
% on the underlying dimensions.  With the fact that the colorMatch and the
% materialMatch each lie close to the axis on each trial, perturbed away
% from it only by the noise, this isn't a bad assumption and we can do a
% first order correction for the expected deviation of the representation
% from each axis.
%
% Note that 'analytic' here does involve some numerical intergration. But
% it does not involve forward simulation and the answer we return is
% deterministic.  A deterministic value is important for numerical search,
% which will call this routine as part of its objective function.
%
%   Inputs:
%       targetColorCoord  - target position on color dimension (fixed to 0).
%       targetMaterialCoord  - target position on material dimension (fixed to 0).
%
%       colorMatchColorCoord - inferred position on the color dimension for the first competitor in the pair
%       materialMatchColorCoord - inferred position on the material dimension for the first competitor in the pair
%       colorMatchMaterialCoord - inferred position on the color dimension for the second competitor in the pair
%       materialMatchMaterialCoord - inferred position on the material dimension for the second competitor in the pair
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
numTolerance = 1e-7;
if (abs(targetColorCoord) > numTolerance || abs(targetMaterialCoord) > numTolerance)
    error('We baked in that the target is at 0,0, but it is not');
end

% We assume that sigma is 1, check
if (abs(sigma-1) > numTolerance)
    error('Code assumes that sigma is 1');
end

% Check w and also avoid numerical problems for very small w or (1-w)
if ~(w > -numTolerance || abs(w-1)  > numTolerance)
    error('w must be between 0 and 1 inclusive');
end
if (w == 0)
    w = 0.0001;
elseif (w == 1)
    w = 0.9999;
end

%% Compute distribution of distances (over trials) of competitor colorMatch
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
% Also take square root to get mean distance.
deltaColorMatch = colorMatchColorCoord^2 + colorMatchMatrialCoord^2;

% We'll also need the distance of the mean of the distribution of the colorMatch in the
% perceptual space.
meanDistanceColorMatch = sqrt(deltaColorMatch);

% Step 2: We want the probability distribution for the distance of noisy
% draws of the colorMatch in the stimulus space. Given the assumption we
% make that sigma is 1 for both axes, and the fact my1 = 0, the
% distribution of distances of the colorMatch is going to be between
% meanDistance +/- n, where n is 3 or 4 or something like that (because
% sigma == 1) and not too much gets perturbed because the noise along the
% material direction isn't going to screw things up too much. We use this
% fact to compute a set of discrete values for the distance of the
% colorMatch that covers the range of values that will occur.

% Turns out empirically that 6 is a good range, and we'll compute the pdf
% over nSamplesValues within that range, to get a good approximation.
% Distances cannot be negative.  It is convenient to work in distance^2,
% because that's what the non-central chi-squared describes the probability
% of.
%
% Note that the length of distance the colorMatch is the same as the distance between the colorMatch
% and the target, because we force the target to be at the origin.
rangeValue = 6;
nSampleValues = 100;
minDistanceColorMatch = max([0 meanDistanceColorMatch-rangeValue]);
distancesSquaredColorMatch = linspace(minDistanceColorMatch^2,(meanDistanceColorMatch+rangeValue)^2,nSampleValues);
deltaValuesColorMatch = distancesSquaredColorMatch(2)-distancesSquaredColorMatch(1);

% Now get probability for each interval over the sampled distances for the colorMatch,
% using the non-central chi-squared.  Make sure the probability sums to 1.
probForEachValueOfColorMatch = ncx2pdf(distancesSquaredColorMatch,2,deltaColorMatch)*deltaValuesColorMatch;
totalProbColorMatch = trapz(probForEachValueOfColorMatch);
if (PLOTS)
    % Show sampled PDF, optionally.
    plotFigure1 = figure; clf; hold on;
    plot(distancesSquaredColorMatch,probForEachValueOfColorMatch,'r','LineWidth',2);
    xlabel('Distance of the colorMatch')
    ylabel('Probability');
end
if (abs(totalProbColorMatch - 1) > 1e-2)
	fprintf('totalProb1 = %0.3f\n',totalProbColorMatch);
    error('Total probability that distance1 has a distance is not close enough to 1');
end

%% Compute expected value of distance1 and adjust w
%
% We want to compare the distance to the colorMatch and the materialMatch
% in a weighted fashion. Ideally, we would compute each distance by
% weighting the color axis by w and the material axis by (1-w).  But we
% can't calculate that, because the non-central chi-squared requires that
% we take the compute the sum of squares of independent normal random
% variables each with sigma = 1.
%
% So, we do a trick.  First note that in the limit that sigma -> 0, the
% distance of the colorMatch depends only on the material axis position and
% the distance of the materialMatch only on the color axis position.  In
% this case, we could weight the distance of the colorMatch by w and the
% distance of the materialMatch by (1-w) and compare those distances.
% Doing that in fact (we checked) gives an excellend contribution for cases
% where cy1 >> 1 and my2 >> 1.  But when cy1 gets smaller (say, < 20 or so
% based on some simulations we did) or my2 gets similarly small, the trial
% by trial variation that takes the perceptual representations off the axes
% intrudes on the approxmation more than we would like.
%
% So, here's what we do.  First, we find the expected distance of the
% colorMatch.  Then, we note that the expected value of the distance of the
% material component of the colorMatch is 1 and thus its expected squared
% distance is also 1.  (This is a property of the univariate normal
% distribution with 0 mean, because the variance is in fact the expected
% squared value when the mean is 0.  These facts allow us to draw a right
% triangle with hypotonuese corresponding to the expected distance and rise
% corresponding to 1.  Then we can compute the squared value of the run
% using Pythagoreus.
%
% Then, we shrink the run by w and the rise by (1-w) and compute the
% distance of the hypotenuse after the shrinking.  Taking the ratio of this
% distance with the original expected distance gives us an approximation to
% the amount we need to shrink distance to approximate what we'd get, on
% average, if we did the underlying dimensional shrinkage.  We have no
% theorems about this, it is based on intuition and in comparison with
% simulations improves the approximation compared to not doing it.
%
% Note that this adjustment only applies to the factor we apply to the
% distance of the colorMatch -- it is not the right adjustment for the
% distance of the materialMatch.  We compute that distance below.
expectedDistancesSquaredColorMatch = trapz(probForEachValueOfColorMatch.*distancesSquaredColorMatch);
expectedRiseSquaredColorMatch = 1;
expectedRunSquaredColorMatch = expectedDistancesSquaredColorMatch - expectedRiseSquaredColorMatch ;
expectedAdjustedDistancesSquaredColorMatch = (w^2)*1 + ((1-w)^2)*expectedRunSquaredColorMatch;
adjustedW = sqrt(expectedAdjustedDistancesSquaredColorMatch / expectedDistancesSquaredColorMatch);
%fprintf('Adjusted w %0.3f, w %0.3f\n',adjustedW,w);

%% Compute expected value of distanceMaterialMatch and get the adjusted factor (1-w)
% This factor is used to adjust the weight on the second dimension.
%
% The logic here is essentially like what we did for distance1 above.
deltaMaterialMatch = materialMatchColorCoord^2 + materialMatchMaterialCoord^2;
meanDistanceMaterialMatch = sqrt(deltaMaterialMatch);
minDistanceMaterialMatch = max([0 meanDistanceMaterialMatch-rangeValue]);
distancesSquaredMaterialMatch = linspace(minDistanceMaterialMatch^2,(meanDistanceMaterialMatch+rangeValue)^2,nSampleValues);
deltaValuesMaterialMatch = distancesSquaredMaterialMatch(2)-distancesSquaredMaterialMatch(1);
probForEachValueOfMaterialMatch = ncx2pdf(distancesSquaredMaterialMatch,2,deltaMaterialMatch)*deltaValuesMaterialMatch;
totalProbMaterialMatch = trapz(probForEachValueOfMaterialMatch);
if (PLOTS)
    plotFigure2 = figure; clf; hold on
    plot(distancesSquaredMaterialMatch,probForEachValueOfMaterialMatch,'r','LineWidth',2);
    xlabel('Distance2')
    ylabel('Probability');
end
if (abs(totalProbMaterialMatch - 1) > 1e-2)
    fprintf('totalProb2 = %0.3f\n',totalProbMaterialMatch);
    error('Total probability that distance2 has a distance is not close enough to 1');
end
expectedDistancesSquaredMaterialMatch = trapz(probForEachValueOfMaterialMatch.*distancesSquaredMaterialMatch);
expectedASquaredMaterialMatch = expectedDistancesSquaredMaterialMatch - 1;
expectedAdjustedDistancesSquaredMaterialMatch = (w^2)*expectedASquaredMaterialMatch + ((1-w)^2)*1;
adjustedOneMinusW = sqrt(expectedAdjustedDistancesSquaredMaterialMatch / expectedDistancesSquaredMaterialMatch);
%fprintf('Adjusted (1-w) %0.3f, (1-w) %0.3f\n\n',adjustedOneMinusW,1-w);

%% Compute probability of a response of 1
% This happens if the first distance is less than the second distance.
%
% The way we find the probability is to take the expected value that the
% first distance is less than the second distance, with the expectation
% taken across values of the first distance.
%
% We use the adjusted weights as calculated above when comparing the
% distances.

% For each value that the first distance might take on, compute the
% probability that the second distance is longer.  For this we use
% the cdf of the ncx2 distribution.
%
% We are interested in the probabilty that:
%         adjustedW^2*distanceSquared1 < adjustedOneMinusW^2*distanceSquared2
%   <=>   (adjustedW^2/adjustedOneMinusW^2)*distanceSquared1 < distanceSquared2
% This is given by the probability that distanceSquared2 is greater than
% the quantity on the left.  We know this by taking 1 minus the cdf of
% distancesSquared2 with respect to the quantity on the left.  And we know
% the cdf of distanceSquared2 since it is given by the non-central chi2
% with the distanceSquared2 parameters.
%p1LessThan2ForEachValueOf1 = 1 - ncx2cdf((adjustedW/adjustedOneMinusW)^2*distancesSquared1,2,delta2);
pColorMatchLessThanMaterialMatchForEachValueOfColorMatch = 1 - ncx2cdf((adjustedW/adjustedOneMinusW)^2*distancesSquaredColorMatch,2,deltaMaterialMatch);

if (PLOTS)
    plotFigure3 = figure; clf; hold on
    plot(distancesSquaredColorMatch,pColorMatchLessThanMaterialMatchForEachValueOfColorMatch,'r','LineWidth',2);
    xlabel('Distance1')
    ylabel('Probability 1 Less Than 2');
end

% Now we just need to take the expected value of the quantity we just
% computed, over the values of distanceSquared1, and we already have
% these probabilities from our work above.  So we get our desired
% probability!
p = trapz(probForEachValueOfColorMatch .* pColorMatchLessThanMaterialMatchForEachValueOfColorMatch);

%% Deal with edge cases to avoid disaster when computing likilihoods later on
if (p == 0)
    p = 0.0001;
elseif (p == 1)
    p = 0.9999;
end
end