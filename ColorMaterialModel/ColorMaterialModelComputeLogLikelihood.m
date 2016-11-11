function [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials,xFit,yFit,sigma)
% function [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials,xFit,yFit,sigma)
% This is identical to a function we are using the the ColorSelectionModel.
%
%
% Computes cummulative log likelihood and predicted responses for a current MLDS solution. 
%   Input: 
%       thePairs -     competitor pairs. 
%       theResponses - set of responses for this pair (number of times first
%                      competitor is chosen. 
%       nTrials -      total number of trials run. 
%       xFit  -        current inferred position for the target. 
%       yFit  -        current inferred matches for a set of competitors. 
%       sigma -        fixed standard deviation
%   
%   Output: 
%       logLikelyFit -        log likelihood of the fit.
%       predictedResponses -  responses predicted from the fit.
%
% 11/07/16  ar  Copied it to the new directory. 


nPairs = size(thePairs,1);
logLikely = 0;
for i = 1:nPairs
    predictedResponses(i) = MLDSComputeProb(xFit,yFit(thePairs(i,1)),yFit(thePairs(i,2)),sigma,@MLDSIdentityMap); %#ok<AGROW>
    if (isnan(predictedResponses))
        error('Returned probability is NaN');
    end
    if (isinf(predictedResponses))
        error('Returend probability is Inf');
    end
    logLikely = logLikely + theResponses(i)*log10(predictedResponses(i)) + (nTrials(i)-theResponses(i))*log10(1-predictedResponses(i));
end
if (isnan(logLikely))
    error('Returned likelihood is NaN');
end

end

