function [theSmoothPreds,theSmoothVals] = FitColorMaterialModelWeibull(thisData,theDeltaCs, fixPoint)
% [theSmoothPreds,theSmoothVals] = FitColorMaterialModelWeibull(thisData,theDeltaCs, fixPoint)
%
% Fit the descriptive Weibull model to the data.
%
% Input: 
%   thisData - response probabilities that are fitted (all are the same
%              colorMatchMaterialCoordiante)
%   theDeltaCs - number of color difference steps (i.e. number of
%                materialMatchColorCompetitors); 
%   fixPoint - setting this value to 1 causes the fit to pass through 0.5
%              in case when the subject sees the target and two identical
%              stimuli. 
% Output: 
%   theSmoothVals  - fit values for the x-axis
%   theSmoothPreds - fit values for the y-axis 

% 11/27/16  ar Adapted it from the working version of the routines that were fitting the data.  


% Smooth values for interpolation. 
% Make sure the fit includes a zero, so that all Weibull functions would
% look nice. 
nSmoothVals = 100;
theSmoothVals = sort([0 ; linspace(theDeltaCs(1),theDeltaCs(end),nSmoothVals)']);

% Allocate some space
nVals = size(theDeltaCs,1);
theSmoothPreds = zeros(nSmoothVals,1);

% Try some starting places to optimize the fits.
tryMin = [0:0.1:0.4];
tryShape = [0.01, 0.25, 0.5, 1, 2, 3];
minError = Inf;

for k1 = 1:length(tryMin)
    for k2 = 1:length(tryShape)
        
        % Set up search parameters
        theScaleNeg0 = 1;
        theScalePos0 = 1;
        theShape0 = tryShape(k2);
        theMin0 = tryMin(k1);
        theRange0 = 1-theMin0;
        x0 = [theScaleNeg0 theScalePos0 theShape0 theMin0 theRange0]';
        
        % Set reasonable bounds on parameters
        if fixPoint == 1
            % force the fit to go through 0.5 when the subject sees two identical
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
        
        % current best solution
        xTemp = fmincon(@(x)FitColorMaterialWeibullFun(x,theDeltaCs,thisData),x0,A,b,[],[],vlb,vub,[],options);
        
        % compute the error of the current best solution
        [minErrorTemp, ~] = FitColorMaterialWeibullFun(xTemp,theDeltaCs,thisData);
        
        % keep track of the smallest error and best solution so far. 
        if (minErrorTemp < minError)
            x = xTemp;
            minError = minErrorTemp;
        end
    end
end

% Once we have the best Weibull function parameters, we will compute the predictions for 
% a series of values. 
[~, theSmoothPreds] = FitToColorMaterialTradeOffFun(x, theSmoothVals);
        
end