function [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials, materialPositions, colorPositions,targetIndex, w, sigma)
% function [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials,materialPositions, colorPositions,targetIndex, w, sigma)
%
% Computes cummulative log likelihood and predicted responses for a current weights and positions.
%   Input:
%       thePairs     - competitor pairs.
%       theResponses - set of responses for this pair (number of times first
%                      competitor is chosen.
%       nTrials      - total number of trials run.
%       materialPositions - current inferred position for color matches on the material axis.
%       colorPositions - current inferred position for material matches on the color axis.
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
colorMatchColorCoord = colorPositions(targetIndex);
materialMatchMaterialCoord = materialPositions(targetIndex);

logLikely = 0;
for i = 1:nPairs
    predictedResponses(i) = ColorMaterialModelComputeProb(materialPositions(targetIndex), colorPositions(targetIndex), colorMatchColorCoord, materialPositions(thePairs(i)), colorPositions(thePairs(i)),materialMatchMaterialCoord, w, sigma);
    % ColorMaterialModelComputeProb(targetColorCoord,targetMaterialCoord, colorMatchColorCoord,materialMatchColorCoord,colorMatchMatrialCoord, materialMatchMaterialCoord, w, sigma)
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

