function [f,thePreds] = FitToColorMaterialTradeOffFun(x,theVals,theData)
% function [f,thePreds] = FitToColorMaterialTradeOffFun(x,theVals,theData)

% Error function used to minimize the difference between the actual and predicted data
% Input: 
% x - current parameters of the Weibul function
% theVals - the 
% theData - 
% Output: 
% f - root mean square error between the predicted and actual values
% thePreds - the predicted values, given the current paramters.


% Unpack the parameter vector. 
theScaleNeg = x(1);
theScalePos = x(2);
theShape = x(3);
theMin = x(4);
theRange = x(5);

thePreds = ColorMaterialModelComputeTradeOffPredictions(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange);

if (nargin > 2)
    theDiff = theData-thePreds;
    f = sqrt(mean(theDiff.^2));
else
    f = [];
end



