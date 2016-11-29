function thePreds = ColorMaterialModelComputeTradeOffPredictions(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange)
%function thePreds = ColorMaterialModelComputeTradeOffPredictions(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange)
% Fit the Weibull function given the current parameters. 
% There are two legs of this function - positive and negative, each is allowed to have its own
% scale but not shape parameters. 
% 
% 11/28/16 ar   Simplified original function written by dhb

% NOT SURE WHY WE DON T ALLOW DIFFERENT SHAPES FOR THE TWO PARTS?

FORCE_ASYMPTOTE = true;
if (FORCE_ASYMPTOTE)
    theRange = 1-theMin;
end

thePreds = NaN*ones(size(theVals));
index = find(theVals < 0);
if (~isempty(index))
    thePreds(index) = theMin+theRange*wblcdf(abs(theVals(index)),theScaleNeg,theShape);
end

index = find(theVals >= 0);
if (~isempty(index))
    thePreds(index) = theMin+theRange*wblcdf(abs(theVals(index)),theScalePos,theShape);
end

