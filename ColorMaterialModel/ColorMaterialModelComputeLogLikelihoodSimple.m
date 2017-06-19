%function logLikely = ColorMaterialModelComputeLogLikelihoodSimple(theResponses,predictedProbabilities,nTrials)
function logLikely = ColorMaterialModelComputeLogLikelihoodSimple(theResponses,predictedProbabilities,nTrials)
% Computes log likelihood of the prediction fit given the data. 
% Note, it is specific to the binomial trial type (choose first vs. second
% competitor)
% Input (should all be column vectors): 
%   theResponses - the data (responses in the experiment)
%   predictedProbabilities - predicted probabilities based on a model. 
%   nTrials - total number of trials run (over which the probability is computed) 
% Outputs: 
%   logLikely - computed log-likelihood. 
% 
% 2/7/17  ar  Wrote it 

logLikely = 0;
nDataPoints = length(theResponses);
for i = 1:nDataPoints
    logLikely = logLikely + theResponses(i)*log10(predictedProbabilities(i)) + (nTrials(i)-theResponses(i))*log10(1-predictedProbabilities(i));
end


