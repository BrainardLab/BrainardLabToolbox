function rmse = ComputeRealRMSE(data,predict)
% rmse = ComputeRealRMSE(data,predict)
%
% Compute a root mean square error between data and prediction.
% Inputs should be vectors ore matrices of the same size.  The
% error is taken over the correspnding elements in either case.
%
% See also ComputeRMSE (in PTB).

% 12/19/16  ar  Wrote it from dhb ComputeRMSE script

diff = predict(:)-data(:);
diffSquared = diff.^2;
meanDiffSquared = mean(diffSquared); 
rmse = sqrt(meanDiffSquared); 