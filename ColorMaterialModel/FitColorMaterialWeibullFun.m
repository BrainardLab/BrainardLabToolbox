function [f,thePreds] = FitColorMaterialWeibullFun(x,theVals,theData)
% function [f,thePreds] = FitColorMaterialWeibullFun(x,theVals,theData)
%
% Error function used to minimize the difference between the actual and predicted data
% for the descriptive Weibull model.
%
% Input: 
%   x - current parameters of the Weibul function
%   theVals - initial input values (x-Axis)
%   theData - measured probabilities for the input values (y-Axis)
%
% Output: 
%   f - root mean square error between the predicted and actual values
%   thePreds - the predicted values, given the current paramters.

% 11/27/16 ar Adapted it from a function written initially by dhb. 
% 11/28/16 ar Added comments.  

% Unpack the parameter vector.
theScaleNeg = x(1);
theScalePos = x(2);
theShape = x(3);
theMin = x(4);
theRange = x(5);

% Compute error only if we provide the actual data. Otherwise, return the values of a Weibull fit
% that correspond to the current paramters given our set of input values. 
thePreds = ColorMaterialModelComputeWeibullProb(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange);

% NOT SURE WHY THIS FUNCTION DOES NOT CRASH IF NARGIN =< 2???? 
if (nargin > 2)
    f = ComputeRealRMSE(theData,thePreds); 
else
    f = [];
end
end