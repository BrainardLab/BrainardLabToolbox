%function logLikely = ColorMaterialModelComputeLogLikelihoodSimple(theResponses,predictedProbabilities,nTrials)
function logLikely = ColorMaterialModelComputeLogLikelihoodSimple(theResponses,predictedProbabilities,nTrials)
%
% Computes log likelihood of the data to prediction fit.
% Note, it is specific to the binomial trial type (choose first vs. second
% competitor)
% Inputs should be column vectors.
%
% 2/7/17  ar  Wrote it 
logLikely = 0;
nDataPoints = length(theResponses);
for i = 1:nDataPoints
    logLikely = logLikely + theResponses(i)*log10(predictedProbabilities(i)) + (nTrials(i)-theResponses(i))*log10(1-predictedProbabilities(i));
end


