% function [theSmoothPreds,theSmoothVals] = FitColorMaterialModelWeibull(thisData,theDeltaCs, fixPoint)
function [theSmoothPreds,theSmoothVals] = FitColorMaterialModelWeibull(thisData, differenceSteps, fixPoint)
% Fit the descriptive Weibull model to the data.
% Input: 
%   thisData - response probabilities for color/material trade off trials. 
%   differenceSteps - number of difference steps (we assume it is the same
%                for color and material) 
%   fixPoint - boolean; setting this to true enforces the fit to pass through 0.5
%              for trials in which the subject sees the target and two identical
%              stimuli. 
% Output: 
%   theSmoothVals  - set of values for the x-axis.
%   theSmoothPreds - corresponding y-values.  
%
% 11/27/16  ar Adapted it from the working version of the routines that were fitting the data.  
% 06/19/17  ar Added comments. 

% Set some smooth values for interpolation. These need to include zero
% (otherwise the fit won't look nice). 
nSmoothVals = 100;
theSmoothVals = sort([0; linspace(differenceSteps(1),differenceSteps(end),nSmoothVals)']);

% Allocate some space
nVals = size(differenceSteps,1);
theSmoothPreds = zeros(nSmoothVals,1);

% Try a few initial values for function paramters to optimize the fit.
tryMin = 0:0.1:0.4;
tryShape = [0.01, 0.25, 0.5, 1, 2, 3];

% Initialize minimal error before we have started to fit the data. 
minError = Inf;

for k1 = 1:length(tryMin)
    for k2 = 1:length(tryShape)
        
        % Set up initial parameters
        % We fix the scale to 1 and vary shape and minimum. 
        theScaleNeg0 = 1;
        theScalePos0 = 1;
        theShape0 = tryShape(k2);
        theMin0 = tryMin(k1);
        theRange0 = 1-theMin0;
        x0 = [theScaleNeg0 theScalePos0 theShape0 theMin0 theRange0]';
        
        % Set reasonable bounds on parameters
        if fixPoint == 1
            % Force the fit to go through 0.5 when the subject sees two identical
            % tests - we do that by setting both the lower and the
            % upper bound to 0.5 
            vlb = [0.001 0.001 0.01 0.5 0];
        else
            vlb = [0.001 0.001 0.01 0 0];
        end
        vub = [100 100 10 0.5 1];
        
        % Enforce max percent < 1
        A = [0 0 0 1 1]; b = 1;
        
        options = optimset('fmincon');
        options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
        
        % Return the parameters for the current solution. 
        xTemp = fmincon(@(x)FitColorMaterialWeibullFun(x,differenceSteps,thisData),x0,A,b,[],[],vlb,vub,[],options);
        
        % Compute the error of the current solution
        [minErrorTemp, ~] = FitColorMaterialWeibullFun(xTemp,differenceSteps,thisData);
        
        % Keep track of the smallest error and best solution so far. 
        if (minErrorTemp < minError)
            x = xTemp;
            minError = minErrorTemp;
        end
    end
end

% Given the best, found paramters compute the predictions for a series of values. 
[~, theSmoothPreds] = FitColorMaterialWeibullFun(x, theSmoothVals);
        
end