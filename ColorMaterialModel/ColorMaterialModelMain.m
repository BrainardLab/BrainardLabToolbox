
function [targetCompetitorFit, logLikelyFit, predictedResponses] = ColorMaterialModelMain(thePairs,theResponses,nTrialsPerPair, numberOfCompetitors)
% function [targetCompetitorFit, logLikelyFit, predictedResponses] = ColorMaterialModelMain(thePairs,theResponses,nTrialsPerPair, numberOfCompetitors)


%% The number of responses in theResponses cannot ever exceed nTrialsPerPair.
% Check this and throw error message if it does not hold.
if (length(theResponses(:)) ~= length(nTrialsPerPair(:)))
    error('Passed theResponses and nTrialsPerPair must be of same length');
end
if (any(theResponses > nTrialsPerPair))
    error('An entry of input theResponses exceeds passed nTrialsPerPair.  No good!');
end

%% Set fixed parameters
%
% Standard deviation for the MLDS solution.
% This determines the scale of the solution.
sigma = 1;

% Determine minimum size of interval between
% solution elements, relative to sigma.  That
% is, the minimum spacing will be sigma/sigmaFactor.
sigmaFactor = 4;

%% Set up parameters for search.
A = zeros(numberOfCompetitors-2,numberOfCompetitors);
for i = 1:numberOfCompetitors-2
    A(i,i+1) = 1;
    A(i,i+2) = -1;
end

% This is the minimum interval size for use with the
% the A matrix above.
b = -sigma/sigmaFactor*ones(numberOfCompetitors-2,1);

% We have determined that target is going to be at 0. 
targetPosition = 0; 

% Set spacings for initializing the search.  
% Try different ones in the hope that we thus avoid local minima in 
% the search.
%
% Note that these spacings are hard coded and were determined
% from experience.  Thus they are rather 
% specific to the type of color selection experiment we
% have been doing.  It is possible that there would be a
% cleverer thing to do here.
trySpacings = [0.5 1 2];

% Standard fmincon options
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');

%% Search
%
% We search over various initial spacings and take the best result.
% There are two loops.  One sets the positions of the competitors
% in the solution.  The other tries different places for the target
% in the solution.
%
% In terms of variable names below, Y indicates competitor positoins,
% while X is (unfortunately
maxLogLikely = -Inf; 

for k1 = 1:length(trySpacings)
    % Choose initial competitor positions based on current spacing to try.
    %initialCompetitorPositions = linspace(0,trySpacings(k1)*numberOfCompetitors*sigma,numberOfCompetitors);
    initialCompetitorPositionsColor = [trySpacing*linspace(-3,-1,3),targetPosition,trySpacing*linspace(1,3,3)]; 
    % TRY SPACING THE SAME OR DIFFERENT. 
    initialCompetitorPositionsMaterial = [trySpacing*linspace(-3,-1,3),targetPosition,trySpacing*linspace(1,3,3)]; 
    
        initialParams = [initialCompetitorPositionsColor initialCompetitorPositionsMaterial w]; 
        targetIndex1 = 4; 
        targetIndex2 = 11; 
        % Get reasonable upper and lower bound. These are most easily computed from the initial parameters.
        % We enforce that the competitor solutions head off in the positive direction, but the target can
        % be anywhere.  (We take 100 times the maximum value in the intial parameters to equal 'anyware');
        % 
        % Because the first competitor is at 0, the rest cannot be lower
        % than sigma/sigmaFactor.  This has the effect of enforcing C2 >
        % sigma/sigmaFactor.  And since C3 > C2 etc, using this as a lower
        % bound for C3 etc is OK.
        vlb = (sigma/sigmaFactor)*ones(size(initialParams));
        vub = 100*max(abs(initialParams))*ones(size(initialParams));
        vlb(targetIndex1) = 0; 
        vlb(targetIndex2) = 0; 
        vub(targetIndex1) = vlb(targetIndex1); % fix search for target position at 0. 
        vub(targetIndex2) = vlb(targetIndex2); % fix search for target position at 0. 
        
        % Run the search
        fitParams = fmincon(@(x)FitColorMaterialScalingFun(colorPositions,materialPositions, targetIndex, sigma, w),initialParams,A,b,[],[],vlb,vub,[],options);
        
        % Compute log likelihood for this solution.  Keep track of the best
        % solution that comes out of the multiple starting points.
        % Save this solution if it's better than the current best. 
        temp = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses, nTrials, colorPositions,materialPositions, targetIndex, sigma, w);
        if (temp > maxLogLikely)
            maxLogLikely = temp;
            [logLikelyFit,predictedResponses] = ColorMaterialComputeLogLikelyhood(thePairs,theResponses,nTrialsPerPair,fitTargetPosition,fitCompetitorPositions,sigma);
            targetCompetitorFit = [fitTargetPosition, fitCompetitorPositions];
        end
end
end

function f = FitColorMaterialScalingFun(thePairs,theResponses,nTrials, colorPositions,materialPositions, targetIndex, sigma, w)
%function f = FitColorMaterialScalingFun(thePairs,theResponses,nTrials, colorPositions,materialPositions, targetIndex, sigma, w)

% The error function we are minimizing in the numerical search.
% Computes the negative log likelyhood of the current solution i.e. the weights and the inferred
% position of the competitors on color and material axes. 
% Input: 
%   w           - the current weight(s). 
%   y1          - current competitor position fits on color and material axis. 
%   thePairs    - competitor pairs. 
%   theResponses- set of responses for this pair (number of times first
%                 competitor is chosen). 
%   nTrialsPerPair - total number of trials run. 
%   sigma          - fixed standard deviation
% Output: 
%   f - negative log likelihood for the current solution. 


% Sanity check - did any of the solutions return as NaN
if (any(isnan([colorPositions, materialPositions, w])))
    error('Entry of x is NaN');
end


% compute negative log likelyhood of the current solution
%function [logLikely, predictedResponses] = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials, colorPositions,materialPositions, targetIndex, sigma, w)
logLikely = ColorMaterialModelComputeLogLikelihood(thePairs,theResponses,nTrials, colorPositions,materialPositions, targetIndex1, sigma, w);
f = -logLikely;

end
