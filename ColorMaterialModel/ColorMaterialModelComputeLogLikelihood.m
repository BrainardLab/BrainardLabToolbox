function [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices, ...
     theResponses,nTrials,colorMatchMaterialCoords,materialMatchColorCoords,targetIndex,w,sigma)
% function [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(pairColorMatchMatrialCoordIndices,pairMaterialMatchColorCoordIndices, ...
%    theResponses,nTrials,colorMatchMaterialCoords,materialMatchColorCoords,targetIndex,w,sigma)
%
% Computes cummulative log likelihood and predicted responses for a current weights and positions.
%   Input:
%       pairColorMatchMatrialCoordIndices - index to get color match material coordinate for each trial type.
%       pairMaterialMatchColorCoordIndices - index to get material match color coordinate for each trial type.
%       theResponses - set of responses for this pair (number of times color match is chosen.
%       nTrials - total number of trials run.
%       colorMatchMaterialCoords - current inferred position for color matches on the material axis.
%       materialMatchColorCoords - current inferred position for material matches on the color axis.
%       sigma -fixed standard deviation
%       w - current weight(s) for color/material axes.
%
%   Output:
%       logLikelyFit -        log likelihood of the fit.
%       predictedResponses -  responses predicted from the fit.
%
% 11/16/16  ar  This function is adapted from equivalent function for our MLDS model.
%               It is replaced with the new probability function and updated
%               accordingly.

% Get some basic info out
nPairs = size(pairColorMatchMatrialCoordIndices,1);
targetColorCoord = materialMatchColorCoords(targetIndex);
colorMatchColorCoord = targetColorCoord;
targetMaterialCoord = colorMatchMaterialCoords(targetIndex);
materialMatchMaterialCoord = targetMaterialCoord;

% Check that should be true in our current implementation
tolerance = 1e-7;
if (abs(colorMatchColorCoord) > tolerance || abs(materialMatchMaterialCoord) > tolerance)
    error('A coordinate that should be locked at zero is not');
end

% Compute the log likelihood
logLikely = 0;
for i = 1:nPairs
    predictedResponses(i) = ColorMaterialModelComputeProb(targetColorCoord, targetMaterialCoord, ...
        colorMatchColorCoord, materialMatchColorCoords(pairMaterialMatchColorCoordIndices(i)), ...
        colorMatchMaterialCoords(pairColorMatchMatrialCoordIndices(i)),materialMatchMaterialCoord, ...
        w, sigma);
    
    if (isnan(predictedResponses(i)))
        error('Returned probability is NaN');
    end
    if (isinf(predictedResponses(i)))
        error('Returend probability is Inf');
    end
    
    logLikely = logLikely + theResponses(i)*log10(predictedResponses(i)) + (nTrials(i)-theResponses(i))*log10(1-predictedResponses(i));
end

% Something bad happened if this is true
if (isnan(logLikely))
    error('Returned likelihood is NaN');
end

end

