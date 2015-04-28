function [logLikely, predictedResponses] = ThurstScalingComputeLogLikelihood(thePairs,theResponses,nTrials,yFit,sigma)
% function [logLikely,predictedResponses] = ThurstScalingComputeLogLikelihood(thePairs,theResponses,nTrials,yFit,sigma)
%
% Computes cummulative log likelihood and predicted responses for a current MLDS solution. 
%   Input: 
%       thePairs -     competitor pairs. 
%       theResponses - set of responses for this pair (number of times first
%                      competitor is chosen. 
%       nTrials -      total number of trials run. 
%       yFit  -        current inferred stimulus positions. 
%       sigma -        fixed standard deviation
%   
%   Output: 
%       logLikelyFit -        log likelihood of the fit.
%       predictedResponses -  responses predicted from the fit.
%
% 4/28/15  dhb  Wrote from MLDS version.

nPairs = size(thePairs,1);
logLikely = 0;
for i = 1:nPairs
    predictedResponses(i) = MLDSComputeProb(yFit(thePairs(i,1)),yFit(thePairs(i,2)),sigma); %#ok<AGROW>
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

