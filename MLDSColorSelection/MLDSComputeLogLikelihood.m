function [logLikely, predictedResponses] = MLDSComputeLogLikelihood(thePairs,theResponses,nTrials,xFit,yFit,sigma)
% function [logLikely,predictedResponses] = MLDSComputeLogLikelihood(thePairs,theResponses,nTrials,xFit,yFit,sigma)
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
% 05/03/12  dhb  Store and return predicted probabilities.
% 06/13/13  ar   Added more comments. 

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

