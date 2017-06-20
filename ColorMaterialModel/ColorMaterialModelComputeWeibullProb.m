function thePreds = ColorMaterialModelComputeWeibullProb(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange)
% thePreds = ColorMaterialModellComputeWeibullProb(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange)
%
% Return predictions from the descriptive Weibull model. 
%
% There are two legs of this function - positive and negative, each is
% allowed to have its own scale but not shape parameters. Note that we are
% fixing the shape to be the same for both positive and negative leg (this
% can change in the future, if needed).
%
% Input: 
%   theVals -   the range of values for which the function needs to be
%               evaluated. 
%   theScaleNeg - the scale parameter of the Weibull function for 
%                 negative input values
%   theScalePos - the scale parameter of the Weibull function for the
%                 positive input values. 
%   theShape - shape parameter of the Weibull function
%   theMin -   minimal value of a function (this is one of the parameters
%              we are searching for).
%   theRange - scale the function output so that given the found minimum,
%              maximal output is 1. 
% Output: 
%   thePreds - returned function values for given input values.  

% 11/28/16 ar   Simplified original function written by dhb

FORCE_ASYMPTOTE = true; % max output == 1
 
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

