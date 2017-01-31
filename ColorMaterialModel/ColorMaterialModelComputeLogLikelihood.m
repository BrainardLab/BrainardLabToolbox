function [logLikely, predictedProbabilities] = ColorMaterialModelComputeLogLikelihood(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
     theResponses, nTrials,targetColorCoord,targetMaterialCoord,w,sigma)
% [logLikely, predictedProbabilities] = ColorMaterialModelComputeLogLikelihood(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
%    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
%    theResponses, nTrials,targetColorCoord,targetMaterialCoord,w,sigma)
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
%       logLikelyFit -            log likelihood of the fit.
%       predictedProbabilities -  responses predicted from the fit.
%
% 11/16/16  ar  This function is adapted from equivalent function for our MLDS model.
%               It is replaced with the new probability function and updated
%               accordingly.

% Compute the log likelihood
logLikely = 0;
nPairs = length(pairColorMatchMaterialCoords);
for i = 1:nPairs
    
    colorMatchColorCoord = pairColorMatchColorCoords(i);
    materialMatchColorCoord = pairMaterialMatchColorCoords(i);
    colorMatchMaterialCoord = pairColorMatchMaterialCoords(i);
    materialMatchMaterialCoord = pairMaterialMatchMaterialCoords(i);
    
    ANALYTIC = false;
    if (ANALYTIC)
        predictedProbabilities(i) = ColorMaterialModelComputeProb(targetColorCoord, targetMaterialCoord, ...
            colorMatchColorCoord, materialMatchColorCoord, ...
            colorMatchMaterialCoord,materialMatchMaterialCoord, w, sigma);
    else
        nSimulate = 1000;
        predictedResponses = zeros(nSimulate,1);
        s = rng(173);
        for kk = 1:nSimulate
            predictedResponses(kk) = ColorMaterialModelSimulateResponse(targetColorCoord, targetMaterialCoord, ...
                pairColorMatchColorCoords(i), pairMaterialMatchColorCoords(i), ...
                pairColorMatchMaterialCoords(i), pairMaterialMatchMaterialCoords(i), w, sigma);
        end
        rng(s);
        predictedProbabilities(i) = mean(predictedResponses);
    end
    
    if (isnan(predictedProbabilities(i)))
        error('Returned probability is NaN');
    end
    
    if (isinf(predictedProbabilities(i)))
        error('Returend probability is Inf');
    end
    
    logLikely = logLikely + theResponses(i)*log10(predictedProbabilities(i)) + (nTrials(i)-theResponses(i))*log10(1-predictedProbabilities(i));
end

% Something bad happened if this is true
if (isnan(logLikely))
    error('Returned likelihood is NaN');
end

end

