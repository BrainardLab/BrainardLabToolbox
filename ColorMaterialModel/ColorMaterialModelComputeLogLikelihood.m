function [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials, colorPositions,materialPositions, targetIndex, sigma, w)
% function [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials,colorPositions,materialPositions, targetIndex, sigma, w)
%
% Computes cummulative log likelihood and predicted responses for a current weights and positions. 
%   Input: 
%       thePairs     - competitor pairs. 
%       theResponses - set of responses for this pair (number of times first
%                      competitor is chosen. 
%       nTrials      - total number of trials run. 
%       colorPositions - current inferred position for the competitors on the color axis (material matches). 
%       materialPositions - current inferred position for the competitors on the material axis (color matches).
%       sigma -        fixed standard deviation
%          w  -        current weight(s) for color/material axes.  
%   
%   Output: 
%       logLikelyFit -        log likelihood of the fit.
%       predictedResponses -  responses predicted from the fit.
%
% 11/16/16  ar  This function is adapted from equivalent function for our MLDS model. 
%               It is replaced with the new probability function and updated
%               accordingly. 

nPairs = size(thePairs,1);
logLikely = 0;
for i = 1:nPairs
    % p = ColorMaterialModelComputeProb(targetC,targetM, cy1,cy2,my1, my2, sigma, w)
    predictedResponses(i) = ColorMaterialModelComputeProb(colorPositions(targetIndex),materialPositions(targetIndex), colorPositions(thePairs(i,1)),colorPositions(thePairs(i,2)), materialPositions(thePairs(i,1)),materialPositions(thePairs(i,2)), sigma, w); 
    if (isnan(predictedResponses(i)))
        error('Returned probability is NaN');
    end
    if (isinf(predictedResponses(i)))
        error('Returend probability is Inf');
    end
    logLikely = logLikely + theResponses(i)*log10(predictedResponses(i)) + (nTrials(i)-theResponses(i))*log10(1-predictedResponses(i));
end
if (isnan(logLikely))
    error('Returned likelihood is NaN');
end

end

