function thePreds = ColorMaterialModelComputeTradeOffPredictions(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange)
%function thePreds = ColorMaterialModelComputeTradeOffPredictions(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange)
% Fit the Weibull function given the current parameters. 
%
% There are two legs of this function - positive and negative, each is allowed to have its own
% scale but not shape parameters. Note that we are fixing the shape to be
% the same for both positive and negative leg (this can change in the
% future, if needed). 
% 
% 11/28/16 ar   Simplified original function written by dhb

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

