function logLikely = computeLogLikelihood(theResponses,predictedProbabilities,nTrials)
% logLikely = computeLogLikelihood(data,predict)
%
% Computes LogLikelihood of the data to prediction fit.
% Inputs should be column vectors.
%
% 2/7/17  ar  Wrote it 
logLikely = 0;
nDataPoints = length(theResponses);
for i = 1:nDataPoints
    logLikely = logLikely + theResponses(i)*log10(predictedProbabilities(i)) + (nTrials(i)-theResponses(i))*log10(1-predictedProbabilities(i));
end


